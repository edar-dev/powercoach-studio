import '../../dashboard/domain/plan_calendar_event.dart';
import '../data/workout_plan_repository.dart';
import 'session_execution.dart';
import 'session_execution_service.dart';

/// Shared updater for plan session completion/skipped state.
class PlanSessionStatusService {
  PlanSessionStatusService({
    WorkoutPlanRepository? repository,
    SessionExecutionService? executionService,
  }) : _repository = repository ?? WorkoutPlanRepository(),
       _executions = executionService ?? SessionExecutionService(repository: repository);

  final WorkoutPlanRepository _repository;
  final SessionExecutionService _executions;

  Future<void> setSessionStatus({
    required String planId,
    required int weekIndex,
    required int dayIndex,
    required PlanSessionStatus status,
    DateTime? sessionDate,
    List<ExecutedExercise> exercises = const [],
    String notes = '',
    int? sessionRpe,
    int? painLevel,
    String? painLocation,
  }) async {
    await _repository.setSessionCompleted(
      planId: planId,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      completed: status == PlanSessionStatus.completed,
      skipped: status == PlanSessionStatus.skipped,
    );

    final plan = await _repository.getById(planId);
    if (plan == null) return;
    final routine = planDataToRoutine(plan.planData);
    final resolvedDate =
        sessionDate ??
        (routine.startDate != null
            ? planSessionDate(
                startDate: routine.startDate!,
                weekIndex: weekIndex,
                dayIndex: dayIndex,
                scheduledWeekday: weekIndex < routine.weeks.length &&
                        dayIndex < routine.weeks[weekIndex].days.length
                    ? routine.weeks[weekIndex].days[dayIndex].scheduledWeekday
                    : null,
              )
            : DateTime.now());

    await _executions.upsertStatusStub(
      planId: planId,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      sessionDate: resolvedDate,
      status: status,
      exercises: exercises,
      notes: notes,
      sessionRpe: sessionRpe,
      painLevel: painLevel,
      painLocation: painLocation,
    );
  }
}
