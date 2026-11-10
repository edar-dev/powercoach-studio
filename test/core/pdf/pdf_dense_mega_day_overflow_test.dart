import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:powercoach_studio/core/pdf/pdf_export_labels.dart';
import 'package:powercoach_studio/core/pdf/pdf_page_packing.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/export_pdf_usecase.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_routine_json_codec.dart';

PdfExportLabels _labels() {
  return PdfExportLabels(
    brandName: 'PowerCoach Studio',
    coachPrefix: 'Coach:',
    colExercise: 'Esercizio',
    colSets: 'Serie',
    colReps: 'Ripetizioni',
    colLoadRpe: 'Carico/RPE',
    colNotes: 'Note',
    mobilityFallback: 'Mobilità',
    superset: 'Superset',
    dayNumber: (d) => 'Giorno $d',
    emptyValue: '-',
    footerDisclaimer: 'Documento generato con PowerCoach Studio.',
    pageOf: (c, t) => 'Pagina $c di $t',
    generatedOn: (d) => 'Generato il $d',
    measurementDate: 'Data',
    measurementBodyFat: 'BF',
    measurementMuscleMass: 'Massa muscolare',
    measurementSquat: 'Squat',
    measurementBench: 'Panca',
    measurementDeadlift: 'Stacco',
    exportGenerating: 'Generazione…',
    measurementRecordCount: (c) => '$c record',
    denseWeekShort: (n) => 'S$n',
    denseAllWeeks: 'tutte le settimane',
    denseDitto: '"',
    denseWeekLegendEntry: (n, name) => 'S$n = $name',
    denseWeeksSpan: (first, last) => 'S$first–S$last',
    denseLegend: 'Colonne = settimane · " = uguale alla colonna precedente',
    pdfClientPlanFor: (name) => 'Scheda per: $name',
    pdfPlanPeriod: (start, end) => '$start – $end',
    pdfPlanPeriodOpen: (start) => 'Dal $start',
    formatPlanDate: (date) =>
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
  );
}

Exercise _ex({
  required String id,
  required String name,
  String sets = '3',
  String reps = '10',
  String rpe = '@8',
  String note = '',
}) {
  return Exercise(
    id: id,
    name: name,
    sets: sets,
    reps: reps,
    rpe: rpe,
    note: note,
    shortName: '',
  );
}

List<Exercise> _megaExercises({required String weekTag}) {
  const names = [
    'Incline Bench Press (Dumbbell) with long coaching cue',
    'Flat Dumbbell Press (Dumbbell) controlled eccentric tempo',
    'Cable Fly High to Low (Cable) squeeze at midline',
    'Lat Pulldown Wide Grip (Cable) full stretch emphasis',
    'Seated Cable Row V-Grip (Cable) pause contraction',
    'Single Arm Cable Row (Cable) brace trunk each rep',
    'Lateral Raise (Dumbbell) slight forward lean only',
    'Rear Delt Fly (Dumbbell) soft elbows no swinging',
    'Triceps Pushdown Rope (Cable) full lockout finish',
    'Overhead Triceps Extension (Cable) elbows fixed',
    'Barbell Curl Strict (Barbell) no hip drive allowed',
    'Hammer Curl Neutral Grip (Dumbbell) slow negatives',
    'Leg Extension Machine full ROM controlled lowering',
    'Lying Leg Curl Machine heels up squeeze at top',
  ];
  return [
    for (var i = 0; i < names.length; i++)
      _ex(
        id: 'mega_${weekTag}_$i',
        name: names[i],
        note:
            'Week $weekTag cue: keep scapula set, breathe out on effort, stop one rep shy of failure.',
      ),
  ];
}

/// Under the old #251 gate (rowCount >= 8), this day stayed Inseparable.
List<Exercise> _underThresholdWrappedExercises({required String weekTag}) {
  return [
    for (var i = 0; i < 7; i++)
      _ex(
        id: 'under8_${weekTag}_$i',
        name:
            'Long Named Compound Movement Number $i with equipment and tempo cues',
        sets: '4',
        reps: '8-10',
        note: List.filled(
          5,
          'Week $weekTag cue $i: scapula set, brace trunk, controlled eccentric, pause, drive, breathe.',
        ).join(' '),
      ),
  ];
}

Day _day({
  required String id,
  required String name,
  required List<Exercise> exercises,
}) {
  return Day(id: id, name: name, exercises: exercises);
}

Week _week(int index) {
  final tag = 'w$index';
  return Week(
    id: tag,
    name: 'Settimana $index',
    days: [
      _day(
        id: '${tag}_d0',
        name: 'Push short',
        exercises: [
          _ex(id: '${tag}_bp', name: 'Bench Press'),
          _ex(id: '${tag}_ohp', name: 'Overhead Press'),
        ],
      ),
      _day(
        id: '${tag}_d1',
        name: 'Mega bodybuilding day',
        exercises: _megaExercises(weekTag: tag),
      ),
      _day(
        id: '${tag}_d2',
        name: 'Recovery',
        exercises: [
          _ex(id: '${tag}_bike', name: 'Assault Bike', sets: '1', reps: '10 min'),
        ],
      ),
    ],
  );
}

Week _underThresholdWeek(int index) {
  final tag = 'w$index';
  return Week(
    id: tag,
    name: 'Settimana $index',
    days: [
      _day(
        id: '${tag}_d0',
        name: 'Tall under-8-row day',
        exercises: _underThresholdWrappedExercises(weekTag: tag),
      ),
    ],
  );
}

/// Reproduces POWERCOACH-STUDIO-G shape: non-spanning widget taller than ~806 page.
pw.Table _productionShapedTallTable() {
  // Fixed-ish tall rows so Inseparable exceeds page content height (~805.89).
  return pw.Table(
    border: pw.TableBorder.all(),
    children: [
      for (var i = 0; i < 14; i++)
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(
                'Ex $i ${'cue wrap content ' * 16}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
            for (var w = 0; w < 4; w++)
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  'S${w + 1}\n4x8-10 @8\n${'note line\n' * 3}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
          ],
        ),
    ],
  );
}

void main() {
  test(
    'dense 4-week mega day (≥14 exercises) exports without page-overflow crash',
    () async {
      final routine = WorkoutRoutine(
        name: 'Dense Mega Day Overflow',
        mobilitySections: const [],
        mobilityItems: const [],
        phases: [
          WorkoutRoutine.defaultPhase(
            weeks: [for (var i = 1; i <= 4; i++) _week(i)],
          ),
        ],
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 6, 28),
      );

      final artifact = await exportWorkoutRoutineToPdf(
        routine,
        labels: _labels(),
        layout: WorkoutPdfLayout.dense,
        includeMobility: false,
      );

      expect(artifact.bytes, isNotEmpty);
    },
  );

  test(
    'dense export of fixture 09-mega-day-fourteen-exercises succeeds',
    () async {
      final jsonText = File(
        'docs/pdfs/fixtures/09-mega-day-fourteen-exercises.json',
      ).readAsStringSync();
      final routine = decodeWorkoutRoutineJson(jsonText);

      final artifact = await exportWorkoutRoutineToPdf(
        routine,
        labels: _labels(),
        layout: WorkoutPdfLayout.dense,
        includeMobility: false,
      );

      expect(artifact.bytes, isNotEmpty);
    },
  );

  test(
    'dense day under old rowCount>=8 threshold still exports (always-span)',
    () async {
      // Estimates for 7 rows stay well under 85% budget, so #251 kept
      // title+table Inseparable. Always-span must still succeed.
      final estimate = estimateDenseDayHeight(rowCount: 7, weekCount: 4);
      final laterBudget = denseContentBudget(firstPage: false);
      expect(estimate, lessThan(laterBudget * 0.85));
      expect(7, lessThan(8));
      expect(
        denseDayCanKeepInseparable(
          estimatedHeight: estimate,
          pageBudget: laterBudget,
        ),
        isFalse,
      );

      final routine = WorkoutRoutine(
        name: 'Under8 Always Span',
        mobilitySections: const [],
        mobilityItems: const [],
        phases: [
          WorkoutRoutine.defaultPhase(
            weeks: [for (var i = 1; i <= 4; i++) _underThresholdWeek(i)],
          ),
        ],
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 6, 28),
      );

      final artifact = await exportWorkoutRoutineToPdf(
        routine,
        labels: _labels(),
        layout: WorkoutPdfLayout.dense,
        includeMobility: false,
      );
      expect(artifact.bytes, isNotEmpty);
    },
  );

  test(
    '~820pt Inseparable day table overflows; spanning MultiPage child succeeds',
    () async {
      // Same page geometry as production MultiPage dense margins/header/footer
      // yielding ~805.89 content height (POWERCOACH-STUDIO-G).
      const margin = 18.0;

      final inseparableDoc = pw.Document();
      expect(
        () => inseparableDoc.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(margin),
            header: (c) => pw.SizedBox(height: 36),
            footer: (c) => pw.SizedBox(height: 28),
            build: (context) => [
              pw.Inseparable(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    pw.Text('Mega day title'),
                    _productionShapedTallTable(),
                    pw.SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains("won't fit into the page"),
              contains('805.8897637795275'),
            ),
          ),
        ),
      );

      final spanningDoc = pw.Document();
      spanningDoc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(margin),
          header: (c) => pw.SizedBox(height: 36),
          footer: (c) => pw.SizedBox(height: 28),
          build: (context) => [
            pw.Inseparable(child: pw.Text('Mega day title')),
            _productionShapedTallTable(),
            pw.SizedBox(height: 8),
          ],
        ),
      );
      final bytes = await spanningDoc.save();
      expect(bytes, isNotEmpty);
    },
  );
}
