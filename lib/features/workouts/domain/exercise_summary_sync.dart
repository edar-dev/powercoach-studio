import '../data/workout_routine_model.dart';

/// Keeps legacy [Exercise.sets]/[reps]/[rpe] summary fields aligned with [setDetails].
class ExerciseSummarySync {
  ExerciseSummarySync._();

  static Exercise apply(Exercise exercise) {
    final details = exercise.setDetails;
    if (details == null || details.isEmpty) return exercise;

    final displayParts = details
        .map((set) => set.displayText.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (displayParts.isEmpty) return exercise;

    return exercise.copyWith(
      sets: details.length.toString(),
      reps: displayParts.join(' | '),
      rpe: '',
    );
  }
}
