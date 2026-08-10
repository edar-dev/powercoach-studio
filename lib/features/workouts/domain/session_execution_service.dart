import '../../dashboard/domain/plan_calendar_event.dart';
import '../data/workout_plan_api_model.dart';
import '../data/workout_plan_repository.dart';
import '../data/workout_routine_model.dart';
import 'session_execution.dart';

/// Reads and writes [SessionExecution] records stored in plan [planData].
class SessionExecutionService {
  SessionExecutionService({WorkoutPlanRepository? repository})
    : _repository = repository ?? WorkoutPlanRepository();

  final WorkoutPlanRepository _repository;

  Future<SessionExecution?> get({
    required String planId,
    required String sessionKey,
  }) => _repository.getSessionExecution(planId: planId, sessionKey: sessionKey);

  Future<void> save({
    required String planId,
    required SessionExecution execution,
  }) => _repository.upsertSessionExecution(
    planId: planId,
    execution: execution,
  );

  Future<void> remove({
    required String planId,
    required String sessionKey,
  }) => _repository.deleteSessionExecution(
    planId: planId,
    sessionKey: sessionKey,
  );

  Future<List<SessionExecution>> listForPlan(String planId) =>
      _repository.listSessionExecutionsForPlan(planId);

  /// Paginated diary entries across plans, newest first.
  Future<SessionExecutionListPage> listEntries({
    String? planId,
    String? customerId,
    String? sessionKey,
    int limit = 50,
    int offset = 0,
    List<WorkoutPlanApiModel>? plans,
  }) async {
    final allEntries = await _collectEntries(
      planId: planId,
      customerId: customerId,
      sessionKey: sessionKey,
      plans: plans,
    );
    final slice = allEntries.skip(offset).take(limit).toList();
    return SessionExecutionListPage(
      entries: slice,
      totalCount: allEntries.length,
      offset: offset,
      limit: limit,
      hasMore: offset + slice.length < allEntries.length,
    );
  }

  Future<List<SessionExecutionEntry>> _collectEntries({
    String? planId,
    String? customerId,
    String? sessionKey,
    List<WorkoutPlanApiModel>? plans,
  }) async {
    Iterable<WorkoutPlanApiModel> scopedPlans;
    if (plans != null) {
      scopedPlans = plans;
    } else if (planId != null && planId.isNotEmpty) {
      final plan = await _repository.getById(planId);
      scopedPlans = plan == null ? const [] : [plan];
    } else {
      scopedPlans = await _repository.getAll();
    }
    if (customerId != null && customerId.isNotEmpty) {
      scopedPlans = scopedPlans.where((p) => p.customerId == customerId);
    }

    final entries = <SessionExecutionEntry>[];
    for (final plan in scopedPlans) {
      final executions = await listForPlan(plan.id);
      for (final execution in executions) {
        if (execution.status == PlanSessionStatus.planned) continue;
        if (sessionKey != null &&
            sessionKey.isNotEmpty &&
            execution.sessionKey != sessionKey) {
          continue;
        }
        entries.add(
          SessionExecutionEntry(
            planId: plan.id,
            customerId: plan.customerId,
            planName: plan.name,
            execution: execution,
          ),
        );
      }
    }
    entries.sort((a, b) {
      final aDate = a.execution.completedAt ?? a.execution.sessionDate;
      final bDate = b.execution.completedAt ?? b.execution.sessionDate;
      return bDate.compareTo(aDate);
    });
    return entries;
  }

  /// Resolves a single diary entry without scanning all plans.
  Future<SessionExecutionEntry?> getEntry({
    required String planId,
    required String sessionKey,
  }) async {
    final plan = await _repository.getById(planId);
    if (plan == null) return null;
    final execution = await get(planId: planId, sessionKey: sessionKey);
    if (execution == null || execution.status == PlanSessionStatus.planned) {
      return null;
    }
    return SessionExecutionEntry(
      planId: plan.id,
      customerId: plan.customerId,
      planName: plan.name,
      execution: execution,
    );
  }

  /// All executions across plans, newest first.
  Future<List<SessionExecutionEntry>> listAll({
    List<WorkoutPlanApiModel>? plans,
  }) async {
    return _collectEntries(plans: plans);
  }

  Future<SessionExecution> upsertStatusStub({
    required String planId,
    required int weekIndex,
    required int dayIndex,
    required DateTime sessionDate,
    required PlanSessionStatus status,
    List<ExecutedExercise> exercises = const [],
    String notes = '',
    int? sessionRpe,
    int? painLevel,
    String? painLocation,
  }) async {
    final sessionKey = WorkoutRoutine.sessionKey(weekIndex, dayIndex);
    if (status == PlanSessionStatus.planned) {
      await remove(planId: planId, sessionKey: sessionKey);
      return SessionExecution(
        sessionKey: sessionKey,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        sessionDate: sessionDate,
        status: status,
      );
    }
    final execution = SessionExecution(
      sessionKey: sessionKey,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      sessionDate: sessionDate,
      status: status,
      completedAt: DateTime.now(),
      notes: notes,
      exercises: exercises,
      sessionRpe: sessionRpe,
      painLevel: painLevel,
      painLocation: painLocation,
    );
    await save(planId: planId, execution: execution);
    return execution;
  }

  double? adherenceRateForPlan(
    WorkoutPlanApiModel plan, {
    DateTime? from,
    DateTime? to,
  }) {
    final routine = planDataToRoutine(plan.planData);
    final executions = routine.sessionExecutions.values
        .where((e) => e.status != PlanSessionStatus.planned)
        .toList();
    if (executions.isEmpty) return null;

    final start = from ?? DateTime(2000);
    final end = to ?? DateTime(2100);
    final inRange = executions.where((e) {
      final d = e.sessionDate;
      return !d.isBefore(DateTime(start.year, start.month, start.day)) &&
          !d.isAfter(DateTime(end.year, end.month, end.day));
    }).toList();
    if (inRange.isEmpty) return null;

    final completed = inRange
        .where((e) => e.status == PlanSessionStatus.completed)
        .length;
    return completed / inRange.length;
  }
}

class SessionExecutionEntry {
  const SessionExecutionEntry({
    required this.planId,
    required this.customerId,
    required this.planName,
    required this.execution,
  });

  final String planId;
  final String customerId;
  final String planName;
  final SessionExecution execution;
}

class SessionExecutionListPage {
  const SessionExecutionListPage({
    required this.entries,
    required this.totalCount,
    required this.offset,
    required this.limit,
    required this.hasMore,
  });

  final List<SessionExecutionEntry> entries;
  final int totalCount;
  final int offset;
  final int limit;
  final bool hasMore;
}
