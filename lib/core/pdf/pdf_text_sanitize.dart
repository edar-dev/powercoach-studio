/// Normalizes text for PDF rendering with built-in Helvetica (ASCII-safe).
String sanitizePdfText(String text) {
  return text
      .replaceAll('\u2014', '-')
      .replaceAll('\u2013', '-')
      .replaceAll('\u2212', '-')
      .replaceAll('\u2018', "'")
      .replaceAll('\u2019', "'")
      .replaceAll('\u201C', '"')
      .replaceAll('\u201D', '"')
      .replaceAll('\u2026', '...')
      .replaceAll('\u00A0', ' ')
      .replaceAll('\u00D7', 'x')
      .replaceAll('×', 'x');
}
