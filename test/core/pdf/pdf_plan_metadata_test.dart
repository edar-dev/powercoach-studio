import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/pdf/pdf_export_labels.dart';
import 'package:powercoach_studio/core/pdf/pdf_plan_metadata.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';

PdfExportLabels _labels() {
  return PdfExportLabels(
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
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
  );
}

WorkoutRoutine _fourWeekPlan() {
  return WorkoutRoutine(
    name: 'Plan',
    mobilitySections: const [],
    mobilityItems: const [],
    startDate: DateTime(2026, 3, 2),
    endDate: DateTime(2026, 3, 29),
    phases: [
      WorkoutRoutine.defaultPhase(
        weeks: [
          for (var i = 0; i < 4; i++)
            Week(
              id: 'w$i',
              name: 'S${i + 1}',
              days: const [
                Day(id: 'd0', name: 'Day 1', exercises: []),
              ],
            ),
        ],
      ),
    ],
  );
}

void main() {
  group('formatPlanPeriodLabel', () {
    test('full plan uses start and end dates', () {
      final routine = _fourWeekPlan();
      expect(
        formatPlanPeriodLabel(routine, _labels()),
        '02/03/2026 – 29/03/2026',
      );
    });

    test('week-1 filter scopes period to first week only', () {
      final routine = _fourWeekPlan();
      expect(
        formatPlanPeriodLabel(routine, _labels(), weekIndices: const [0]),
        '02/03/2026 – 08/03/2026',
      );
    });

    test('mid-plan week filter offsets from startDate', () {
      final routine = _fourWeekPlan();
      expect(
        formatPlanPeriodLabel(routine, _labels(), weekIndices: const [2, 3]),
        '16/03/2026 – 29/03/2026',
      );
    });

    test('buildPdfPlanMetadata passes weekIndices through', () {
      final meta = buildPdfPlanMetadata(
        routine: _fourWeekPlan(),
        labels: _labels(),
        clientName: 'Alex',
        weekIndices: const [0],
      );
      expect(meta.clientName, 'Alex');
      expect(meta.planPeriodLabel, '02/03/2026 – 08/03/2026');
    });

    test('invalid weekIndices keeps full plan period', () {
      final routine = _fourWeekPlan();
      expect(
        formatPlanPeriodLabel(routine, _labels(), weekIndices: const [99]),
        '02/03/2026 – 29/03/2026',
      );
    });
  });
}
