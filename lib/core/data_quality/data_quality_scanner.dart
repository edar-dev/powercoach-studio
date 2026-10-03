import 'dart:convert';

import '../../features/workouts/data/workout_routine_model.dart';
import '../../features/workouts/domain/workout_routine_json_codec.dart';
import '../data_catalog/data_catalog_registry.dart';
import '../data_catalog/soft_reference.dart';
import '../sync/offline_models.dart';
import 'data_quality_finding.dart';
import 'data_quality_report.dart';
import 'data_quality_rule_ids.dart';
import 'data_quality_severity.dart';

/// Read-only scanner over local [OfflineEntity] graphs / backup JSON.
///
/// Soft-FK rules are driven by [DataCatalogRegistry] relation metadata.
/// Findings are report-only — nothing is deleted or repaired.
class DataQualityScanner {
  const DataQualityScanner();

  /// Scan an in-memory entity list (e.g. Drift cache rows).
  DataQualityReport scanEntities(List<OfflineEntity> entities) {
    final findings = <DataQualityFinding>[];
    _scanTypedEntities(entities, findings);
    return DataQualityReport(
      findings: List.unmodifiable(findings),
      scannedEntityCount: entities.length,
      generatedAt: DateTime.now().toUtc(),
    );
  }

  /// Scan a parsed backup envelope (`entities` array + optional prefs).
  ///
  /// Unknown type strings emit [DataQualityRuleIds.unknownType] /
  /// [DataQualityRuleIds.backupTypeMismatch] without throwing.
  DataQualityReport scanBackupJson(Map<String, dynamic> backup) {
    final findings = <DataQualityFinding>[];
    final rawEntities = backup['entities'];
    final list = rawEntities is List ? rawEntities : const <dynamic>[];
    final typed = <OfflineEntity>[];
    var scanned = 0;

    for (final raw in list) {
      if (raw is! Map) continue;
      scanned++;
      final map = raw.cast<String, dynamic>();
      final id = map['id']?.toString() ?? '';
      final rawType = map['type'];
      final typeName = rawType?.toString() ?? '';

      // Unknown backup type string (legacy exerciseRecord, typos, …).
      // Rule ids unknown_type and backup_type_mismatch describe the same case;
      // emit backup_type_mismatch for backup envelopes (plan alias: unknown_type).
      if (!isKnownOfflineEntityTypeName(typeName) &&
          tryParseOfflineEntityType(rawType) == null) {
        if (id.trim().isEmpty) {
          findings.add(
            DataQualityFinding(
              ruleId: DataQualityRuleIds.emptyId,
              severity: DataQualitySeverity.error,
              message: 'Backup entity has empty or missing id',
              details: <String, dynamic>{
                'type': typeName,
                'source': 'backup',
              },
            ),
          );
        }
        findings.add(
          DataQualityFinding(
            ruleId: DataQualityRuleIds.backupTypeMismatch,
            severity: DataQualitySeverity.error,
            entityId: id.isEmpty ? null : id,
            message:
                'Backup entity type "$typeName" does not match OfflineEntityType '
                '(${DataQualityRuleIds.unknownType})',
            details: <String, dynamic>{
              'type': typeName,
              'rawType': rawType,
              'aliasRuleId': DataQualityRuleIds.unknownType,
            },
          ),
        );
        continue;
      }

      try {
        typed.add(OfflineEntity.fromJson(map));
      } on FormatException catch (e) {
        findings.add(
          DataQualityFinding(
            ruleId: DataQualityRuleIds.unknownType,
            severity: DataQualitySeverity.error,
            entityId: id.isEmpty ? null : id,
            message: e.message,
            details: <String, dynamic>{'type': typeName},
          ),
        );
      }
    }

    _scanTypedEntities(typed, findings);

    return DataQualityReport(
      findings: List.unmodifiable(findings),
      scannedEntityCount: scanned,
      generatedAt: DateTime.now().toUtc(),
    );
  }

  void _scanTypedEntities(
    List<OfflineEntity> entities,
    List<DataQualityFinding> findings,
  ) {
    for (final entity in entities) {
      if (entity.id.trim().isEmpty) {
        findings.add(
          DataQualityFinding(
            ruleId: DataQualityRuleIds.emptyId,
            severity: DataQualitySeverity.error,
            entityType: entity.type,
            entityId: entity.id,
            message: 'Entity has empty or missing id',
          ),
        );
      }
    }

    final idsByType = _buildIdSets(entities);
    _checkSoftReferences(entities, idsByType, findings);
    _checkParentCycles(entities, findings);
    _checkPlanData(entities, idsByType, findings);
  }

  /// Non-deleted entity ids grouped by Drift type.
  Map<OfflineEntityType, Set<String>> _buildIdSets(
    List<OfflineEntity> entities,
  ) {
    final out = <OfflineEntityType, Set<String>>{
      for (final t in OfflineEntityType.values) t: <String>{},
    };
    for (final entity in entities) {
      if (entity.deleted) continue;
      final id = entity.id.trim();
      if (id.isEmpty) continue;
      out[entity.type]!.add(id);
    }
    return out;
  }

  Set<String> _idsForCatalog(
    String catalogId,
    Map<OfflineEntityType, Set<String>> idsByType,
  ) {
    final entry = DataCatalogRegistry.byCatalogId(catalogId);
    final driftType = entry?.driftType;
    if (driftType == null) return const <String>{};
    return idsByType[driftType] ?? const <String>{};
  }

  void _checkSoftReferences(
    List<OfflineEntity> entities,
    Map<OfflineEntityType, Set<String>> idsByType,
    List<DataQualityFinding> findings,
  ) {
    for (final entity in entities) {
      if (entity.deleted) continue;
      final catalog = DataCatalogRegistry.byDriftType(entity.type);
      if (catalog == null) continue;

      for (final ref in catalog.references) {
        if (!_isSimpleFieldPath(ref.fieldPath)) continue;
        _checkSimpleReference(
          entity: entity,
          ref: ref,
          targetIds: _idsForCatalog(ref.targetCatalogId, idsByType),
          findings: findings,
        );
      }
    }
  }

  /// True for payload-root fields like `customerId` / `parentId` (no nesting).
  bool _isSimpleFieldPath(String fieldPath) =>
      fieldPath.isNotEmpty &&
      !fieldPath.contains('.') &&
      !fieldPath.contains('[');

  void _checkSimpleReference({
    required OfflineEntity entity,
    required SoftReference ref,
    required Set<String> targetIds,
    required List<DataQualityFinding> findings,
  }) {
    final raw = entity.payload[ref.fieldPath];
    final value = raw?.toString().trim() ?? '';

    if (value.isEmpty) {
      if (!ref.optional) {
        findings.add(
          DataQualityFinding(
            ruleId: DataQualityRuleIds.orphanReference,
            severity: DataQualitySeverity.error,
            entityType: entity.type,
            entityId: entity.id,
            message:
                'Required soft reference ${ref.fieldPath} is missing or empty',
            details: <String, dynamic>{
              'fieldPath': ref.fieldPath,
              'targetCatalogId': ref.targetCatalogId,
            },
          ),
        );
      }
      return;
    }

    if (!targetIds.contains(value)) {
      findings.add(
        DataQualityFinding(
          ruleId: DataQualityRuleIds.orphanReference,
          severity: DataQualitySeverity.error,
          entityType: entity.type,
          entityId: entity.id,
          message:
              'Orphan ${ref.fieldPath}="$value" (no ${ref.targetCatalogId})',
          details: <String, dynamic>{
            'fieldPath': ref.fieldPath,
            'targetCatalogId': ref.targetCatalogId,
            'targetId': value,
          },
        ),
      );
    }
  }

  void _checkParentCycles(
    List<OfflineEntity> entities,
    List<DataQualityFinding> findings,
  ) {
    final parentOf = <String, String>{};
    for (final entity in entities) {
      if (entity.deleted || entity.type != OfflineEntityType.customExercise) {
        continue;
      }
      final id = entity.id.trim();
      if (id.isEmpty) continue;
      final parent = entity.payload['parentId']?.toString().trim() ?? '';
      if (parent.isNotEmpty) {
        parentOf[id] = parent;
      }
    }

    final liveIds = parentOf.keys.toSet();
    // Include targets that exist as custom exercises even without their own parent.
    for (final entity in entities) {
      if (entity.deleted || entity.type != OfflineEntityType.customExercise) {
        continue;
      }
      final id = entity.id.trim();
      if (id.isNotEmpty) liveIds.add(id);
    }

    final reported = <String>{};
    for (final startId in parentOf.keys) {
      final seen = <String>{};
      var current = startId;
      while (true) {
        if (!seen.add(current)) {
          // Cycle detected; report once per participating node from this walk.
          for (final id in seen) {
            if (!reported.add(id)) continue;
            findings.add(
              DataQualityFinding(
                ruleId: DataQualityRuleIds.parentCycle,
                severity: DataQualitySeverity.error,
                entityType: OfflineEntityType.customExercise,
                entityId: id,
                message: 'customExercise parentId cycle involving "$id"',
                details: <String, dynamic>{
                  'fieldPath': 'parentId',
                  'cycleMembers': seen.toList(growable: false),
                },
              ),
            );
          }
          break;
        }
        final parent = parentOf[current];
        if (parent == null || parent.isEmpty) break;
        if (!liveIds.contains(parent)) break; // orphan, not a cycle
        current = parent;
      }
    }
  }

  void _checkPlanData(
    List<OfflineEntity> entities,
    Map<OfflineEntityType, Set<String>> idsByType,
    List<DataQualityFinding> findings,
  ) {
    final customExerciseIds =
        idsByType[OfflineEntityType.customExercise] ?? const <String>{};
    final planDataEntry =
        DataCatalogRegistry.byCatalogId(DataCatalogRegistry.planData);
    final nestedRefs = planDataEntry?.references ?? const <SoftReference>[];

    for (final entity in entities) {
      if (entity.deleted || entity.type != OfflineEntityType.workoutPlan) {
        continue;
      }

      final rawPlanData = entity.payload['planData'];
      if (rawPlanData == null) {
        findings.add(
          DataQualityFinding(
            ruleId: DataQualityRuleIds.planDataDecode,
            severity: DataQualitySeverity.error,
            entityType: entity.type,
            entityId: entity.id,
            message: 'workoutPlan.planData is missing',
          ),
        );
        continue;
      }

      final jsonText = _planDataToJsonText(rawPlanData);
      if (jsonText == null) {
        findings.add(
          DataQualityFinding(
            ruleId: DataQualityRuleIds.planDataDecode,
            severity: DataQualitySeverity.error,
            entityType: entity.type,
            entityId: entity.id,
            message:
                'workoutPlan.planData has unsupported shape (${rawPlanData.runtimeType})',
          ),
        );
        continue;
      }

      final WorkoutRoutine routine;
      try {
        routine = decodeWorkoutRoutineJson(jsonText);
      } catch (e) {
        findings.add(
          DataQualityFinding(
            ruleId: DataQualityRuleIds.planDataDecode,
            severity: DataQualitySeverity.error,
            entityType: entity.type,
            entityId: entity.id,
            message: 'workoutPlan.planData decode failed: $e',
          ),
        );
        continue;
      }

      if (routine.weeks.isEmpty) {
        findings.add(
          DataQualityFinding(
            ruleId: DataQualityRuleIds.planDataEmptyWeeks,
            severity: DataQualitySeverity.warning,
            entityType: entity.type,
            entityId: entity.id,
            message: 'workoutPlan.planData decodes to a routine with empty weeks',
          ),
        );
      }

      if (nestedRefs.isEmpty) continue;
      _checkNestedCustomExerciseRefs(
        entity: entity,
        routine: routine,
        nestedRefs: nestedRefs,
        customExerciseIds: customExerciseIds,
        findings: findings,
      );
    }
  }

  String? _planDataToJsonText(Object rawPlanData) {
    if (rawPlanData is String) {
      return rawPlanData;
    }
    if (rawPlanData is Map) {
      return jsonEncode(rawPlanData);
    }
    return null;
  }

  void _checkNestedCustomExerciseRefs({
    required OfflineEntity entity,
    required WorkoutRoutine routine,
    required List<SoftReference> nestedRefs,
    required Set<String> customExerciseIds,
    required List<DataQualityFinding> findings,
  }) {
    final wantMobility = nestedRefs.any(
      (r) => r.fieldPath.contains('mobilityItems'),
    );
    final wantExercises = nestedRefs.any(
      (r) =>
          r.fieldPath.contains('exercises[]') &&
          !r.fieldPath.contains('sessionExecutions'),
    );
    final wantExecutions = nestedRefs.any(
      (r) => r.fieldPath.contains('sessionExecutions'),
    );

    if (wantMobility) {
      for (final item in routine.mobilityItems) {
        _reportOrphanCustomExerciseId(
          entity: entity,
          fieldPath: 'planData.mobilityItems[].customExerciseId',
          customExerciseId: item.customExerciseId,
          customExerciseIds: customExerciseIds,
          findings: findings,
        );
      }
    }

    if (wantExercises) {
      for (final week in routine.weeks) {
        for (final day in week.days) {
          for (final exercise in day.exercises) {
            _reportOrphanCustomExerciseId(
              entity: entity,
              fieldPath: 'planData.exercises[].customExerciseId',
              customExerciseId: exercise.customExerciseId,
              customExerciseIds: customExerciseIds,
              findings: findings,
            );
          }
        }
      }
    }

    if (wantExecutions) {
      for (final execution in routine.sessionExecutions.values) {
        for (final exercise in execution.exercises) {
          _reportOrphanCustomExerciseId(
            entity: entity,
            fieldPath:
                'planData.sessionExecutions[].exercises[].customExerciseId',
            customExerciseId: exercise.customExerciseId,
            customExerciseIds: customExerciseIds,
            findings: findings,
          );
        }
      }
    }
  }

  void _reportOrphanCustomExerciseId({
    required OfflineEntity entity,
    required String fieldPath,
    required String? customExerciseId,
    required Set<String> customExerciseIds,
    required List<DataQualityFinding> findings,
  }) {
    final id = customExerciseId?.trim() ?? '';
    if (id.isEmpty) return;
    if (customExerciseIds.contains(id)) return;
    findings.add(
      DataQualityFinding(
        ruleId: DataQualityRuleIds.orphanReference,
        severity: DataQualitySeverity.warning,
        entityType: entity.type,
        entityId: entity.id,
        message: 'Orphan customExerciseId="$id" in $fieldPath',
        details: <String, dynamic>{
          'fieldPath': fieldPath,
          'targetCatalogId': DataCatalogRegistry.customExercise,
          'targetId': id,
        },
      ),
    );
  }
}
