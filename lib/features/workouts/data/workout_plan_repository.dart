import 'package:flutter/foundation.dart';

import '../../../core/constants/workout_plan_template_scope.dart';
import '../../../core/remote/coach_entities_remote.dart';
import '../../../core/sync/offline_models.dart';
import '../../../core/sync/offline_repository_support.dart';
import '../domain/session_execution.dart';
import '../domain/workout_follow_up_factory.dart';
import '../domain/workout_plan_query_helpers.dart';
import '../domain/workout_routine_plan_encoder.dart';
import '../../dashboard/domain/plan_calendar_event.dart';
import 'workout_plan_api_model.dart';
import 'workout_routine_model.dart';

export '../domain/workout_plan_query_helpers.dart' show planDataToRoutine;

/// Persists workout plans in local storage.
class WorkoutPlanRepository {
  WorkoutPlanRepository({OfflineRepositorySupport? offline})
    : _offline = offline ??
          OfflineRepositorySupport(remote: CoachEntitiesRemote());

  final OfflineRepositorySupport _offline;

  static bool _templatePurgeDone = false;

  /// Reset one-shot template purge gate between tests.
  @visibleForTesting
  static void resetTemplatePurgeForTest() {
    _templatePurgeDone = false;
  }

  /// One-shot DELETE of leftover template-scoped workout plans (`__template__`).
  ///
  /// Data policy: stop writing template scope; keep excluding it from [getAll];
  /// purge orphans rather than converting them to customer plans (no safe target).
  Future<void> ensureTemplateScopedPlansPurged() async {
    if (_templatePurgeDone) return;

    final byScope = await _offline.readLocalEntities(
      OfflineEntityType.workoutPlan,
      scopeId: kWorkoutPlanTemplateScopeId,
    );
    final all = await _offline.readLocalEntities(OfflineEntityType.workoutPlan);
    final toDelete = <String>{};
    for (final entity in [...byScope, ...all]) {
      final id = entity['id']?.toString();
      if (id == null || id.isEmpty) continue;
      if (entity['customerId']?.toString() == kWorkoutPlanTemplateScopeId) {
        toDelete.add(id);
      }
    }
    for (final id in toDelete) {
      await _offline.markDeleted(OfflineEntityType.workoutPlan, id);
    }
    _templatePurgeDone = true;
  }

  Future<void> _ensureReady() => ensureTemplateScopedPlansPurged();

  void _rejectTemplateScope(String customerId) {
    if (customerId == kWorkoutPlanTemplateScopeId) {
      throw ArgumentError.value(
        customerId,
        'customerId',
        'template scope is no longer supported',
      );
    }
  }

  /// All workout plans **except** leftover template scope ([kWorkoutPlanTemplateScopeId]).
  Future<List<WorkoutPlanApiModel>> getAll() async {
    await _ensureReady();
    final local = await _offline.readLocalEntities(
      OfflineEntityType.workoutPlan,
    );
    // Defensive: keep excluding `__template__` even after purge.
    return mapAndSortWorkoutPlans(local, excludeTemplateScope: true);
  }

  Future<List<WorkoutPlanApiModel>> getByCustomerId(String customerId) async {
    await _ensureReady();
    _rejectTemplateScope(customerId);
    final local = await _offline.readLocalEntities(
      OfflineEntityType.workoutPlan,
      scopeId: customerId,
    );
    return mapAndSortWorkoutPlans(local);
  }

  Future<WorkoutPlanApiModel?> getById(String planId) async {
    await _ensureReady();
    final local = await _offline.readLocalEntityById(
      OfflineEntityType.workoutPlan,
      planId,
    );
    if (local == null) return null;
    final plan = WorkoutPlanApiModel.fromJson(local);
    if (plan.customerId == kWorkoutPlanTemplateScopeId) return null;
    return plan;
  }

  Future<WorkoutPlanApiModel> create({
    required String customerId,
    required String name,
    required WorkoutRoutine routine,
    String? pdfHeader,
    bool useCustomPdfHeader = false,
    String? theme,
    int initialWeekNumber = 1,
    String? phase,
    String? tags,
    String? notes,
  }) async {
    await _ensureReady();
    _rejectTemplateScope(customerId);
    final tempId = _offline.newTempId('workout');
    final now = DateTime.now();
    final body = <String, dynamic>{
      'customerId': customerId,
      'name': name,
      'planData': buildWorkoutRoutinePlanData(routine),
      'useCustomPdfHeader': useCustomPdfHeader,
      'initialWeekNumber': initialWeekNumber,
    };
    if (pdfHeader != null) body['pdfHeader'] = pdfHeader;
    if (theme != null) body['theme'] = theme;
    if (phase != null) body['phase'] = phase;
    if (tags != null) body['tags'] = tags;
    if (notes != null) body['notes'] = notes;
    _writeScheduleMarkersToPayload(body, routine);

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
    WorkoutRoutine? routine,
    String? pdfHeader,
    bool? useCustomPdfHeader,
    String? theme,
    int? initialWeekNumber,
    String? phase,
    String? tags,
    String? notes,
  }) async {
    final current = await _offline.readLocalEntityById(
      OfflineEntityType.workoutPlan,
      planId,
    );
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (routine != null) {
      body['planData'] = buildWorkoutRoutinePlanData(
        routine,
        existingPlanData: current?['planData'],
      );
      if (current != null) {
        // Promote legacy nested markers first so a partial routine cannot drop
        // schedule/lifecycle that only lived in planData or top-level.
        _promoteAllMarkersToPayload(
          body,
          WorkoutPlanApiModel.fromJson(current),
        );
      }
      // Non-null routine schedule overwrites promoted values.
      _writeScheduleMarkersToPayload(body, routine);
    }
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

  /// Persists a planData [Map] without round-tripping through [WorkoutRoutine]
  /// (used by session map patches).
  ///
  /// Strips plan-level markers from the blob and promotes any legacy nested
  /// markers onto the entity top level so they are not lost.
  Future<WorkoutPlanApiModel> _updatePlanDataMap(
    String planId,
    Map<String, dynamic> planData,
  ) async {
    final current = await _offline.readLocalEntityById(
      OfflineEntityType.workoutPlan,
      planId,
    );
    final plan = current == null
        ? null
        : WorkoutPlanApiModel.fromJson(current);
    stripPlanLevelMarkersFromPlanData(planData);
    final patch = <String, dynamic>{'planData': planData};
    if (plan != null) {
      _promoteAllMarkersToPayload(patch, plan);
    }
    return _updatePayload(planId, patch);
  }

  Future<WorkoutPlanApiModel> _updatePayload(
    String planId,
    Map<String, dynamic> patch, {
    Iterable<String> removeKeys = const <String>[],
  }) async {
    final current = await _offline.readLocalEntityById(
      OfflineEntityType.workoutPlan,
      planId,
    );
    final merged = <String, dynamic>{
      ...?current,
      ...patch,
      'id': planId,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    for (final key in removeKeys) {
      merged.remove(key);
    }
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

  /// Writes schedule markers as top-level payload fields from [routine].
  void _writeScheduleMarkersToPayload(
    Map<String, dynamic> payload,
    WorkoutRoutine routine,
  ) {
    if (routine.startDate != null) {
      payload['startDate'] = dateOnlyIso(routine.startDate!);
    }
    if (routine.endDate != null) {
      payload['endDate'] = dateOnlyIso(routine.endDate!);
    }
    if (routine.currentWeek != null) {
      payload['currentWeek'] = routine.currentWeek;
    }
  }

  /// Copies all plan-level markers from a normalized [plan] onto [payload].
  void _promoteAllMarkersToPayload(
    Map<String, dynamic> payload,
    WorkoutPlanApiModel plan,
  ) {
    if (plan.archivedAt != null) {
      payload.putIfAbsent('archivedAt', () => dateOnlyIso(plan.archivedAt!));
    }
    if (plan.completedAt != null) {
      payload.putIfAbsent('completedAt', () => dateOnlyIso(plan.completedAt!));
    }
    if (plan.startDate != null) {
      payload.putIfAbsent('startDate', () => dateOnlyIso(plan.startDate!));
    }
    if (plan.endDate != null) {
      payload.putIfAbsent('endDate', () => dateOnlyIso(plan.endDate!));
    }
    if (plan.currentWeek != null) {
      payload.putIfAbsent('currentWeek', () => plan.currentWeek);
    }
  }

  Future<void> delete(String planId) async {
    await _offline.markDeleted(OfflineEntityType.workoutPlan, planId);
  }

  /// Copies [sourcePlanId] into a **new** plan for [customerId] (new id, deep-copied `planData`).
  Future<WorkoutPlanApiModel> duplicateToCustomer({
    required String sourcePlanId,
    required String customerId,
    String? name,
  }) async {
    _rejectTemplateScope(customerId);
    final src = await getById(sourcePlanId);
    if (src == null) {
      throw StateError('workout_plan_not_found');
    }
    // Prefer typed routine (hydrates top-level schedule). Clone helper strips
    // any legacy plan-level markers still nested in planData.
    final routine = planDataToRoutine(cloneWorkoutPlanDataJson(src.planData));
    final withSchedule = routine.copyWith(
      startDate: src.startDate,
      endDate: src.endDate,
      currentWeek: src.currentWeek,
    );
    final resolvedName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : src.name;
    return create(
      customerId: customerId,
      name: resolvedName,
      routine: withSchedule,
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
    bool applyExecutedLoads = false,
  }) async {
    final src = await getById(sourcePlanId);
    if (src == null) {
      throw StateError('workout_plan_not_found');
    }
    final sourceRoutine = src.routine;
    final executions = applyExecutedLoads
        ? await listSessionExecutionsForPlan(sourcePlanId)
        : const <SessionExecution>[];
    final followUpRoutine = prepareFollowUpRoutine(
      source: sourceRoutine,
      newStartDate: newStartDate,
      executions: executions,
      options: FollowUpOptions(applyExecutedLoads: applyExecutedLoads),
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
      routine: followUpRoutine,
      pdfHeader: src.pdfHeader,
      useCustomPdfHeader: src.useCustomPdfHeader,
      theme: src.theme,
      initialWeekNumber: src.initialWeekNumber + numWeeks,
      phase: src.phase,
      tags: src.tags,
      notes: src.notes,
    );
  }

  /// Updates assignment markers as top-level workoutPlan payload fields.
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
    final effectiveStart = startDate ?? plan.startDate;
    if (endDate != null) {
      if (effectiveStart != null &&
          dateOnly(endDate).isBefore(dateOnly(effectiveStart))) {
        throw ArgumentError.value(
          endDate,
          'endDate',
          'must be on or after startDate',
        );
      }
    }
    if (currentWeek != null && currentWeek < 1) {
      throw ArgumentError.value(currentWeek, 'currentWeek', 'must be >= 1');
    }

    final planData = Map<String, dynamic>.from(plan.planDataMap);
    stripPlanLevelMarkersFromPlanData(planData);
    final patch = <String, dynamic>{'planData': planData};
    if (startDate != null) patch['startDate'] = dateOnlyIso(startDate);
    if (endDate != null) patch['endDate'] = dateOnlyIso(endDate);
    if (currentWeek != null) patch['currentWeek'] = currentWeek;
    return _updatePayload(planId, patch);
  }

  /// Updates lifecycle markers as top-level workoutPlan payload fields.
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
    final planData = Map<String, dynamic>.from(plan.planDataMap);
    stripPlanLevelMarkersFromPlanData(planData);
    final patch = <String, dynamic>{'planData': planData};
    final removeKeys = <String>[];
    if (clearArchivedAt) {
      removeKeys.add('archivedAt');
    } else if (archivedAt != null) {
      patch['archivedAt'] = dateOnlyIso(archivedAt);
    }
    if (clearCompletedAt) {
      removeKeys.add('completedAt');
    } else if (completedAt != null) {
      patch['completedAt'] = dateOnlyIso(completedAt);
    }
    return _updatePayload(planId, patch, removeKeys: removeKeys);
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
    final routine = plan.routine;
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
    final map = Map<String, dynamic>.from(plan.planDataMap);
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
    return _updatePlanDataMap(planId, map);
  }

  Future<WorkoutPlanApiModel> setSessionOccurrenceOverride({
    required String planId,
    required int weekIndex,
    required int dayIndex,
    required DateTime originalDay,
    required SessionOverride override,
  }) async {
    final plan = await getById(planId);
    if (plan == null) {
      throw StateError('workout_plan_not_found');
    }
    final map = Map<String, dynamic>.from(plan.planDataMap);
    final overridesRaw = map['sessionOverrides'];
    final overrides = overridesRaw is Map<String, dynamic>
        ? Map<String, dynamic>.from(overridesRaw)
        : <String, dynamic>{};
    final key = sessionOccurrenceKey(
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      originalDay: originalDay,
    );
    overrides[key] = override.toJson();
    map['sessionOverrides'] = overrides;
    return _updatePlanDataMap(planId, map);
  }

  Future<WorkoutPlanApiModel> removeSessionOccurrenceOverride({
    required String planId,
    required int weekIndex,
    required int dayIndex,
    required DateTime originalDay,
  }) async {
    final plan = await getById(planId);
    if (plan == null) {
      throw StateError('workout_plan_not_found');
    }
    final map = Map<String, dynamic>.from(plan.planDataMap);
    final overridesRaw = map['sessionOverrides'];
    if (overridesRaw is! Map) {
      return plan;
    }
    final overrides = Map<String, dynamic>.from(overridesRaw);
    final key = sessionOccurrenceKey(
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      originalDay: originalDay,
    );
    overrides.remove(key);
    if (overrides.isEmpty) {
      map.remove('sessionOverrides');
    } else {
      map['sessionOverrides'] = overrides;
    }
    return _updatePlanDataMap(planId, map);
  }

  Future<SessionExecution?> getSessionExecution({
    required String planId,
    required String sessionKey,
  }) async {
    final plan = await getById(planId);
    if (plan == null) return null;
    final routine = plan.routine;
    return routine.sessionExecutions[sessionKey];
  }

  Future<List<SessionExecution>> listSessionExecutionsForPlan(
    String planId,
  ) async {
    final plan = await getById(planId);
    if (plan == null) return const [];
    final routine = plan.routine;
    return sortSessionExecutionsNewestFirst(routine.sessionExecutions.values);
  }

  Future<WorkoutPlanApiModel> upsertSessionExecution({
    required String planId,
    required SessionExecution execution,
  }) async {
    final plan = await getById(planId);
    if (plan == null) {
      throw StateError('workout_plan_not_found');
    }
    final map = Map<String, dynamic>.from(plan.planDataMap);
    final raw = map['sessionExecutions'];
    final executions = raw is Map<String, dynamic>
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};
    executions[execution.sessionKey] = execution.toJson();
    map['sessionExecutions'] = executions;
    return _updatePlanDataMap(planId, map);
  }

  Future<WorkoutPlanApiModel> deleteSessionExecution({
    required String planId,
    required String sessionKey,
  }) async {
    final plan = await getById(planId);
    if (plan == null) {
      throw StateError('workout_plan_not_found');
    }
    final map = Map<String, dynamic>.from(plan.planDataMap);
    final raw = map['sessionExecutions'];
    if (raw is! Map) return plan;
    final executions = Map<String, dynamic>.from(raw);
    executions.remove(sessionKey);
    if (executions.isEmpty) {
      map.remove('sessionExecutions');
    } else {
      map['sessionExecutions'] = executions;
    }
    return _updatePlanDataMap(planId, map);
  }
}
