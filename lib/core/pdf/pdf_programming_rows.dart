import '../../features/workouts/data/workout_routine_model.dart';
import 'pdf_coaching_note.dart';
import 'pdf_exercise_name.dart';
import 'pdf_text_sanitize.dart';

/// One rendered row in the workout programming PDF table.
class PdfProgrammingSetRow {
  const PdfProgrammingSetRow({
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.load,
    required this.notes,
    this.isGrouped = false,
    this.prescriptionOnly = false,
  });

  final String exercise;
  final String sets;
  final String reps;
  final String load;
  final String notes;
  final bool isGrouped;

  /// When true, [reps] holds the full prescription and sets/load stay blank.
  final bool prescriptionOnly;

  bool get isMultiline =>
      sets.contains('\n') || reps.contains('\n') || load.contains('\n');
}

List<PdfProgrammingSetRow> buildProgrammingSetRows(
  Exercise exercise, {
  bool dense = false,
}) {
  final details = exercise.effectiveSetDetails;
  if (details.length > 1) {
    final prescription = formatExercisePrescriptionCompact(
      exercise,
      singleLine: dense,
      includeExerciseNote: false,
    );
    if (dense) {
      return [
        PdfProgrammingSetRow(
          exercise: exercise.name,
          sets: '',
          reps: prescription,
          load: '',
          notes: sanitizePdfText(exercise.note.trim()),
          isGrouped: true,
          prescriptionOnly: true,
        ),
      ];
    }
    return [
      PdfProgrammingSetRow(
        exercise: exercise.name,
        sets: _joinLines(
          List.generate(details.length, (index) => '${index + 1}'),
        ),
        reps: _joinLines(details.map(_repsForSet)),
        load: _joinLines(details.map(_loadForSet)),
        notes: sanitizePdfText(exercise.note.trim()),
        isGrouped: true,
      ),
    ];
  }

  final set = details.first;
  if (_hasStructuredSet(set)) {
    if (dense) {
      return [
        PdfProgrammingSetRow(
          exercise: exercise.name,
          sets: '',
          reps: formatExercisePrescriptionCompact(
            exercise,
            singleLine: true,
            includeExerciseNote: false,
          ),
          load: '',
          notes: _notesForSet(set, exercise, true),
          prescriptionOnly: true,
        ),
      ];
    }
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

  if (dense) {
    return [
      PdfProgrammingSetRow(
        exercise: exercise.name,
        sets: '',
        reps: formatExercisePrescriptionCompact(
          exercise,
          singleLine: true,
          includeExerciseNote: false,
        ),
        load: '',
        notes: exercise.note,
        prescriptionOnly: true,
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

/// Compact human-readable prescription for PDF cells (dense layout).
String formatExercisePrescriptionCompact(
  Exercise e, {
  bool singleLine = false,
  bool includeExerciseNote = true,
}) {
  final details = e.effectiveSetDetails;
  final separator = singleLine ? ' · ' : '\n';

  if (details.length > 1) {
    return details
        .map((s) => _compactSetFragment(s, exercise: e))
        .where((x) => x.isNotEmpty)
        .join(separator);
  }

  if (details.isNotEmpty && details.first.displayText.isNotEmpty) {
    final n = includeExerciseNote ? e.note.trim() : '';
    final d0 = sanitizePdfText(details.first.displayText);
    return n.isEmpty ? d0 : '$d0 — ${sanitizePdfText(n)}';
  }

  final sets = e.sets.trim();
  final reps = e.reps.trim();
  final rpe = e.rpe.trim();
  final note = includeExerciseNote ? e.note.trim() : '';
  String line;
  if (sets.isNotEmpty && reps.isNotEmpty) {
    line = '${sets}x$reps${rpe.isNotEmpty ? ' $rpe' : ''}';
  } else {
    line = [reps, sets, rpe].where((x) => x.isNotEmpty).join(' ');
  }
  if (note.isNotEmpty) {
    line = line.isEmpty ? sanitizePdfText(note) : '$line — ${sanitizePdfText(note)}';
  }
  return sanitizePdfText(line);
}

String _compactSetFragment(ExerciseSet s, {required Exercise exercise}) {
  if (s.displayText.isNotEmpty) {
    final n = s.note.trim();
    final display = sanitizePdfText(s.displayText);
    return n.isEmpty ? display : '$display (${sanitizePdfText(n)})';
  }
  final sets = s.sets.trim();
  final reps = s.reps.trim();
  final load = s.rpe.trim();
  final n = s.note.trim();
  final core = sets.isNotEmpty && reps.isNotEmpty
      ? '${sets}x$reps${load.isNotEmpty ? ' $load' : ''}'
      : [sets, reps, load].where((x) => x.isNotEmpty).join(' ');
  if (core.isEmpty && n.isEmpty) return '';
  if (n.isEmpty) return core;
  return core.isEmpty ? sanitizePdfText(n) : '$core (${sanitizePdfText(n)})';
}

String _joinLines(Iterable<String> lines) {
  return lines
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .join('\n');
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

String formatBlockPrescriptionCompact(Object item, {bool singleLine = false}) {
  if (item is Exercise) {
    return formatExercisePrescriptionCompact(item, singleLine: singleLine);
  }
  final g = item as List<Exercise>;
  final separator = singleLine ? ' | ' : '\n';
  return g
      .map(
        (e) =>
            '${sanitizePdfText(e.name)}: ${formatExercisePrescriptionCompact(e, singleLine: singleLine)}',
      )
      .join(separator);
}

/// Prescription and coaching note split for dense PDF week cells.
class PdfDenseCellContent {
  const PdfDenseCellContent({
    required this.prescription,
    required this.note,
  });

  final String prescription;
  final String note;

  bool get isEmpty => prescription.trim().isEmpty && note.trim().isEmpty;

  String get signature => '${prescription.trim()}|${note.trim()}';
}

/// Arrow between pyramid tokens in dense PDF cells (`5@80 > 4@82.5`).
const densePyramidTokenSeparator = ' > ';

/// Short pyramids stay on one line; longer chains wrap in pairs for readability.
const densePyramidSingleLineMaxTokens = 4;
const densePyramidWrappedTokensPerLine = 2;

/// Compact arrow notation for dense PDF week cells (pyramids with controlled wraps).
String formatDenseTablePrescription(Exercise exercise) {
  final tokens = exercise.effectiveSetDetails
      .map(_compactDenseSetToken)
      .where((token) => token.isNotEmpty)
      .toList();
  if (tokens.isEmpty) return '';
  if (tokens.length == 1) return tokens.first;
  return _joinDensePyramidTokens(tokens);
}

String _joinDensePyramidTokens(List<String> tokens) {
  if (tokens.length <= densePyramidSingleLineMaxTokens) {
    return tokens.join(densePyramidTokenSeparator);
  }
  final lines = <String>[];
  for (var i = 0; i < tokens.length; i += densePyramidWrappedTokensPerLine) {
    final end = i + densePyramidWrappedTokensPerLine;
    final slice = tokens.sublist(i, end > tokens.length ? tokens.length : end);
    lines.add(slice.join(densePyramidTokenSeparator));
  }
  return lines.join('\n');
}

String _compactDenseSetToken(ExerciseSet set) {
  final display = set.displayText.trim();
  if (display.isNotEmpty) {
    return _compactFromDisplayText(sanitizePdfText(display));
  }
  final sets = set.sets.trim();
  final reps = set.reps.trim();
  final load = sanitizePdfText(set.rpe.trim());
  if (load.startsWith('@')) return load;
  if (sets.isNotEmpty && reps.isNotEmpty && load.isNotEmpty) {
    if (sets == '1') return '$reps@$load';
    return '${sets}x$reps $load';
  }
  if (reps.isNotEmpty && load.isNotEmpty) {
    return '$reps@$load';
  }
  return [sets, reps, load].where((part) => part.isNotEmpty).join(' ');
}

String _compactFromDisplayText(String display) {
  if (display.startsWith('@')) return display;

  final rpeSingle = RegExp(r'^1x1\s+(@\S+)$').firstMatch(display);
  if (rpeSingle != null) return rpeSingle.group(1)!;

  final oneSet = RegExp(r'^1x(\S+)\s+(.+)$').firstMatch(display);
  if (oneSet != null) {
    final load = oneSet.group(2)!;
    if (load.startsWith('@')) return load;
    return '${oneSet.group(1)}@$load';
  }

  final multi = RegExp(r'^(\d+)x(\S+)(?:\s+(.*))?$').firstMatch(display);
  if (multi != null) {
    final rest = multi.group(3)?.trim() ?? '';
    final core = '${multi.group(1)}x${multi.group(2)}';
    if (rest.isEmpty) return core;
    return '$core $rest';
  }

  return display;
}

/// Builds dense cell content for week columns (prescription only in cells).
PdfDenseCellContent formatDenseBlockContent(Object item) {
  if (item is Exercise) {
    return PdfDenseCellContent(
      prescription: formatDenseTablePrescription(item),
      note: extractExerciseNoteForDense(item),
    );
  }
  final group = item as List<Exercise>;
  final prescriptions = <String>[];
  final notes = <String>[];
  for (final exercise in group) {
    final content = formatDenseBlockContent(exercise);
    if (content.prescription.isNotEmpty) {
      prescriptions.add(
        '${abbreviateExerciseNameForPdf(exercise.name)}: ${content.prescription}',
      );
    }
    if (content.note.isNotEmpty) {
      notes.add(content.note);
    }
  }
  return PdfDenseCellContent(
    prescription: prescriptions.join('\n'),
    note: notes.toSet().join(' · '),
  );
}

String extractExerciseNoteForDense(Exercise exercise) {
  final notes = <String>{};
  final main = exercise.note.trim();
  if (main.isNotEmpty) {
    notes.add(abbreviatePdfCoachingNote(main));
  }
  for (final set in exercise.effectiveSetDetails) {
    final setNote = set.note.trim();
    if (setNote.isNotEmpty) {
      notes.add(abbreviatePdfCoachingNote(setNote));
    }
  }
  return notes.join(' · ');
}

/// Whether every populated week cell shares the same prescription text.
bool denseWeekPrescriptionsIdentical(List<PdfDenseCellContent?> contents) {
  final populated = contents
      .whereType<PdfDenseCellContent>()
      .where((cell) => cell.prescription.trim().isNotEmpty)
      .toList();
  if (populated.length < 2) return false;
  final signature = populated.first.prescription.trim();
  return populated.every((cell) => cell.prescription.trim() == signature);
}

/// Returns a coaching note when every populated week cell agrees.
String? resolveSharedDenseNote(List<PdfDenseCellContent?> contents) {
  final notes = contents
      .whereType<PdfDenseCellContent>()
      .map((cell) => cell.note.trim())
      .where((note) => note.isNotEmpty)
      .toList();
  if (notes.isEmpty) return null;
  final shared = notes.first;
  return notes.every((note) => note == shared) ? shared : null;
}
