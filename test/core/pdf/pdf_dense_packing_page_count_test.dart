import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/pdf/pdf_export_labels.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/export_pdf_usecase.dart';

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
  String reps = '8',
  String rpe = '70kg',
}) {
  return Exercise(
    id: id,
    name: name,
    sets: sets,
    reps: reps,
    rpe: rpe,
    note: '',
    shortName: '',
  );
}

/// Rough page count from PDF object markers (excludes /Pages).
int _countPdfPages(Uint8List bytes) {
  final text = utf8.decode(bytes, allowMalformed: true);
  return RegExp(r'/Type\s*/Page(?![sA-Za-z])').allMatches(text).length;
}

void main() {
  test('dense four short days packs into at most 2 pages', () async {
    final routine = WorkoutRoutine(
      name: 'Four Day Split',
      mobilitySections: const [],
      mobilityItems: const [],
      phases: [
        WorkoutRoutine.defaultPhase(
          weeks: [
            Week(
              id: 'w0',
              name: 'Settimana 1',
              days: [
                Day(
                  id: 'd0',
                  name: 'Push',
                  exercises: [
                    _ex(id: 'bp', name: 'Bench Press', sets: '4', reps: '6'),
                    _ex(id: 'ohp', name: 'OHP', sets: '3', reps: '8'),
                    _ex(id: 'fly', name: 'Cable Fly', sets: '3', reps: '12'),
                  ],
                ),
                Day(
                  id: 'd1',
                  name: 'Pull',
                  exercises: [
                    _ex(id: 'dl', name: 'Deadlift', sets: '3', reps: '5'),
                    _ex(id: 'pullup', name: 'Pull-up', sets: '3', reps: '8'),
                    _ex(id: 'curl', name: 'Curl', sets: '3', reps: '12'),
                  ],
                ),
                Day(
                  id: 'd2',
                  name: 'Legs',
                  exercises: [
                    _ex(id: 'sq', name: 'Squat', sets: '4', reps: '5'),
                    _ex(id: 'legpress', name: 'Leg Press', sets: '3', reps: '10'),
                    _ex(id: 'calf', name: 'Calf Raise', sets: '4', reps: '15'),
                  ],
                ),
                Day(
                  id: 'd3',
                  name: 'Upper accessory',
                  exercises: [
                    _ex(id: 'dbp', name: 'DB Press', sets: '3', reps: '10'),
                    _ex(id: 'lat', name: 'Lat Pulldown', sets: '3', reps: '12'),
                    _ex(
                      id: 'latraise',
                      name: 'Lateral Raise',
                      sets: '3',
                      reps: '15',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
      startDate: DateTime(2026, 3, 2),
      endDate: DateTime(2026, 3, 8),
    );

    final artifact = await exportWorkoutRoutineToPdf(
      routine,
      labels: _labels(),
      layout: WorkoutPdfLayout.dense,
      includeMobility: false,
    );

    expect(artifact.bytes, isNotEmpty);
    final pages = _countPdfPages(artifact.bytes);
    expect(pages, greaterThanOrEqualTo(1));
    expect(pages, lessThanOrEqualTo(2));
  });
}
