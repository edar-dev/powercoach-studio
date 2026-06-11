import 'pdf_text_sanitize.dart';

/// Shortens coaching notes for dense PDF cells to reduce awkward line wraps.
String abbreviatePdfCoachingNote(String note) {
  var text = sanitizePdfText(note.trim());
  if (text.isEmpty) return text;

  text = text
      .replaceAll('Fermo incastro 2" + Fermo ginocchio', 'Fermo incastro 2" + ginocchio')
      .replaceAll('Femo incastro', 'Fermo incastro')
      .replaceAll('Fermo ginocchio', 'ginocchio')
      .replaceAll(RegExp(r'\s+'), ' ');

  return text;
}
