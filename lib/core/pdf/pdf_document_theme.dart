import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_coach_header.dart';
import 'pdf_export_labels.dart';
import 'pdf_text_sanitize.dart';

/// Shared visual system for PowerCoach Studio PDF exports (Stitch-aligned).
class PdfDocumentTheme {
  PdfDocumentTheme._();

  static const double pageMargin = 24;
  static const double densePageMargin = 18;
  static const double headerMetaFontSize = 9;
  static const double titleFontSize = 20;
  static const double denseTitleFontSize = 16;
  static const double sectionFontSize = 13;
  static const double denseSectionFontSize = 11;
  static const double dayFontSize = 11;
  static const double denseDayFontSize = 9.5;
  static const double tableFontSize = 8.5;
  static const double denseTableFontSize = 7.5;
  static const double tableHeaderFontSize = 7.5;
  static const double compactTableFontSize = 7.5;
  static const double denseCompactTableFontSize = 7;
  static const double supersetFontSize = 8;
  static const double denseSupersetFontSize = 7;
  static const double footerFontSize = 7.5;
  static const double denseFooterFontSize = 7;
  static const double cellPaddingH = 6;
  static const double cellPaddingV = 4;
  static const double denseCellPaddingH = 4;
  static const double denseCellPaddingV = 2.5;
  static const double compactCellPadding = 4;
  static const double denseCompactCellPadding = 3;

  static double pageMarginFor({required bool dense}) =>
      dense ? densePageMargin : pageMargin;

  static final PdfColor accent = PdfColor.fromHex('#0D59F2');
  static final PdfColor textPrimary = PdfColor.fromHex('#1F2937');
  static final PdfColor textMuted = PdfColor.fromHex('#6B7280');
  static final PdfColor tableHeaderBg = PdfColor.fromHex('#F3F4F6');
  static final PdfColor tableRowAltBg = PdfColor.fromHex('#FAFBFC');
  static final PdfColor exerciseGroupBg = PdfColor.fromHex('#F8FAFC');
  static final PdfColor border = PdfColor.fromHex('#E5E7EB');
  static final PdfColor borderStrong = PdfColor.fromHex('#D1D5DB');
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

  static pw.Widget buildDocumentTitle(String title, {bool dense = false}) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          width: dense ? 3 : 4,
          height: dense ? 22 : 28,
          color: accent,
        ),
        pw.SizedBox(width: dense ? 8 : 10),
        pw.Expanded(
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: dense ? denseTitleFontSize : titleFontSize,
              fontWeight: pw.FontWeight.bold,
              color: textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget buildRunningHeader(
    String title,
    pw.Context context,
    PdfExportLabels labels,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 5),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: border, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: denseFooterFontSize + 1,
                fontWeight: pw.FontWeight.bold,
                color: textMuted,
              ),
              maxLines: 1,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            labels.pageOf(context.pageNumber, context.pagesCount),
            style: pw.TextStyle(fontSize: denseFooterFontSize, color: footerMuted),
          ),
        ],
      ),
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

  static pw.Widget sectionTitle(String text, {bool dense = false}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.SizedBox(height: dense ? 2 : 4),
        pw.Text(
          dense ? text : text.toUpperCase(),
          style: pw.TextStyle(
            fontSize: dense ? denseSectionFontSize : sectionFontSize,
            fontWeight: pw.FontWeight.bold,
            color: textPrimary,
            letterSpacing: dense ? 0.2 : 0.6,
          ),
        ),
        pw.SizedBox(height: dense ? 2 : 4),
        pw.Container(height: dense ? 1 : 1.5, color: textPrimary),
        pw.SizedBox(height: dense ? 4 : 6),
      ],
    );
  }

  static pw.Widget dayTitle(String text, {bool dense = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: dense ? 2 : 4),
      child: pw.Text(
        dense ? text : text.toUpperCase(),
        style: pw.TextStyle(
          fontSize: dense ? denseDayFontSize : dayFontSize,
          fontWeight: pw.FontWeight.bold,
          color: textMuted,
          letterSpacing: dense ? 0.1 : 0.4,
        ),
      ),
    );
  }

  static pw.Widget buildPageFooter(
    pw.Context context,
    PdfExportLabels labels,
    DateTime generatedAt, {
    bool dense = false,
    bool showDisclaimer = true,
  }) {
    final dateStr = _formatDate(generatedAt);
    final footerSize = dense ? denseFooterFontSize : footerFontSize;
    final topPadding = dense ? 6.0 : 12.0;
    return pw.Container(
      padding: pw.EdgeInsets.only(top: topPadding),
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
                style: pw.TextStyle(fontSize: footerSize, color: footerMuted),
              ),
              pw.Text(
                labels.generatedOn(dateStr),
                style: pw.TextStyle(fontSize: footerSize, color: footerMuted),
              ),
            ],
          ),
          if (showDisclaimer) ...[
            pw.SizedBox(height: dense ? 4 : 6),
            pw.Text(
              labels.footerDisclaimer,
              style: pw.TextStyle(fontSize: footerSize, color: footerMuted),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget tableCell(
    String text, {
    bool isHeader = false,
    bool isSuperset = false,
    bool center = false,
    bool bold = false,
    bool blankIfEmpty = false,
    String emptyPlaceholder = '-',
    double fontSize = tableFontSize,
    double paddingH = cellPaddingH,
    double paddingV = cellPaddingV,
    double? lineSpacing,
    bool dense = false,
  }) {
    if (dense) {
      fontSize = isHeader ? denseCompactTableFontSize : denseTableFontSize;
      paddingH = isHeader ? denseCompactCellPadding : denseCellPaddingH;
      paddingV = isHeader ? denseCompactCellPadding : denseCellPaddingV;
    }
    final sanitized = sanitizePdfText(text.trim());
    final display = sanitized.isEmpty
        ? (blankIfEmpty ? '' : emptyPlaceholder)
        : sanitized;
    final multiline = display.contains('\n');
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(
        horizontal: paddingH,
        vertical: multiline ? paddingV + 1 : paddingV,
      ),
      child: pw.Align(
        alignment: center ? pw.Alignment.center : pw.Alignment.centerLeft,
        child: pw.Text(
          isHeader ? display : display,
          style: pw.TextStyle(
            fontSize: isHeader
                ? tableHeaderFontSize
                : (isSuperset ? supersetFontSize : fontSize),
            fontWeight: (isHeader || isSuperset || bold)
                ? pw.FontWeight.bold
                : null,
            color: isHeader ? textMuted : textPrimary,
            letterSpacing: isHeader ? 0.2 : 0,
            lineSpacing: lineSpacing ?? (multiline ? 1.5 : 0),
          ),
          textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
        ),
      ),
    );
  }

  static pw.Widget programmingExerciseCell(
    String text, {
    required bool highlight,
    String emptyPlaceholder = '-',
    bool dense = false,
  }) {
    if (!highlight) {
      return tableCell(
        text,
        bold: true,
        blankIfEmpty: text.trim().isEmpty,
        emptyPlaceholder: emptyPlaceholder,
        dense: dense,
      );
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: exerciseGroupBg,
        border: pw.Border(
          left: pw.BorderSide(color: accent, width: dense ? 2 : 2.5),
        ),
      ),
      child: tableCell(
        text,
        bold: true,
        blankIfEmpty: text.trim().isEmpty,
        emptyPlaceholder: emptyPlaceholder,
        dense: dense,
      ),
    );
  }

  static pw.Widget compactCell(
    String text, {
    bool isHeader = false,
    PdfExportLabels? labels,
    bool dense = false,
    bool blankIfEmpty = false,
  }) {
    final empty = labels?.emptyValue ?? '-';
    final trimmed = text.trim();
    final display = trimmed.isEmpty ? (blankIfEmpty ? '' : empty) : text;
    return tableCell(
      display,
      isHeader: isHeader,
      fontSize: dense ? denseCompactTableFontSize : compactTableFontSize,
      paddingH: dense ? denseCompactCellPadding : compactCellPadding,
      paddingV: dense ? denseCompactCellPadding : compactCellPadding,
      blankIfEmpty: blankIfEmpty,
      emptyPlaceholder: empty,
      dense: dense,
    );
  }

  static pw.TableRow programmingHeaderRow(
    PdfExportLabels labels, {
    bool dense = false,
    bool prescriptionColumns = false,
  }) {
    if (prescriptionColumns) {
      return pw.TableRow(
        decoration: pw.BoxDecoration(color: tableHeaderBg),
        children: [
          tableCell(labels.colExercise, isHeader: true, dense: dense),
          tableCell(
            '${labels.colSets} / ${labels.colReps} / ${labels.colLoadRpe}',
            isHeader: true,
            dense: dense,
          ),
          tableCell(labels.colNotes, isHeader: true, dense: dense),
        ],
      );
    }
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: tableHeaderBg),
      children: [
        tableCell(labels.colExercise, isHeader: true, paddingV: dense ? 3 : 5, dense: dense),
        tableCell(labels.colSets, isHeader: true, center: true, paddingV: dense ? 3 : 5, dense: dense),
        tableCell(labels.colReps, isHeader: true, center: true, paddingV: dense ? 3 : 5, dense: dense),
        tableCell(labels.colLoadRpe, isHeader: true, center: true, paddingV: dense ? 3 : 5, dense: dense),
        tableCell(labels.colNotes, isHeader: true, paddingV: dense ? 3 : 5, dense: dense),
      ],
    );
  }

  static pw.Widget inlineSupersetBadge(String label, {bool dense = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(
        horizontal: dense ? denseCellPaddingH : cellPaddingH,
        vertical: dense ? denseCellPaddingV : cellPaddingV,
      ),
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: pw.BoxDecoration(
          color: supersetBg,
          borderRadius: pw.BorderRadius.circular(3),
        ),
        child: pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: dense ? denseSupersetFontSize : supersetFontSize,
            fontWeight: pw.FontWeight.bold,
            color: accent,
          ),
        ),
      ),
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
