import 'pdf_text_sanitize.dart';

final RegExp _equipmentSuffix = RegExp(
  r'\s*\((Barbell|Dumbbell|Machine|Cable|Kettlebell|Smith Machine|Band)\)\s*$',
  caseSensitive: false,
);

/// Shortens exercise names for dense PDF tables by removing equipment suffixes.
String abbreviateExerciseNameForPdf(String name) {
  var shortened = sanitizePdfText(name.trim());
  while (_equipmentSuffix.hasMatch(shortened)) {
    shortened = shortened.replaceFirst(_equipmentSuffix, '').trim();
  }
  return shortened.isEmpty ? sanitizePdfText(name.trim()) : shortened;
}
