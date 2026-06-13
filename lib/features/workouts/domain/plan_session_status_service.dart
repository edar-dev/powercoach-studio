import '../../dashboard/domain/plan_calendar_event.dart';
import '../data/workout_plan_repository.dart';

/// Shared updater for plan session completion/skipped state.
class PlanSessionStatusService {
  PlanSessionStatusService({WorkoutPlanRepository? repository})
      : _repository = repository ?? WorkoutPlanRepository();

  final WorkoutPlanRepository _repository;

  Future<void> setSessionStatus({
    required String planId,
    required int weekIndex,
    required int dayIndex,
    required PlanSessionStatus status,
  }) async {
    await _repository.setSessionCompleted(
      planId: planId,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      completed: status == PlanSessionStatus.completed,
      skipped: status == PlanSessionStatus.skipped,
    );
  }
}
