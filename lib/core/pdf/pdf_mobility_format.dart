import 'pdf_text_sanitize.dart';

/// One mobility line for PDF export (`Title` or `Title: subtitle`).
String formatMobilityPdfLine(String title, String subtitle) {
  final cleanTitle = sanitizePdfText(title.trim());
  final cleanSubtitle = sanitizePdfText(subtitle.trim());
  if (cleanSubtitle.isEmpty) return cleanTitle;
  return '$cleanTitle: $cleanSubtitle';
}
