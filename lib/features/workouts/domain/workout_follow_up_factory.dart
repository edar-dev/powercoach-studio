import '../data/workout_routine_model.dart';

/// Builds a follow-up routine from an existing plan routine.
///
/// The returned routine keeps structure/content while resetting completion state
/// and assignment window markers for a new planning cycle.
WorkoutRoutine prepareFollowUpRoutine({
  required WorkoutRoutine source,
  DateTime? newStartDate,
}) {
  final cloned = WorkoutRoutine.fromJson(source.toJson());
  final resolvedStart = newStartDate != null
      ? DateTime(newStartDate.year, newStartDate.month, newStartDate.day)
      : cloned.startDate;

  return WorkoutRoutine(
    name: cloned.name,
    mobilitySections: cloned.mobilitySections,
    mobilityItems: cloned.mobilityItems,
    weeks: cloned.weeks,
    startDate: resolvedStart,
    endDate: null,
    currentWeek: 1,
    sessionCompletionByKey: const {},
    sessionSkippedByKey: const {},
  );
}
