import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/export_pdf_usecase.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_export_preset.dart';

WorkoutRoutine _routineWithWeeks(int count) {
  return WorkoutRoutine(
    name: 'Test',
    mobilitySections: const [],
    mobilityItems: const [],
    phases: [
      WorkoutRoutine.defaultPhase(
        weeks: [
          for (var i = 0; i < count; i++)
            Week(
              id: 'w$i',
              name: 'Week ${i + 1}',
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
  group('filterRoutineWeeks', () {
    test('null weekIndices returns all weeks', () {
      final routine = _routineWithWeeks(3);
      final result = filterRoutineWeeks(routine, null);
      expect(result.weeks.length, 3);
      expect(identical(result, routine), isTrue);
    });

    test('empty weekIndices returns all weeks', () {
      final routine = _routineWithWeeks(3);
      final result = filterRoutineWeeks(routine, const []);
      expect(result.weeks.length, 3);
      expect(identical(result, routine), isTrue);
    });

    test('week 0 only keeps first week', () {
      final routine = _routineWithWeeks(4);
      final result = filterRoutineWeeks(routine, const [0]);
      expect(result.weeks.length, 1);
      expect(result.weeks.single.id, 'w0');
      expect(result.weeks.single.name, 'Week 1');
    });

    test('multiple indices are sorted and de-duplicated', () {
      final routine = _routineWithWeeks(4);
      final result = filterRoutineWeeks(routine, const [2, 0, 2, 1]);
      expect(result.weeks.map((w) => w.id), ['w0', 'w1', 'w2']);
    });

    test('invalid indices alone fall back to original', () {
      final routine = _routineWithWeeks(2);
      final result = filterRoutineWeeks(routine, const [-1, 99]);
      expect(identical(result, routine), isTrue);
      expect(result.weeks.length, 2);
    });

    test('mix of valid and invalid keeps only valid', () {
      final routine = _routineWithWeeks(3);
      final result = filterRoutineWeeks(routine, const [-1, 1, 50]);
      expect(result.weeks.map((w) => w.id), ['w1']);
    });
  });

  group('resolveWorkoutExportPreset', () {
    test('gym → dense, mobility off, all weeks', () {
      final options = resolveWorkoutExportPreset(
        WorkoutExportPreset.gym,
        hasMobilityItems: true,
      );
      expect(options.preset, WorkoutExportPreset.gym);
      expect(options.layout, WorkoutPdfLayout.dense);
      expect(options.includeMobility, isFalse);
      expect(options.weekIndices, isNull);
    });

    test('full → canonical, mobility on when items exist', () {
      final withMobility = resolveWorkoutExportPreset(
        WorkoutExportPreset.full,
        hasMobilityItems: true,
      );
      expect(withMobility.layout, WorkoutPdfLayout.canonical);
      expect(withMobility.includeMobility, isTrue);
      expect(withMobility.weekIndices, isNull);

      final withoutMobility = resolveWorkoutExportPreset(
        WorkoutExportPreset.full,
        hasMobilityItems: false,
      );
      expect(withoutMobility.includeMobility, isFalse);
    });

    test('week1Only → dense, mobility off, week index 0', () {
      final options = resolveWorkoutExportPreset(
        WorkoutExportPreset.week1Only,
        hasMobilityItems: true,
      );
      expect(options.layout, WorkoutPdfLayout.dense);
      expect(options.includeMobility, isFalse);
      expect(options.weekIndices, [0]);
    });
  });
}
