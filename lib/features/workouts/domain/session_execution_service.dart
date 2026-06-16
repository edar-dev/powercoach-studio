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

  /// All executions across plans, newest first.
  Future<List<SessionExecutionEntry>> listAll({
    List<WorkoutPlanApiModel>? plans,
  }) async {
    final allPlans = plans ?? await _repository.getAll();
    final entries = <SessionExecutionEntry>[];
    for (final plan in allPlans) {
      final executions = await listForPlan(plan.id);
      for (final execution in executions) {
        if (execution.status == PlanSessionStatus.planned) continue;
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

  Future<SessionExecution> upsertStatusStub({
    required String planId,
    required int weekIndex,
    required int dayIndex,
    required DateTime sessionDate,
    required PlanSessionStatus status,
    List<ExecutedExercise> exercises = const [],
    String notes = '',
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
