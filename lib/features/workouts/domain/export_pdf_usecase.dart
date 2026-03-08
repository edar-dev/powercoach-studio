import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/workout_routine_model.dart';
import '../../customers/data/models/customer.dart';

/// Generates a PDF from [WorkoutRoutine]. Optionally uses [Customer] pdfHeader when [Customer.useCustomPdfHeader] is true.
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
              style: pw.TextStyle(fontSize: 10),
            ),
          if (headerText != null) pw.SizedBox(height: 8),
          pw.Text(
            routine.name,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
        ],
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
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              ...items.map(
                (m) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2),
                  child: pw.Text(
                    '${m.title}: ${m.subtitle}',
                    style: const pw.TextStyle(fontSize: 10),
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
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            ...week.days.expand((day) {
              return [
                pw.Text(
                  day.name,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2.5),
                    1: const pw.FlexColumnWidth(0.6),
                    2: const pw.FlexColumnWidth(0.8),
                    3: const pw.FlexColumnWidth(0.8),
                    4: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      children: [
                        _cell('Exercise'),
                        _cell('Sets'),
                        _cell('Reps'),
                        _cell('Load/RPE'),
                        _cell('Notes'),
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
                                _cell(s.reps),
                                _cell(s.rpe),
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
                          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                          children: [
                            _cell('Superset'),
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
                                  _cell(s.reps),
                                  _cell(s.rpe),
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

pw.Widget _cell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    child: pw.Text(
      text,
      style: const pw.TextStyle(fontSize: 9),
    ),
  );
}
