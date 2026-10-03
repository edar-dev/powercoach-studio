import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/data_quality/data_quality.dart';
import 'package:powercoach_studio/core/sync/offline_models.dart';

void main() {
  const scanner = DataQualityScanner();
  final now = DateTime.utc(2026, 3, 15);

  OfflineEntity entity({
    required String id,
    required OfflineEntityType type,
    String scopeId = 'user-1',
    Map<String, dynamic>? payload,
    bool deleted = false,
  }) {
    return OfflineEntity(
      id: id,
      type: type,
      scopeId: scopeId,
      payload: payload ?? <String, dynamic>{'id': id},
      updatedAt: now,
      deleted: deleted,
    );
  }

  String planDataJson({
    List<Map<String, dynamic>>? weeks,
    List<Map<String, dynamic>>? mobilityItems,
    Map<String, dynamic>? sessionExecutions,
  }) {
    return jsonEncode(<String, dynamic>{
      'name': 'Test plan',
      'includesMobilityTab': false,
      'mobilityItems': mobilityItems ?? const <Map<String, dynamic>>[],
      'weeks': weeks ??
          [
            <String, dynamic>{
              'id': 'w1',
              'name': 'Week 1',
              'days': [
                <String, dynamic>{
                  'id': 'd1',
                  'name': 'Day 1',
                  'exercises': [
                    <String, dynamic>{
                      'id': 'ex1',
                      'name': 'Squat',
                      'customExerciseId': 'lib-squat',
                    },
                  ],
                },
              ],
            },
          ],
      if (sessionExecutions != null) 'sessionExecutions': sessionExecutions,
    });
  }

  group('happy path', () {
    test('connected customer → plan / measurement / note graph is clean', () {
      final entities = <OfflineEntity>[
        entity(
          id: 'cust-1',
          type: OfflineEntityType.customer,
          payload: <String, dynamic>{'id': 'cust-1', 'name': 'Ada'},
        ),
        entity(
          id: 'plan-1',
          type: OfflineEntityType.workoutPlan,
          scopeId: 'cust-1',
          payload: <String, dynamic>{
            'id': 'plan-1',
            'customerId': 'cust-1',
            'planData': planDataJson(),
          },
        ),
        entity(
          id: 'meas-1',
          type: OfflineEntityType.measurement,
          scopeId: 'cust-1',
          payload: <String, dynamic>{
            'id': 'meas-1',
            'customerId': 'cust-1',
          },
        ),
        entity(
          id: 'note-1',
          type: OfflineEntityType.customerNote,
          scopeId: 'cust-1',
          payload: <String, dynamic>{
            'id': 'note-1',
            'customerId': 'cust-1',
            'body': 'hi',
          },
        ),
        entity(
          id: 'lib-squat',
          type: OfflineEntityType.customExercise,
          scopeId: 'library',
          payload: <String, dynamic>{
            'id': 'lib-squat',
            'name': 'Squat',
            'parentId': 'lib-folder',
          },
        ),
        entity(
          id: 'lib-folder',
          type: OfflineEntityType.customExercise,
          scopeId: 'library',
          payload: <String, dynamic>{
            'id': 'lib-folder',
            'name': 'Legs',
          },
        ),
      ];

      final report = scanner.scanEntities(entities);

      expect(report.scannedEntityCount, 6);
      expect(report.findings, isEmpty);
      expect(report.hasErrors, isFalse);
    });
  });

  group('empty / missing ids', () {
    test('reports empty_id', () {
      final report = scanner.scanEntities([
        entity(id: '', type: OfflineEntityType.customer),
        entity(id: '  ', type: OfflineEntityType.customer),
      ]);

      final emptyIds = report.findings
          .where((f) => f.ruleId == DataQualityRuleIds.emptyId)
          .toList();
      expect(emptyIds.length, 2);
      expect(
        emptyIds.every((f) => f.severity == DataQualitySeverity.error),
        isTrue,
      );
    });
  });

  group('orphan soft references (registry-driven)', () {
    test('orphan customerId on workoutPlan / measurement / note', () {
      final entities = <OfflineEntity>[
        entity(
          id: 'plan-orphan',
          type: OfflineEntityType.workoutPlan,
          scopeId: 'missing-cust',
          payload: <String, dynamic>{
            'id': 'plan-orphan',
            'customerId': 'missing-cust',
            'planData': planDataJson(weeks: const []),
          },
        ),
        entity(
          id: 'meas-orphan',
          type: OfflineEntityType.measurement,
          scopeId: 'missing-cust',
          payload: <String, dynamic>{
            'id': 'meas-orphan',
            'customerId': 'missing-cust',
          },
        ),
        entity(
          id: 'note-orphan',
          type: OfflineEntityType.customerNote,
          scopeId: 'missing-cust',
          payload: <String, dynamic>{
            'id': 'note-orphan',
            'customerId': 'missing-cust',
            'body': 'x',
          },
        ),
      ];

      final report = scanner.scanEntities(entities);
      final orphans = report.findings
          .where((f) => f.ruleId == DataQualityRuleIds.orphanReference)
          .toList();

      expect(orphans.length, greaterThanOrEqualTo(3));
      expect(
        orphans.map((f) => f.entityId).toSet(),
        containsAll(<String>['plan-orphan', 'meas-orphan', 'note-orphan']),
      );
      expect(
        orphans.every((f) => f.details?['fieldPath'] == 'customerId'),
        isTrue,
      );
    });

    test('missing required customerId is reported', () {
      final report = scanner.scanEntities([
        entity(
          id: 'plan-1',
          type: OfflineEntityType.workoutPlan,
          payload: <String, dynamic>{
            'id': 'plan-1',
            'planData': planDataJson(weeks: const []),
          },
        ),
      ]);

      expect(
        report.findings.any(
          (f) =>
              f.ruleId == DataQualityRuleIds.orphanReference &&
              f.entityId == 'plan-1' &&
              f.details?['fieldPath'] == 'customerId',
        ),
        isTrue,
      );
    });

    test('orphan parentId on customExercise', () {
      final report = scanner.scanEntities([
        entity(
          id: 'lib-child',
          type: OfflineEntityType.customExercise,
          scopeId: 'library',
          payload: <String, dynamic>{
            'id': 'lib-child',
            'name': 'Child',
            'parentId': 'missing-parent',
          },
        ),
      ]);

      expect(
        report.findings.any(
          (f) =>
              f.ruleId == DataQualityRuleIds.orphanReference &&
              f.details?['fieldPath'] == 'parentId' &&
              f.details?['targetId'] == 'missing-parent',
        ),
        isTrue,
      );
    });

    test('optional empty parentId is allowed', () {
      final report = scanner.scanEntities([
        entity(
          id: 'lib-root',
          type: OfflineEntityType.customExercise,
          scopeId: 'library',
          payload: <String, dynamic>{'id': 'lib-root', 'name': 'Root'},
        ),
      ]);

      expect(
        report.findings.where(
          (f) => f.ruleId == DataQualityRuleIds.orphanReference,
        ),
        isEmpty,
      );
    });

    test('orphan nested customExerciseId in planData', () {
      final report = scanner.scanEntities([
        entity(
          id: 'cust-1',
          type: OfflineEntityType.customer,
        ),
        entity(
          id: 'plan-1',
          type: OfflineEntityType.workoutPlan,
          scopeId: 'cust-1',
          payload: <String, dynamic>{
            'id': 'plan-1',
            'customerId': 'cust-1',
            'planData': planDataJson(
              mobilityItems: [
                <String, dynamic>{
                  'id': 'm1',
                  'title': 'Stretch',
                  'sectionId': 'sec_upper',
                  'customExerciseId': 'ghost-lib',
                },
              ],
            ),
          },
        ),
      ]);

      expect(
        report.findings.any(
          (f) =>
              f.ruleId == DataQualityRuleIds.orphanReference &&
              f.details?['targetId'] == 'ghost-lib',
        ),
        isTrue,
      );
    });
  });

  group('parentId cycles', () {
    test('detects A → B → A cycle', () {
      final report = scanner.scanEntities([
        entity(
          id: 'a',
          type: OfflineEntityType.customExercise,
          scopeId: 'library',
          payload: <String, dynamic>{
            'id': 'a',
            'name': 'A',
            'parentId': 'b',
          },
        ),
        entity(
          id: 'b',
          type: OfflineEntityType.customExercise,
          scopeId: 'library',
          payload: <String, dynamic>{
            'id': 'b',
            'name': 'B',
            'parentId': 'a',
          },
        ),
      ]);

      final cycles = report.findings
          .where((f) => f.ruleId == DataQualityRuleIds.parentCycle)
          .toList();
      expect(cycles, isNotEmpty);
      expect(cycles.map((f) => f.entityId).toSet(), containsAll({'a', 'b'}));
    });
  });

  group('planData', () {
    test('decode failure', () {
      final report = scanner.scanEntities([
        entity(
          id: 'cust-1',
          type: OfflineEntityType.customer,
        ),
        entity(
          id: 'plan-bad',
          type: OfflineEntityType.workoutPlan,
          scopeId: 'cust-1',
          payload: <String, dynamic>{
            'id': 'plan-bad',
            'customerId': 'cust-1',
            'planData': 'not-json{',
          },
        ),
      ]);

      expect(
        report.findings.any(
          (f) =>
              f.ruleId == DataQualityRuleIds.planDataDecode &&
              f.entityId == 'plan-bad',
        ),
        isTrue,
      );
    });

    test('empty weeks', () {
      final report = scanner.scanEntities([
        entity(
          id: 'cust-1',
          type: OfflineEntityType.customer,
        ),
        entity(
          id: 'plan-empty',
          type: OfflineEntityType.workoutPlan,
          scopeId: 'cust-1',
          payload: <String, dynamic>{
            'id': 'plan-empty',
            'customerId': 'cust-1',
            'planData': planDataJson(weeks: const []),
          },
        ),
      ]);

      expect(
        report.findings.any(
          (f) =>
              f.ruleId == DataQualityRuleIds.planDataEmptyWeeks &&
              f.severity == DataQualitySeverity.warning &&
              f.entityId == 'plan-empty',
        ),
        isTrue,
      );
    });
  });

  group('backup JSON', () {
    test('unknown / mismatched type strings', () {
      final report = scanner.scanBackupJson(<String, dynamic>{
        'schemaVersion': 1,
        'exportFormat': 'powercoach_user_backup_v1',
        'entities': [
          <String, dynamic>{
            'id': 'legacy-1',
            'type': 'exerciseRecord',
            'scopeId': 'cust-1',
            'payload': <String, dynamic>{},
            'updatedAt': now.toIso8601String(),
            'deleted': false,
          },
          <String, dynamic>{
            'id': 'typo-1',
            'type': 'workOutPlan',
            'scopeId': 'cust-1',
            'payload': <String, dynamic>{},
            'updatedAt': now.toIso8601String(),
            'deleted': false,
          },
        ],
      });

      final mismatches = report.findings.where(
        (f) =>
            f.ruleId == DataQualityRuleIds.backupTypeMismatch ||
            f.ruleId == DataQualityRuleIds.unknownType,
      );
      expect(mismatches.length, 2);
      expect(report.scannedEntityCount, 2);
    });

    test('happy backup with known types is clean', () {
      final report = scanner.scanBackupJson(<String, dynamic>{
        'entities': [
          <String, dynamic>{
            'id': 'cust-1',
            'type': 'customer',
            'scopeId': 'user-1',
            'payload': <String, dynamic>{'id': 'cust-1', 'name': 'Ada'},
            'updatedAt': now.toIso8601String(),
            'deleted': false,
            'localOnly': false,
          },
          <String, dynamic>{
            'id': 'lib-1',
            'type': 'customExercise',
            'scopeId': 'library',
            'payload': <String, dynamic>{'id': 'lib-1', 'name': 'Bench'},
            'updatedAt': now.toIso8601String(),
            'deleted': false,
          },
          <String, dynamic>{
            'id': 'plan-1',
            'type': 'workoutPlan',
            'scopeId': 'cust-1',
            'payload': <String, dynamic>{
              'id': 'plan-1',
              'customerId': 'cust-1',
              'planData': planDataJson(
                weeks: [
                  <String, dynamic>{
                    'id': 'w1',
                    'name': 'W1',
                    'days': [
                      <String, dynamic>{
                        'id': 'd1',
                        'name': 'D1',
                        'exercises': [
                          <String, dynamic>{
                            'id': 'e1',
                            'name': 'Bench',
                            'customExerciseId': 'lib-1',
                          },
                        ],
                      },
                    ],
                  },
                ],
              ),
            },
            'updatedAt': now.toIso8601String(),
            'deleted': false,
          },
        ],
      });

      expect(report.findings, isEmpty);
      expect(report.scannedEntityCount, 3);
    });

    test('empty id in backup row', () {
      final report = scanner.scanBackupJson(<String, dynamic>{
        'entities': [
          <String, dynamic>{
            'id': '',
            'type': 'customer',
            'scopeId': 'user-1',
            'payload': <String, dynamic>{},
            'updatedAt': now.toIso8601String(),
          },
        ],
      });

      expect(
        report.findings.any((f) => f.ruleId == DataQualityRuleIds.emptyId),
        isTrue,
      );
    });
  });

  group('report model', () {
    test('toJson / toMarkdown are stable shapes', () {
      final report = scanner.scanEntities([
        entity(id: '', type: OfflineEntityType.customer),
      ]);
      final json = report.toJson();
      expect(json['scannedEntityCount'], 1);
      expect(json['findings'], isA<List<dynamic>>());
      expect(report.toMarkdown(), contains('Data quality report'));
      expect(report.toMarkdown(), contains(DataQualityRuleIds.emptyId));
    });
  });
}
