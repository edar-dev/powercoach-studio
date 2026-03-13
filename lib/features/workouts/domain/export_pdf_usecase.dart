import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/workout_routine_model.dart';
import '../../customers/data/models/customer.dart';

// PDF layout aligned to Stitch prototype "Generated Screen" (project 15732533611981325178, screen 80e27a86da484d75b1dc9481a2d61b1c).
// design/stitch-assets/generated-pdf-screen.html | .png
const double _pdfHeaderFontSize = 10;
const double _pdfTitleFontSize = 18;
const double _pdfSectionFontSize = 14;
const double _pdfDayFontSize = 12;
const double _pdfTableFontSize = 10;
const double _pdfSupersetFontSize = 9;
const double _pdfFooterFontSize = 8;
const double _pdfCellPadding = 8;
final PdfColor _pdfTableHeaderBg = PdfColor.fromHex('#f3f4f6');
final PdfColor _pdfBorder = PdfColor.fromHex('#e5e7eb');
final PdfColor _pdfSupersetBg = PdfColor.fromHex('#f9fafb');
final PdfColor _pdfFooterMuted = PdfColor.fromHex('#9ca3af');

/// Generates a PDF from [WorkoutRoutine]. Optionally uses [Customer] pdfHeader when [Customer.useCustomPdfHeader] is true.
/// Layout matches Stitch prototype "Generated Screen" (project 15732533611981325178).
/// Returns the path to the saved file in the temp directory for sharing.
Future<String> exportWorkoutRoutineToPdf(
  WorkoutRoutine routine, {
  Customer? customer,
}) async {
  final doc = pw.Document();
  final hasCustomHeader = customer != null &&
      customer.useCustomPdfHeader &&
      (customer.pdfHeader?.trim().isNotEmpty ?? false);
  final headerText = hasCustomHeader ? customer.pdfHeader!.trim() : null;

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      header: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (headerText != null)
            pw.Text(
              headerText,
              style: pw.TextStyle(fontSize: _pdfHeaderFontSize, color: _pdfFooterMuted),
            ),
          if (headerText != null) pw.SizedBox(height: 4),
          pw.Text(
            routine.name,
            style: pw.TextStyle(
              fontSize: _pdfTitleFontSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
        ],
      ),
      footer: (context) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 24),
        child: pw.Text(
          'This document is intended for the designated client only. Please consult a physician before beginning any new exercise program.',
          style: pw.TextStyle(fontSize: _pdfFooterFontSize, color: _pdfFooterMuted),
          textAlign: pw.TextAlign.center,
        ),
      ),
      build: (context) => [
        // Mobility (optional, grouped by section)
        if (routine.mobilityItems.isNotEmpty) ...[
          ...routine.mobilitySections.expand((section) {
            final items = routine.mobilityItems.where((m) => m.sectionId == section.id).toList();
            if (items.isEmpty) return <pw.Widget>[];
            return [
              pw.Text(
                section.name.isNotEmpty ? section.name : 'Mobility',
                style: pw.TextStyle(
                  fontSize: _pdfSectionFontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              ...items.map(
                (m) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2),
                  child: pw.Text(
                    '${m.title}: ${m.subtitle}',
                    style: pw.TextStyle(fontSize: _pdfTableFontSize),
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
            ];
          }),
          pw.SizedBox(height: 16),
        ],
        // Weeks and exercises
        ...routine.weeks.expand((week) {
          return [
            pw.Text(
              week.name,
              style: pw.TextStyle(
                fontSize: _pdfSectionFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            ...week.days.expand((day) {
              return [
                pw.Text(
                  day.name,
                  style: pw.TextStyle(
                    fontSize: _pdfDayFontSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Table(
                  border: pw.TableBorder.all(color: _pdfBorder),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2.5),
                    1: const pw.FlexColumnWidth(0.6),
                    2: const pw.FlexColumnWidth(0.8),
                    3: const pw.FlexColumnWidth(0.8),
                    4: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: _pdfTableHeaderBg,
                      ),
                      children: [
                        _cell('Exercise', isHeader: true),
                        _cell('Sets', isHeader: true),
                        _cell('Reps', isHeader: true),
                        _cell('Load/RPE', isHeader: true),
                        _cell('Notes', isHeader: true),
                      ],
                    ),
                    ...partitionExercisesBySuperset(day.exercises).expand((item) {
                      if (item is Exercise) {
                        final e = item;
                        final details = e.effectiveSetDetails;
                        if (details.length > 1) {
                          return details.asMap().entries.map((entry) {
                            final i = entry.key;
                            final s = entry.value;
                            return pw.TableRow(
                              children: [
                                _cell(i == 0 ? e.name : ''),
                                _cell(i == 0 ? '${details.length}' : ''),
                                _cell(s.displayText.isNotEmpty ? s.displayText : s.reps),
                                _cell(s.displayText.isNotEmpty ? '' : s.rpe),
                                _cell(s.note.isNotEmpty ? s.note : (i == 0 ? e.note : '')),
                              ],
                            );
                          });
                        }
                        return [
                          pw.TableRow(
                            children: [
                              _cell(e.name),
                              _cell(e.sets),
                              _cell(e.reps),
                              _cell(e.rpe),
                              _cell(e.note),
                            ],
                          ),
                        ];
                      }
                      final group = item as List<Exercise>;
                      return [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: _pdfSupersetBg),
                          children: [
                            _cell('Superset', isSupersetHeader: true),
                            _cell(''),
                            _cell(''),
                            _cell(''),
                            _cell(''),
                          ],
                        ),
                        ...group.expand((e) {
                          final details = e.effectiveSetDetails;
                          if (details.length > 1) {
                            return details.asMap().entries.map((entry) {
                              final i = entry.key;
                              final s = entry.value;
                              return pw.TableRow(
                                children: [
                                  _cell(i == 0 ? e.name : ''),
                                  _cell(i == 0 ? '${details.length}' : ''),
                                  _cell(s.displayText.isNotEmpty ? s.displayText : s.reps),
                                  _cell(s.displayText.isNotEmpty ? '' : s.rpe),
                                  _cell(s.note.isNotEmpty ? s.note : (i == 0 ? e.note : '')),
                                ],
                              );
                            });
                          }
                          return [
                            pw.TableRow(
                              children: [
                                _cell(e.name),
                                _cell(e.sets),
                                _cell(e.reps),
                                _cell(e.rpe),
                                _cell(e.note),
                              ],
                            ),
                          ];
                        }),
                      ];
                    }),
                  ],
                ),
                pw.SizedBox(height: 12),
              ];
            }),
            pw.SizedBox(height: 12),
          ];
        }),
      ],
    ),
  );

  final bytes = await doc.save();
  final dir = await getTemporaryDirectory();
  final sanitizedName = routine.name.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
  final sanitized = sanitizedName.isEmpty ? 'workout_plan' : sanitizedName;
  final file = File('${dir.path}/${sanitized}_${DateTime.now().millisecondsSinceEpoch}.pdf');
  await file.writeAsBytes(bytes);
  return file.path;
}

pw.Widget _cell(String text, {bool isHeader = false, bool isSupersetHeader = false}) {
  final fontSize = isSupersetHeader ? _pdfSupersetFontSize : _pdfTableFontSize;
  return pw.Padding(
    padding: pw.EdgeInsets.symmetric(horizontal: _pdfCellPadding, vertical: _pdfCellPadding),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: fontSize,
        fontWeight: (isHeader || isSupersetHeader) ? pw.FontWeight.bold : null,
      ),
    ),
  );
}
