import '../data/workout_routine_model.dart';

/// Returns [routine] with [weeks] filtered to [weekIndices] (0-based).
///
/// - `null` or empty [weekIndices] → original routine (all weeks).
/// - Indices are clamped to valid range, de-duplicated, and sorted.
/// - If no valid indices remain, returns the original routine.
WorkoutRoutine filterRoutineWeeks(
  WorkoutRoutine routine,
  List<int>? weekIndices,
) {
  if (weekIndices == null || weekIndices.isEmpty) return routine;

  final weeks = routine.weeks;
  if (weeks.isEmpty) return routine;

  final valid = <int>{
    for (final i in weekIndices)
      if (i >= 0 && i < weeks.length) i,
  }.toList()
    ..sort();

  if (valid.isEmpty) return routine;

  return routine.copyWith(weeks: [for (final i in valid) weeks[i]]);
}
