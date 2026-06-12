import '../../features/workouts/data/workout_routine_model.dart';
import 'pdf_text_sanitize.dart';

final RegExp _equipmentSuffix = RegExp(
  r'\s*\((Barbell|Dumbbell|Machine|Cable|Kettlebell|Smith Machine|Band)\)\s*$',
  caseSensitive: false,
);

const Map<String, String> _knownAbbreviations = {
  'Seated Cable Row - V Grip': 'Cable Row (V)',
  'Seated Overhead Press': 'OHP DB',
  'Lat Pulldown': 'Lat Pulldown',
  'Incline Bench Press': 'Incline DB',
  'Single Arm Cable Row': '1-Arm Row',
  'Triceps Rope Pushdown': 'Triceps Pushdown',
  'Bulgarian Split Squat': 'Bulgarian Split',
  'Cable Pull Through': 'Pull Through',
  'Single Leg Hip Thrust': 'SL Hip Thrust',
  'Skullcrusher': 'Skullcrusher',
  'Chest Press': 'Chest Press',
  'Leg Extension': 'Leg Extension',
  'Leg Press': 'Leg Press',
};

/// Resolves the exercise label for PDF export (persisted short name wins).
String resolveExerciseDisplayNameForPdf(Exercise exercise) {
  final short = exercise.shortName.trim();
  if (short.isNotEmpty) return sanitizePdfText(short);
  return abbreviateExerciseNameForPdf(exercise.name);
}

/// Shortens exercise names for dense PDF tables by removing equipment suffixes.
String abbreviateExerciseNameForPdf(String name) {
  final sanitized = sanitizePdfText(name.trim());
  var shortened = sanitized;
  while (_equipmentSuffix.hasMatch(shortened)) {
    shortened = shortened.replaceFirst(_equipmentSuffix, '').trim();
  }
  final known = _knownAbbreviations[shortened];
  if (known != null) return known;
  return shortened.isEmpty ? sanitized : shortened;
}
