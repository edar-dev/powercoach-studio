import 'dart:convert';

import '../../../core/constants/workout_plan_template_scope.dart';
import '../../../core/sync/offline_models.dart';
import '../../../core/sync/offline_repository_support.dart';
import 'workout_plan_api_model.dart';
import 'workout_routine_model.dart';
import '../domain/workout_follow_up_factory.dart';

/// Persists workout plans in local storage.
class WorkoutPlanRepository {
  WorkoutPlanRepository({OfflineRepositorySupport? offline})
    : _offline = offline ?? OfflineRepositorySupport();

  final OfflineRepositorySupport _offline;

  /// All workout plans **except** templates ([kWorkoutPlanTemplateScopeId]).
  Future<List<WorkoutPlanApiModel>> getAll() async {
    final local = await _offline.readLocalEntities(
      OfflineEntityType.workoutPlan,
    );
    final models = local
        .map(WorkoutPlanApiModel.fromJson)
        .where((p) => p.customerId != kWorkoutPlanTemplateScopeId)
        .toList();
    _sortPlansByStartDateDesc(models);
    return models;
  }

  /// Reusable templates (sentinel [kWorkoutPlanTemplateScopeId] as `customerId` / scope).
  Future<List<WorkoutPlanApiModel>> listTemplates() async {
    final local = await _offline.readLocalEntities(
      OfflineEntityType.workoutPlan,
      scopeId: kWorkoutPlanTemplateScopeId,
    );
    final models = local.map(WorkoutPlanApiModel.fromJson).toList();
    _sortPlansByStartDateDesc(models);
    return models;
  }

  Future<List<WorkoutPlanApiModel>> getByCustomerId(String customerId) async {
    final local = await _offline.readLocalEntities(
      OfflineEntityType.workoutPlan,
      scopeId: customerId,
    );
    final models = local.map(WorkoutPlanApiModel.fromJson).toList();
    _sortPlansByStartDateDesc(models);
    return models;
  }

  Future<WorkoutPlanApiModel?> getById(String planId) async {
    final local = await _offline.readLocalEntityById(
      OfflineEntityType.workoutPlan,
      planId,
    );
    if (local == null) return null;
    return WorkoutPlanApiModel.fromJson(local);
  }

  Future<WorkoutPlanApiModel> create({
    required String customerId,
    required String name,
    required String planDataJson,
    String? pdfHeader,
    bool useCustomPdfHeader = false,
    String? theme,
    int initialWeekNumber = 1,
    String? phase,
    String? tags,
    String? notes,
  }) async {
    final tempId = _offline.newTempId('workout');
    final now = DateTime.now();
    final body = <String, dynamic>{
      'customerId': customerId,
      'name': name,
      'planData': planDataJson,
      'useCustomPdfHeader': useCustomPdfHeader,
      'initialWeekNumber': initialWeekNumber,
    };
    if (pdfHeader != null) body['pdfHeader'] = pdfHeader;
    if (theme != null) body['theme'] = theme;
    if (phase != null) body['phase'] = phase;
    if (tags != null) body['tags'] = tags;
    if (notes != null) body['notes'] = notes;

    final localPayload = <String, dynamic>{
      'id': tempId,
      'customerId': customerId,
      'userId': '',
      ...body,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'rowVersion': 1,
    };
    await _offline.saveLocalEntity(
      type: OfflineEntityType.workoutPlan,
      id: tempId,
      scopeId: customerId,
      payload: localPayload,
      localOnly: false,
    );
    return WorkoutPlanApiModel.fromJson(localPayload);
  }

  Future<WorkoutPlanApiModel> update({
    required String planId,
    String? name,
    String? planDataJson,
    String? pdfHeader,
    bool? useCustomPdfHeader,
    String? theme,
    int? initialWeekNumber,
    String? phase,
    String? tags,
    String? notes,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (planDataJson != null) body['planData'] = planDataJson;
    if (pdfHeader != null) body['pdfHeader'] = pdfHeader;
    if (useCustomPdfHeader != null) {
      body['useCustomPdfHeader'] = useCustomPdfHeader;
    }
    if (theme != null) body['theme'] = theme;
    if (initialWeekNumber != null) {
      body['initialWeekNumber'] = initialWeekNumber;
    }
    if (phase != null) body['phase'] = phase;
    if (tags != null) body['tags'] = tags;
    if (notes != null) body['notes'] = notes;

    final current = await _offline.readLocalEntityById(
      OfflineEntityType.workoutPlan,
      planId,
    );
    final merged = <String, dynamic>{
      ...?current,
      ...body,
      'id': planId,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await _offline.saveLocalEntity(
      type: OfflineEntityType.workoutPlan,
      id: planId,
      scopeId:
          merged['customerId']?.toString() ??
          current?['customerId']?.toString() ??
          '',
      payload: merged,
      localOnly: false,
    );
    return WorkoutPlanApiModel.fromJson(merged);
  }

  Future<void> delete(String planId) async {
    await _offline.markDeleted(OfflineEntityType.workoutPlan, planId);
  }

  /// Creates a new template (no real customer).
  Future<WorkoutPlanApiModel> createTemplate({
    required String name,
    required String planDataJson,
    String? pdfHeader,
    bool useCustomPdfHeader = false,
    String? theme,
    int initialWeekNumber = 1,
    String? phase,
    String? tags,
    String? notes,
  }) {
    return create(
      customerId: kWorkoutPlanTemplateScopeId,
      name: name,
      planDataJson: planDataJson,
      pdfHeader: pdfHeader,
      useCustomPdfHeader: useCustomPdfHeader,
      theme: theme,
      initialWeekNumber: initialWeekNumber,
      phase: phase,
      tags: tags,
      notes: notes,
    );
  }

  /// Deep-copies an existing plan (any customer or template) into a new template.
  Future<WorkoutPlanApiModel> createTemplateFromPlan({
    required String sourcePlanId,
    required String templateName,
  }) async {
    final src = await getById(sourcePlanId);
    if (src == null) {
      throw StateError('workout_plan_not_found');
    }
    final planDataCopy = _cloneWorkoutPlanDataJson(src.planData);
    return createTemplate(
      name: templateName.trim().isEmpty ? src.name : templateName.trim(),
      planDataJson: planDataCopy,
      pdfHeader: src.pdfHeader,
      useCustomPdfHeader: src.useCustomPdfHeader,
      theme: src.theme,
      initialWeekNumber: src.initialWeekNumber,
      phase: src.phase,
      tags: src.tags,
      notes: src.notes,
    );
  }

  /// Copies [sourcePlanId] into a **new** plan for [customerId] (new id, deep-copied `planData`).
  Future<WorkoutPlanApiModel> duplicateToCustomer({
    required String sourcePlanId,
    required String customerId,
    String? name,
  }) async {
    if (customerId == kWorkoutPlanTemplateScopeId) {
      throw ArgumentError.value(
        customerId,
        'customerId',
        'Use createTemplateFromPlan for template scope',
      );
    }
    final src = await getById(sourcePlanId);
    if (src == null) {
      throw StateError('workout_plan_not_found');
    }
    final planDataCopy = _cloneWorkoutPlanDataJson(src.planData);
    final resolvedName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : src.name;
    return create(
      customerId: customerId,
      name: resolvedName,
      planDataJson: planDataCopy,
      pdfHeader: src.pdfHeader,
      useCustomPdfHeader: src.useCustomPdfHeader,
      theme: src.theme,
      initialWeekNumber: src.initialWeekNumber,
      phase: src.phase,
      tags: src.tags,
      notes: src.notes,
    );
  }

  /// Creates a follow-up plan from an existing one for the same customer.
  ///
  /// - Deep-clones and resets progress/session maps.
  /// - Bumps [initialWeekNumber] by source routine length.
  /// - Optionally sets a new routine [startDate].
  Future<WorkoutPlanApiModel> createFollowUpFromPlan({
    required String sourcePlanId,
    String? name,
    DateTime? newStartDate,
  }) async {
    final src = await getById(sourcePlanId);
    if (src == null) {
      throw StateError('workout_plan_not_found');
    }
    final sourceRoutine = planDataToRoutine(src.planData);
    final followUpRoutine = prepareFollowUpRoutine(
      source: sourceRoutine,
      newStartDate: newStartDate,
    );
    final numWeeks = sourceRoutine.weeks.isEmpty
        ? 1
        : sourceRoutine.weeks.length;
    final resolvedName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : src.name;
    return create(
      customerId: src.customerId,
      name: resolvedName,
      planDataJson: jsonEncode(followUpRoutine.toJson()),
      pdfHeader: src.pdfHeader,
      useCustomPdfHeader: src.useCustomPdfHeader,
      theme: src.theme,
      initialWeekNumber: src.initialWeekNumber + numWeeks,
      phase: src.phase,
      tags: src.tags,
      notes: src.notes,
    );
  }

  /// Updates assignment markers stored inside [planData] JSON.
  Future<WorkoutPlanApiModel> updateScheduleMarkers({
    required String planId,
    DateTime? startDate,
    DateTime? endDate,
    int? currentWeek,
  }) async {
    final plan = await getById(planId);
    if (plan == null) {
      throw StateError('workout_plan_not_found');
    }
    final map = jsonDecode(plan.planData) as Map<String, dynamic>;
    DateTime? effectiveStart = startDate;
    final existingStart = map['startDate'];
    if (effectiveStart == null && existingStart != null) {
      effectiveStart = DateTime.tryParse(existingStart.toString());
    }
    if (startDate != null) {
      map['startDate'] = _dateOnlyIso(startDate);
    }
    if (endDate != null) {
      if (effectiveStart != null &&
          _dateOnly(endDate).isBefore(_dateOnly(effectiveStart))) {
        throw ArgumentError.value(
          endDate,
          'endDate',
          'must be on or after startDate',
        );
      }
      map['endDate'] = _dateOnlyIso(endDate);
    }
    if (currentWeek != null) {
      if (currentWeek < 1) {
        throw ArgumentError.value(currentWeek, 'currentWeek', 'must be >= 1');
      }
      map['currentWeek'] = currentWeek;
    }
    return update(planId: planId, planDataJson: jsonEncode(map));
  }

  Future<WorkoutPlanApiModel> updateLifecycleMarkers({
    required String planId,
    DateTime? archivedAt,
    DateTime? completedAt,
    bool clearArchivedAt = false,
    bool clearCompletedAt = false,
  }) async {
    final plan = await getById(planId);
    if (plan == null) {
      throw StateError('workout_plan_not_found');
    }
    final map = jsonDecode(plan.planData) as Map<String, dynamic>;
    if (clearArchivedAt) {
      map.remove('archivedAt');
    } else if (archivedAt != null) {
      map['archivedAt'] = _dateOnlyIso(archivedAt);
    }
    if (clearCompletedAt) {
      map.remove('completedAt');
    } else if (completedAt != null) {
      map['completedAt'] = _dateOnlyIso(completedAt);
    }
    return update(planId: planId, planDataJson: jsonEncode(map));
  }

  Future<WorkoutPlanApiModel> archivePlan(String planId) {
    return updateLifecycleMarkers(planId: planId, archivedAt: DateTime.now());
  }

  Future<WorkoutPlanApiModel> unarchivePlan(String planId) {
    return updateLifecycleMarkers(planId: planId, clearArchivedAt: true);
  }

  Future<WorkoutPlanApiModel> markPlanCompleted(
    String planId, {
    DateTime? completedAt,
  }) {
    return updateLifecycleMarkers(
      planId: planId,
      completedAt: completedAt ?? DateTime.now(),
    );
  }

  /// Persists completion/skip flags for a week/day slot inside [planData].
  Future<WorkoutPlanApiModel> setSessionCompleted({
    required String planId,
    required int weekIndex,
    required int dayIndex,
    required bool completed,
    bool skipped = false,
  }) async {
    if (weekIndex < 0 || dayIndex < 0) {
      throw ArgumentError('weekIndex and dayIndex must be non-negative');
    }
    final plan = await getById(planId);
    if (plan == null) {
      throw StateError('workout_plan_not_found');
    }
    final routine = planDataToRoutine(plan.planData);
    final key = WorkoutRoutine.sessionKey(weekIndex, dayIndex);
    final completion = Map<String, bool>.from(routine.sessionCompletionByKey);
    final skippedByKey = Map<String, bool>.from(routine.sessionSkippedByKey);
    if (skipped && !completed) {
      skippedByKey[key] = true;
      completion.remove(key);
    } else if (completed) {
      completion[key] = true;
      skippedByKey.remove(key);
    } else {
      completion.remove(key);
      skippedByKey.remove(key);
    }
    final map = jsonDecode(plan.planData) as Map<String, dynamic>;
    if (completion.isEmpty) {
      map.remove('sessionCompletionByKey');
    } else {
      map['sessionCompletionByKey'] = completion;
    }
    if (skippedByKey.isEmpty) {
      map.remove('sessionSkippedByKey');
    } else {
      map['sessionSkippedByKey'] = skippedByKey;
    }
    return update(planId: planId, planDataJson: jsonEncode(map));
  }
}

/// Sort key: routine `startDate` from [WorkoutPlanApiModel.planData], else [WorkoutPlanApiModel.updatedAt].
DateTime _sortKeyForPlan(WorkoutPlanApiModel p) {
  try {
    final decoded = jsonDecode(p.planData);
    if (decoded is Map<String, dynamic>) {
      final sd = decoded['startDate'];
      if (sd != null) {
        final d = DateTime.tryParse(sd.toString());
        if (d != null) {
          return DateTime(d.year, d.month, d.day);
        }
      }
    }
  } catch (_) {}
  return p.updatedAt;
}

void _sortPlansByStartDateDesc(List<WorkoutPlanApiModel> plans) {
  plans.sort((a, b) => _sortKeyForPlan(b).compareTo(_sortKeyForPlan(a)));
}

/// Deep-clone [planData] JSON string; throws [FormatException] if not valid JSON.
String _cloneWorkoutPlanDataJson(String planData) {
  try {
    final decoded = jsonDecode(planData);
    if (decoded is Map<String, dynamic>) {
      decoded.remove('archivedAt');
      decoded.remove('completedAt');
      return jsonEncode(decoded);
    }
    return jsonEncode(decoded);
  } catch (_) {
    throw FormatException('invalid_workout_plan_data');
  }
}

/// Parses [WorkoutPlanApiModel.planData] into [WorkoutRoutine].
WorkoutRoutine planDataToRoutine(String planDataJson) {
  final map = jsonDecode(planDataJson) as Map<String, dynamic>;
  return WorkoutRoutine.fromJson(map);
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

String _dateOnlyIso(DateTime value) {
  final day = _dateOnly(value);
  return day.toIso8601String();
}
