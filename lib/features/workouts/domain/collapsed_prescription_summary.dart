import '../data/workout_routine_model.dart';

/// Compact collapsed-row / day-preview prescription text (UI polish only).
///
/// Prefers structured `sets×reps` with a multiplication sign, normalizes
/// ASCII `x`/`X` between digits in free-form lines, and joins blocks with ` · `.
/// Does not change [ExerciseSet.displayText].
String collapsedPrescriptionSummary(Iterable<ExerciseSet> details) {
  final parts = <String>[];
  for (final set in details) {
    final part = _formatBlock(set);
    if (part.isNotEmpty) parts.add(part);
  }
  if (parts.isEmpty) return '';
  if (parts.length == 1 && RegExp(r'^\d+$').hasMatch(parts.first)) {
    return '';
  }
  return parts.join(' · ');
}

String _formatBlock(ExerciseSet set) {
  final line = set.line.trim();
  final setsRaw = set.sets.trim();
  final repsRaw = set.reps.trim();
  final load = set.rpe.trim();
  final setsParsed = int.tryParse(setsRaw);

  String scheme;
  if (line.isNotEmpty) {
    scheme = _normalizeTimes(line);
  } else if (setsParsed != null &&
      setsParsed > 0 &&
      repsRaw.isNotEmpty &&
      !_looksLikeScheme(repsRaw)) {
    scheme = '$setsParsed×$repsRaw';
  } else if (repsRaw.isNotEmpty) {
    scheme = _normalizeTimes(repsRaw);
  } else if (setsRaw.isNotEmpty) {
    scheme = setsRaw;
  } else {
    scheme = '';
  }

  if (scheme.isEmpty) {
    return load;
  }
  if (load.isEmpty) return scheme;
  return '$scheme $load';
}

bool _looksLikeScheme(String reps) {
  return RegExp(r'^\d+[xX×]').hasMatch(reps) || reps.contains('@');
}

/// Normalize ASCII `x`/`X` between digits to `×` (e.g. `3x5` → `3×5`).
String _normalizeTimes(String raw) {
  return raw.replaceAllMapped(
    RegExp(r'(\d)\s*[xX]\s*(\d)'),
    (m) => '${m[1]}×${m[2]}',
  );
}
