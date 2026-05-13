import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/models/customer_measurement.dart';

final PdfColor _pdfTableHeaderBg = PdfColor.fromHex('#f3f4f6');
final PdfColor _pdfBorder = PdfColor.fromHex('#e5e7eb');

Future<String> exportMeasurementsToPdf(
  List<CustomerMeasurement> measurements,
  String title,
) async {
  final sorted = List<CustomerMeasurement>.from(measurements)
    ..sort((a, b) => a.measurementDate.compareTo(b.measurementDate));

  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (context) => [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),
        pw.Table(
          border: pw.TableBorder.all(color: _pdfBorder, width: 0.5),
          columnWidths: const {
            0: pw.FlexColumnWidth(1.2),
            1: pw.FlexColumnWidth(1),
            2: pw.FlexColumnWidth(1),
            3: pw.FlexColumnWidth(1),
            4: pw.FlexColumnWidth(1),
            5: pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: _pdfTableHeaderBg),
              children: [
                _headerCell('Date'),
                _headerCell('Body fat %'),
                _headerCell('Muscle (kg)'),
                _headerCell('Waist (cm)'),
                _headerCell('Squat 1RM'),
                _headerCell('Bench 1RM'),
              ],
            ),
            ...sorted.map(
              (measurement) => pw.TableRow(
                children: [
                  _bodyCell(CustomerMeasurement.toDateString(measurement.measurementDate)),
                  _bodyCell(_formatNumber(measurement.bodyFatPercent)),
                  _bodyCell(_formatNumber(measurement.muscleMassKg)),
                  _bodyCell(_formatNumber(measurement.waistCm)),
                  _bodyCell(_formatNumber(measurement.squat1RM)),
                  _bodyCell(_formatNumber(measurement.benchPress1RM)),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );

  final bytes = await doc.save();
  final dir = await getTemporaryDirectory();
  final sanitized = title.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
  final base = sanitized.isEmpty ? 'measurements' : sanitized;
  final file = File(
    '${dir.path}/${base}_${DateTime.now().millisecondsSinceEpoch}.pdf',
  );
  await file.writeAsBytes(bytes);
  return file.path;
}

pw.Widget _headerCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
    ),
  );
}

pw.Widget _bodyCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
  );
}

String _formatNumber(double? value) {
  if (value == null) {
    return '—';
  }
  return value.toString();
}
