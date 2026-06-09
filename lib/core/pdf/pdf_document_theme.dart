import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_coach_header.dart';
import 'pdf_export_labels.dart';
import 'pdf_text_sanitize.dart';

/// Shared visual system for PowerCoach Studio PDF exports (Stitch-aligned).
class PdfDocumentTheme {
  PdfDocumentTheme._();

  static const double pageMargin = 24;
  static const double headerMetaFontSize = 9;
  static const double titleFontSize = 20;
  static const double sectionFontSize = 13;
  static const double dayFontSize = 11;
  static const double tableFontSize = 9.5;
  static const double tableHeaderFontSize = 8.5;
  static const double compactTableFontSize = 8;
  static const double supersetFontSize = 9;
  static const double footerFontSize = 7.5;
  static const double cellPaddingH = 8;
  static const double cellPaddingV = 7;
  static const double compactCellPadding = 5;

  static final PdfColor accent = PdfColor.fromHex('#0D59F2');
  static final PdfColor textPrimary = PdfColor.fromHex('#1F2937');
  static final PdfColor textMuted = PdfColor.fromHex('#6B7280');
  static final PdfColor tableHeaderBg = PdfColor.fromHex('#F3F4F6');
  static final PdfColor tableRowAltBg = PdfColor.fromHex('#FAFBFC');
  static final PdfColor border = PdfColor.fromHex('#E5E7EB');
  static final PdfColor supersetBg = PdfColor.fromHex('#E8EEFE');
  static final PdfColor footerMuted = PdfColor.fromHex('#9CA3AF');

  static pw.Widget buildCoachHeaderBand(PdfCoachHeaderInfo info) {
    if (!info.hasContent) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: _metaCell(info.leftLine, align: pw.TextAlign.left)),
            if (info.centerLine != null)
              pw.Expanded(
                child: _metaCell(info.centerLine!, align: pw.TextAlign.center),
              ),
            if (info.rightLine != null)
              pw.Expanded(
                child: _metaCell(info.rightLine!, align: pw.TextAlign.right),
              ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Container(height: 2, color: accent),
        pw.SizedBox(height: 10),
      ],
    );
  }

  static pw.Widget buildDocumentTitle(String title) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(width: 4, height: 28, color: accent),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: titleFontSize,
              fontWeight: pw.FontWeight.bold,
              color: textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget buildSubtitle(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: headerMetaFontSize, color: textMuted),
      ),
    );
  }

  static pw.Widget sectionTitle(String text) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.SizedBox(height: 4),
        pw.Text(
          text.toUpperCase(),
          style: pw.TextStyle(
            fontSize: sectionFontSize,
            fontWeight: pw.FontWeight.bold,
            color: textPrimary,
            letterSpacing: 0.6,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Container(height: 1.5, color: textPrimary),
        pw.SizedBox(height: 10),
      ],
    );
  }

  static pw.Widget dayTitle(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(
        text.toUpperCase(),
        style: pw.TextStyle(
          fontSize: dayFontSize,
          fontWeight: pw.FontWeight.bold,
          color: textPrimary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  static pw.Widget buildPageFooter(
    pw.Context context,
    PdfExportLabels labels,
    DateTime generatedAt,
  ) {
    final dateStr = _formatDate(generatedAt);
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: border, width: 0.5)),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                labels.pageOf(context.pageNumber, context.pagesCount),
                style: pw.TextStyle(fontSize: footerFontSize, color: footerMuted),
              ),
              pw.Text(
                labels.generatedOn(dateStr),
                style: pw.TextStyle(fontSize: footerFontSize, color: footerMuted),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            labels.footerDisclaimer,
            style: pw.TextStyle(fontSize: footerFontSize, color: footerMuted),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  static pw.Widget tableCell(
    String text, {
    bool isHeader = false,
    bool isSuperset = false,
    bool center = false,
    bool blankIfEmpty = false,
    String emptyPlaceholder = '-',
    double fontSize = tableFontSize,
    double paddingH = cellPaddingH,
    double paddingV = cellPaddingV,
  }) {
    final sanitized = sanitizePdfText(text.trim());
    final display = sanitized.isEmpty
        ? (blankIfEmpty ? '' : emptyPlaceholder)
        : sanitized;
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
      child: pw.Align(
        alignment: center ? pw.Alignment.center : pw.Alignment.centerLeft,
        child: pw.Text(
          isHeader ? display.toUpperCase() : display,
          style: pw.TextStyle(
            fontSize: isHeader
                ? tableHeaderFontSize
                : (isSuperset ? supersetFontSize : fontSize),
            fontWeight: (isHeader || isSuperset) ? pw.FontWeight.bold : null,
            color: isHeader ? textMuted : textPrimary,
            letterSpacing: isHeader ? 0.3 : 0,
          ),
          textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
          maxLines: isHeader ? 2 : null,
        ),
      ),
    );
  }

  static pw.Widget compactCell(
    String text, {
    bool isHeader = false,
    PdfExportLabels? labels,
  }) {
    final empty = labels?.emptyValue ?? '-';
    final display = text.trim().isEmpty ? empty : text;
    return tableCell(
      display,
      isHeader: isHeader,
      fontSize: compactTableFontSize,
      paddingH: compactCellPadding,
      paddingV: compactCellPadding,
    );
  }

  static pw.TableRow programmingHeaderRow(PdfExportLabels labels) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: tableHeaderBg),
      children: [
        tableCell(labels.colExercise, isHeader: true),
        tableCell(labels.colSets, isHeader: true, center: true),
        tableCell(labels.colReps, isHeader: true, center: true),
        tableCell(labels.colLoadRpe, isHeader: true, center: true),
        tableCell(labels.colNotes, isHeader: true),
      ],
    );
  }

  static pw.Widget _metaCell(String text, {required pw.TextAlign align}) {
    return pw.Text(
      text.toUpperCase(),
      style: pw.TextStyle(
        fontSize: headerMetaFontSize,
        color: textMuted,
        letterSpacing: 0.5,
      ),
      textAlign: align,
    );
  }

  static String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$day/$m/$y';
  }
}
