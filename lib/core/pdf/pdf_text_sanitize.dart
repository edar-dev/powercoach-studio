/// Normalizes text for PDF rendering with built-in Helvetica (WinAnsi).
///
/// Replaces punctuation Helvetica cannot draw (tofu □) with ASCII-safe
/// equivalents — especially name↔cue separators coaches type as middle dots.
String sanitizePdfText(String text) {
  final normalized = text
      .replaceAll('\u2014', ' - ') // em dash
      .replaceAll('\u2013', ' - ') // en dash
      .replaceAll('\u2212', '-') // minus
      .replaceAll('\u2018', "'")
      .replaceAll('\u2019', "'")
      .replaceAll('\u201C', '"')
      .replaceAll('\u201D', '"')
      .replaceAll('\u2026', '...')
      // PDF parent/variant path joiner (in-app uses › / U+203A).
      // Map to ASCII " > " — not " - ", which is reserved for name↔cue.
      .replaceAll('\u203A', ' > ') // › single right-pointing angle quotation
      .replaceAll('›', ' > ')
      // Name ↔ cue / list separators that render as tofu in Helvetica.
      .replaceAll('\u00B7', ' - ') // middle dot ·
      .replaceAll('·', ' - ')
      .replaceAll('\u22C5', ' - ') // dot operator ⋅
      .replaceAll('\u2219', ' - ') // bullet operator ∙
      .replaceAll('\u2022', ' - ') // bullet •
      .replaceAll('\u25AA', ' - ') // black small square
      .replaceAll('\u25AB', ' - ') // white small square
      .replaceAll('\u25A0', ' - ') // black square
      .replaceAll('\u25A1', ' - ') // white square □
      .replaceAll('\u25CF', ' - ') // black circle
      .replaceAll('\u25E6', ' - ') // white bullet
      .replaceAll('\u30FB', ' - ') // katakana middle dot
      .replaceAll('\uFF65', ' - ') // halfwidth katakana middle dot
      .replaceAll('\u00A0', ' ')
      .replaceAll('\u00D7', 'x')
      .replaceAll('×', 'x')
      .replaceAll('\u3003', '"') // ditto mark
      .replaceAll(RegExp(r' +'), ' ')
      .trim();

  return _replaceNonWinAnsi(normalized);
}

/// Drops remaining code points Helvetica/WinAnsi cannot encode (→ tofu).
String _replaceNonWinAnsi(String text) {
  final buffer = StringBuffer();
  for (final unit in text.runes) {
    if (_isWinAnsiSafe(unit)) {
      buffer.writeCharCode(unit);
      continue;
    }
    // Prefer a readable separator when the glyph was likely punctuation.
    if (_looksLikeSeparator(unit)) {
      buffer.write(' - ');
    } else {
      buffer.write(' ');
    }
  }
  return buffer.toString().replaceAll(RegExp(r' +'), ' ').trim();
}

bool _isWinAnsiSafe(int unit) {
  if (unit == 0x09 || unit == 0x0A || unit == 0x0D) return true;
  if (unit >= 0x20 && unit <= 0x7E) return true;
  // Latin-1 supplement used by Italian copy (accented letters, etc.).
  if (unit >= 0xA0 && unit <= 0xFF) return true;
  // Common WinAnsi extras in the C1 range (euro, quotes, dashes already
  // normalized above — keep remaining mapped symbols if any slipped through).
  const winAnsiExtras = <int>{
    0x20AC, // euro — may still tofu; replace below if needed
  };
  return winAnsiExtras.contains(unit);
}

bool _looksLikeSeparator(int unit) {
  return unit == 0x22C5 ||
      unit == 0x2219 ||
      unit == 0x2022 ||
      unit == 0x00B7 ||
      unit == 0x25AA ||
      unit == 0x25AB ||
      unit == 0x25A0 ||
      unit == 0x25A1 ||
      unit == 0x25CF ||
      unit == 0x25E6 ||
      unit == 0x30FB ||
      unit == 0xFF65 ||
      unit == 0x2014 ||
      unit == 0x2013 ||
      unit == 0x2212;
}
