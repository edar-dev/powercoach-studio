import '../data/workout_plan_repository.dart';
import '../data/workout_routine_model.dart';

class PlanSessionOverrideService {
  PlanSessionOverrideService({WorkoutPlanRepository? repository})
    : _repository = repository ?? WorkoutPlanRepository();

  final WorkoutPlanRepository _repository;

  Future<void> moveSessionOccurrence({
    required String planId,
    required int weekIndex,
    required int dayIndex,
    required DateTime originalDay,
    required DateTime movedToDate,
  }) async {
    await _repository.setSessionOccurrenceOverride(
      planId: planId,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      originalDay: originalDay,
      override: SessionOverride.moved(movedToDate),
    );
  }

  Future<void> skipSessionOccurrence({
    required String planId,
    required int weekIndex,
    required int dayIndex,
    required DateTime originalDay,
  }) async {
    await _repository.setSessionOccurrenceOverride(
      planId: planId,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      originalDay: originalDay,
      override: const SessionOverride.skipped(),
    );
  }

  Future<void> clearSessionOccurrenceOverride({
    required String planId,
    required int weekIndex,
    required int dayIndex,
    required DateTime originalDay,
  }) async {
    await _repository.removeSessionOccurrenceOverride(
      planId: planId,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      originalDay: originalDay,
    );
  }
}
