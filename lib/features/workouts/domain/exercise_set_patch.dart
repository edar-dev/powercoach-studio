import '../data/workout_routine_model.dart';

/// Whether a set row carries any coach-facing prescription content.
bool exerciseSetHasContent(ExerciseSet set) {
  return set.line.trim().isNotEmpty ||
      set.reps.trim().isNotEmpty ||
      set.rpe.trim().isNotEmpty ||
      set.note.trim().isNotEmpty ||
      (set.sets.trim().isNotEmpty && set.sets.trim() != '1');
}

/// True when any row in [details] has content (not just empty seed rows).
bool exerciseSetDetailsAreMeaningful(List<ExerciseSet>? details) {
  if (details == null || details.isEmpty) return false;
  return details.any(exerciseSetHasContent);
}

/// Applies a set-table edit to [current] (shared by training + mobility).
ExerciseSet patchExerciseSet(
  ExerciseSet current, {
  String? line,
  String? sets,
  String? reps,
  String? rpe,
  String? note,
}) {
  if (line != null) {
    final trimmed = line.trim();
    if (trimmed.isNotEmpty) {
      return ExerciseSet(
        line: trimmed,
        sets: '1',
        reps: '',
        rpe: '',
        note: note ?? current.note,
      );
    }
    return current.copyWith(note: note ?? current.note);
  }
  if (sets != null || reps != null || rpe != null) {
    return ExerciseSet(
      line: '',
      sets: sets ?? current.sets,
      reps: reps ?? current.reps,
      rpe: rpe ?? current.rpe,
      note: note ?? current.note,
    );
  }
  return current.copyWith(note: note ?? current.note);
}

/// Patches [setIndex] inside a copy of [details], or returns null if OOB.
List<ExerciseSet>? patchExerciseSetAt(
  List<ExerciseSet> details,
  int setIndex, {
  String? line,
  String? sets,
  String? reps,
  String? rpe,
  String? note,
}) {
  if (setIndex < 0 || setIndex >= details.length) return null;
  final next = List<ExerciseSet>.from(details);
  next[setIndex] = patchExerciseSet(
    details[setIndex],
    line: line,
    sets: sets,
    reps: reps,
    rpe: rpe,
    note: note,
  );
  return next;
}
