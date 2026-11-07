import '../data/workout_routine_model.dart';

/// Keeps legacy [Exercise.sets]/[reps]/[rpe] summary fields aligned with [setDetails].
class ExerciseSummarySync {
  ExerciseSummarySync._();

  /// Sum of block sizes across [details], matching [SessionDayMetrics] /
  /// day-card `_totalSets` (non-positive / unparseable → 1).
  static int totalSetsFromDetails(List<ExerciseSet> details) {
    var total = 0;
    for (final set in details) {
      final parsed = int.tryParse(set.sets.trim());
      total += (parsed == null || parsed <= 0) ? 1 : parsed;
    }
    return total;
  }

  static Exercise apply(Exercise exercise) {
    final details = exercise.setDetails;
    if (details == null || details.isEmpty) return exercise;

    final displayParts = details
        .map((set) => set.displayText.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (displayParts.isEmpty) return exercise;

    return exercise.copyWith(
      sets: totalSetsFromDetails(details).toString(),
      reps: displayParts.join(' | '),
      rpe: '',
    );
  }
}
