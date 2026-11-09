import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/pdf/pdf_export_labels.dart';
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
}
