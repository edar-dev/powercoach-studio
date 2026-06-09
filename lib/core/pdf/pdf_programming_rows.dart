import '../../features/workouts/data/workout_routine_model.dart';
import 'pdf_text_sanitize.dart';

/// One rendered row in the workout programming PDF table.
class PdfProgrammingSetRow {
  const PdfProgrammingSetRow({
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.load,
    required this.notes,
    this.isContinuation = false,
  });

  final String exercise;
  final String sets;
  final String reps;
  final String load;
  final String notes;
  final bool isContinuation;
}

List<PdfProgrammingSetRow> buildProgrammingSetRows(Exercise exercise) {
  final details = exercise.effectiveSetDetails;
  if (details.length > 1) {
    return details.asMap().entries.map((entry) {
      final index = entry.key;
      final set = entry.value;
      return PdfProgrammingSetRow(
        exercise: index == 0 ? exercise.name : '',
        sets: '${index + 1}',
        reps: _repsForSet(set),
        load: _loadForSet(set),
        notes: _notesForSet(set, exercise, index == 0),
        isContinuation: index > 0,
      );
    }).toList();
  }

  final set = details.first;
  if (_hasStructuredSet(set)) {
    return [
      PdfProgrammingSetRow(
        exercise: exercise.name,
        sets: _setsForSet(set, exercise),
        reps: _repsForSet(set, fallback: exercise.reps),
        load: _loadForSet(set, fallback: exercise.rpe),
        notes: _notesForSet(set, exercise, true),
      ),
    ];
  }

  return [
    PdfProgrammingSetRow(
      exercise: exercise.name,
      sets: exercise.sets,
      reps: exercise.reps,
      load: exercise.rpe,
      notes: exercise.note,
    ),
  ];
}

bool _hasStructuredSet(ExerciseSet set) {
  return set.sets.trim().isNotEmpty ||
      set.reps.trim().isNotEmpty ||
      set.rpe.trim().isNotEmpty ||
      set.line.trim().isNotEmpty;
}

String _setsForSet(ExerciseSet set, Exercise exercise) {
  final sets = set.sets.trim();
  if (sets.isNotEmpty && sets != '1') return sanitizePdfText(sets);
  final exerciseSets = exercise.sets.trim();
  if (exerciseSets.isNotEmpty) return sanitizePdfText(exerciseSets);
  return sets.isEmpty ? '' : sanitizePdfText(sets);
}

String _repsForSet(ExerciseSet set, {String fallback = ''}) {
  final reps = set.reps.trim();
  if (reps.isNotEmpty) return sanitizePdfText(reps);
  if (set.line.trim().isNotEmpty) return sanitizePdfText(set.line.trim());
  final display = set.displayText.trim();
  if (display.isNotEmpty && set.rpe.trim().isEmpty) {
    return sanitizePdfText(display);
  }
  return sanitizePdfText(fallback);
}

String _loadForSet(ExerciseSet set, {String fallback = ''}) {
  final load = set.rpe.trim();
  if (load.isNotEmpty) return sanitizePdfText(load);
  return sanitizePdfText(fallback);
}

String _notesForSet(ExerciseSet set, Exercise exercise, bool includeExerciseNote) {
  final setNote = set.note.trim();
  if (setNote.isNotEmpty) return sanitizePdfText(setNote);
  if (includeExerciseNote) return sanitizePdfText(exercise.note.trim());
  return '';
}
