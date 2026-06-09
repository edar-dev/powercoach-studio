import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/export/export_artifact.dart';
import '../../../core/pdf/pdf_coach_header.dart';
import '../../../core/pdf/pdf_document_theme.dart';
import '../../../core/pdf/pdf_export_labels.dart';
import '../data/models/customer_measurement.dart';

Future<ExportArtifact> exportMeasurementsToPdf(
  List<CustomerMeasurement> measurements,
  String title, {
  required PdfExportLabels labels,
  PdfCoachHeaderInfo? coachHeader,
}) async {
  final sorted = List<CustomerMeasurement>.from(measurements)
    ..sort((a, b) => a.measurementDate.compareTo(b.measurementDate));

  final generatedAt = DateTime.now();
  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(PdfDocumentTheme.pageMargin),
      header: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          if (coachHeader != null && coachHeader.hasContent)
            PdfDocumentTheme.buildCoachHeaderBand(coachHeader),
          PdfDocumentTheme.buildDocumentTitle(title),
          PdfDocumentTheme.buildSubtitle(
            labels.measurementRecordCount(sorted.length),
          ),
          pw.SizedBox(height: 16),
        ],
      ),
      footer: (context) =>
          PdfDocumentTheme.buildPageFooter(context, labels, generatedAt),
      build: (context) => [
        pw.Table(
          border: pw.TableBorder.all(color: PdfDocumentTheme.border, width: 0.5),
          columnWidths: const {
            0: pw.FlexColumnWidth(1.15),
            1: pw.FlexColumnWidth(0.9),
            2: pw.FlexColumnWidth(1.05),
            3: pw.FlexColumnWidth(0.9),
            4: pw.FlexColumnWidth(0.85),
            5: pw.FlexColumnWidth(0.95),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfDocumentTheme.tableHeaderBg),
              children: [
                _headerCell(labels.measurementDate),
                _headerCell(labels.measurementBodyFat, center: true),
                _headerCell(labels.measurementMuscleMass, center: true),
                _headerCell(labels.measurementWaist, center: true),
                _headerCell(labels.measurementSquat, center: true),
                _headerCell(labels.measurementBench, center: true),
              ],
            ),
            ...sorted.map(
              (measurement) => pw.TableRow(
                children: [
                  _bodyCell(
                    CustomerMeasurement.toDateString(measurement.measurementDate),
                  ),
                  _bodyCell(
                    _formatNumber(measurement.bodyFatPercent, labels),
                    center: true,
                  ),
                  _bodyCell(
                    _formatNumber(measurement.muscleMassKg, labels),
                    center: true,
                  ),
                  _bodyCell(
                    _formatNumber(measurement.waistCm, labels),
                    center: true,
                  ),
                  _bodyCell(
                    _formatNumber(measurement.squat1RM, labels),
                    center: true,
                  ),
                  _bodyCell(
                    _formatNumber(measurement.benchPress1RM, labels),
                    center: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );

  final bytes = await doc.save();
  final sanitized = title.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
  final base = sanitized.isEmpty ? 'measurements' : sanitized;
  return ExportArtifact(
    bytes: bytes,
    filename: '${base}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    mimeType: 'application/pdf',
  );
}

pw.Widget _headerCell(String text, {bool center = false}) {
  return PdfDocumentTheme.tableCell(
    text,
    isHeader: true,
    center: center,
    fontSize: 9,
    paddingH: 6,
    paddingV: 6,
  );
}

pw.Widget _bodyCell(String text, {bool center = false}) {
  return PdfDocumentTheme.tableCell(
    text,
    center: center,
    fontSize: 9,
    paddingH: 6,
    paddingV: 6,
  );
}

String _formatNumber(double? value, PdfExportLabels labels) {
  if (value == null) return labels.emptyValue;
  return value.toString();
}
