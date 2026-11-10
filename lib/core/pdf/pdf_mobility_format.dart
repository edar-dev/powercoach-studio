import 'pdf_text_sanitize.dart';

/// One mobility line for PDF export.
///
/// Legacy: `Title` or `Title: subtitle`.
/// With structured prescription: `Title: 3×30s` or
/// `Title: 3×30s — note` when [prescriptionSummary] is non-empty.
String formatMobilityPdfLine(
  String title,
  String subtitle, {
  String prescriptionSummary = '',
}) {
  final cleanTitle = sanitizePdfText(title.trim());
  final cleanSubtitle = sanitizePdfText(subtitle.trim());
  final cleanRx = sanitizePdfText(prescriptionSummary.trim());
  if (cleanRx.isNotEmpty) {
    final head = '$cleanTitle: $cleanRx';
    if (cleanSubtitle.isEmpty) return head;
    // ASCII separator — Helvetica cannot reliably draw em dash.
    return '$head - $cleanSubtitle';
  }
  if (cleanSubtitle.isEmpty) return cleanTitle;
  return '$cleanTitle: $cleanSubtitle';
}
