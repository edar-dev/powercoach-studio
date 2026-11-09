import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:powercoach_studio/core/pdf/pdf_coach_header.dart';
import 'package:powercoach_studio/core/pdf/pdf_document_theme.dart';
import 'package:powercoach_studio/core/pdf/pdf_export_labels.dart';
import 'package:powercoach_studio/core/pdf/pdf_logo_image.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/export_pdf_usecase.dart';

/// 1×1 red PNG — valid MemoryImage payload.
final Uint8List _validPng = Uint8List.fromList(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  ),
);

void main() {
  test('tryPdfMemoryImage returns image for valid PNG', () {
    expect(tryPdfMemoryImage(_validPng), isNotNull);
  });

  test('tryPdfMemoryImage returns null for corrupt bytes', () {
    final corrupt = Uint8List.fromList([0x00, 0x01, 0x02, 0x03, 0x04]);
    expect(tryPdfMemoryImage(corrupt), isNull);
  });

  test('tryPdfMemoryImage returns null for empty bytes', () {
    expect(tryPdfMemoryImage(Uint8List(0)), isNull);
  });

  test('isPdfLogoDecodeError matches pdf image decode messages', () {
    expect(
      isPdfLogoDecodeError(
        Exception('PdfException: Unable to guess the image type 5 bytes'),
      ),
      isTrue,
    );
    expect(
      isPdfLogoDecodeError(Exception('PdfException: Unable decode the image')),
      isTrue,
    );
    expect(
      isPdfLogoDecodeError(Exception('Unable to decode the image')),
      isTrue,
    );
    expect(
      isPdfLogoDecodeError(Exception('Unable to decode image')),
      isTrue,
    );
    expect(isPdfLogoDecodeError(Exception('network timeout')), isFalse);
  });

  test('buildCoachHeaderBand skips corrupt logo without throwing', () async {
    final info = PdfCoachHeaderInfo(
      leftLine: 'Studio Test',
      centerLine: 'Coach: Ada',
      logoBytes: Uint8List.fromList([1, 2, 3, 4, 5]),
    );

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => PdfDocumentTheme.buildCoachHeaderBand(info),
      ),
    );

    final bytes = await doc.save();
    expect(bytes, isNotEmpty);
  });

  test('buildCoachHeaderBand keeps valid logo', () async {
    final info = PdfCoachHeaderInfo(
      leftLine: 'Studio Test',
      logoBytes: _validPng,
    );

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => PdfDocumentTheme.buildCoachHeaderBand(info),
      ),
    );

    final bytes = await doc.save();
    expect(bytes, isNotEmpty);
  });

  test('exportWorkoutRoutineToPdf succeeds with corrupt brand logo', () async {
    final routine = WorkoutRoutine(
      name: 'Logo harden',
      mobilitySections: const [],
      mobilityItems: const [],
      phases: [
        WorkoutRoutine.defaultPhase(
          weeks: [
            const Week(
              id: 'w0',
              name: 'Week 1',
              days: [
                Day(
                  id: 'd0',
                  name: 'A',
                  exercises: [
                    Exercise(
                      id: 'sq',
                      name: 'Squat',
                      sets: '3',
                      reps: '5',
                      rpe: '',
                      note: '',
                      shortName: '',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );

    final artifact = await exportWorkoutRoutineToPdf(
      routine,
      labels: PdfExportLabels(
        brandName: 'PowerCoach Studio',
        coachPrefix: 'Coach:',
        colExercise: 'Exercise',
        colSets: 'Sets',
        colReps: 'Reps',
        colLoadRpe: 'Load/RPE',
        colNotes: 'Notes',
        mobilityFallback: 'Mobility',
        superset: 'Superset',
        dayNumber: (d) => 'Day $d',
        emptyValue: '-',
        footerDisclaimer: 'Disclaimer',
        pageOf: (c, t) => '$c/$t',
        generatedOn: (d) => d,
        measurementDate: 'Date',
        measurementBodyFat: 'BF',
        measurementMuscleMass: 'Muscle',
        measurementSquat: 'Squat',
        measurementBench: 'Bench',
        measurementDeadlift: 'Deadlift',
        exportGenerating: '...',
        measurementRecordCount: (c) => '$c records',
        denseWeekShort: (n) => 'S$n',
        denseAllWeeks: 'all',
        denseDitto: '"',
        denseWeekLegendEntry: (n, name) => 'S$n = $name',
        denseWeeksSpan: (first, last) => 'S$first-S$last',
        denseLegend: 'legend',
        pdfClientPlanFor: (name) => 'Plan for: $name',
        pdfPlanPeriod: (start, end) => '$start – $end',
        pdfPlanPeriodOpen: (start) => 'From $start',
        formatPlanDate: (date) =>
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      ),
      coachHeader: PdfCoachHeaderInfo(
        leftLine: 'Studio',
        logoBytes: Uint8List.fromList([0xFF, 0xD8, 0x00]), // truncated JPEG
      ),
      layout: WorkoutPdfLayout.dense,
      includeMobility: false,
    );

    expect(artifact.bytes, isNotEmpty);
  });
}
