import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/density_block.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_density_block_mutations.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_exercise_mutations.dart';

WorkoutRoutine _routineWithExercises(List<Exercise> exercises) {
  return WorkoutRoutine.empty().copyWith(
    weeks: [
      Week(
        id: 'w1',
        name: 'Week 1',
        days: [
          Day(
            id: 'd1',
            name: 'Day A',
            exercises: exercises,
          ),
        ],
      ),
    ],
  );
}

void main() {
  group('density block mutations', () {
    test('setDensityBlock and clearDensityBlock on Day', () {
      const day = Day(id: 'd1', name: 'Day', exercises: []);
      final withBlock = setDensityBlock(
        day,
        'ss_1',
        DensityBlockConfig.defaultCircuit,
      );
      expect(withBlock.densityBlocks?['ss_1']?.type, DensityBlockType.circuit);
      final cleared = clearDensityBlock(withBlock, 'ss_1');
      expect(cleared.densityBlocks, isNull);
    });

    test('assignExerciseToDensityGroupInRoutine sets group and config', () {
      final routine = _routineWithExercises([
        const Exercise(
          id: 'e1',
          name: 'Squat',
          sets: '3',
          reps: '10',
          rpe: '',
          note: '',
        ),
      ]);
      final updated = assignExerciseToDensityGroupInRoutine(
        routine: routine,
        weekIndex: 0,
        dayIndex: 0,
        exerciseId: 'e1',
        groupId: 'ss_1',
        densityConfig: DensityBlockConfig.defaultEmom,
      );
      final day = updated!.weeks.single.days.single;
      expect(day.exercises.single.supersetGroupId, 'ss_1');
      expect(day.densityBlocks?['ss_1']?.type, DensityBlockType.emom);
      expect(day.densityBlocks?['ss_1']?.intervalSeconds, 60);
    });

    test('removing last exercise from group clears densityBlocks entry', () {
      final routine = _routineWithExercises([
        const Exercise(
          id: 'e1',
          name: 'A',
          sets: '3',
          reps: '10',
          rpe: '',
          note: '',
          supersetGroupId: 'ss_1',
        ),
        const Exercise(
          id: 'e2',
          name: 'B',
          sets: '3',
          reps: '10',
          rpe: '',
          note: '',
          supersetGroupId: 'ss_1',
        ),
      ]);
      final withDensity = setDensityBlockInRoutine(
        routine: routine,
        weekIndex: 0,
        dayIndex: 0,
        groupId: 'ss_1',
        config: DensityBlockConfig.defaultCircuit,
      )!;

      final unlinkedOne = removeExerciseFromSupersetInRoutine(
        routine: withDensity,
        weekIndex: 0,
        dayIndex: 0,
        exerciseId: 'e1',
      )!;
      expect(
        unlinkedOne.weeks.single.days.single.densityBlocks?['ss_1'],
        isNotNull,
      );

      final unlinkedLast = removeExerciseFromSupersetInRoutine(
        routine: unlinkedOne,
        weekIndex: 0,
        dayIndex: 0,
        exerciseId: 'e2',
      )!;
      expect(unlinkedLast.weeks.single.days.single.densityBlocks, isNull);
    });

    test('deleting last grouped exercise clears densityBlocks entry', () {
      final routine = _routineWithExercises([
        const Exercise(
          id: 'e1',
          name: 'A',
          sets: '3',
          reps: '10',
          rpe: '',
          note: '',
          supersetGroupId: 'ss_1',
        ),
      ]);
      final withDensity = setDensityBlockInRoutine(
        routine: routine,
        weekIndex: 0,
        dayIndex: 0,
        groupId: 'ss_1',
        config: DensityBlockConfig.defaultCircuit,
      )!;
      final removed = removeExerciseFromDayInRoutine(
        routine: withDensity,
        weekIndex: 0,
        dayIndex: 0,
        exerciseId: 'e1',
      )!;
      expect(removed.weeks.single.days.single.densityBlocks, isNull);
    });
    test('reassigning last member to another group prunes old densityBlocks', () {
      final routine = _routineWithExercises([
        const Exercise(
          id: 'e1',
          name: 'A',
          sets: '3',
          reps: '10',
          rpe: '',
          note: '',
          supersetGroupId: 'ss_old',
        ),
        const Exercise(
          id: 'e2',
          name: 'B',
          sets: '3',
          reps: '10',
          rpe: '',
          note: '',
          supersetGroupId: 'ss_new',
        ),
      ]);
      final withDensity = setDensityBlockInRoutine(
        routine: routine,
        weekIndex: 0,
        dayIndex: 0,
        groupId: 'ss_old',
        config: DensityBlockConfig.defaultCircuit,
      )!;

      final moved = assignExerciseToSupersetInRoutine(
        routine: withDensity,
        weekIndex: 0,
        dayIndex: 0,
        exerciseId: 'e1',
        supersetGroupId: 'ss_new',
      )!;
      final day = moved.weeks.single.days.single;
      expect(day.exercises.first.supersetGroupId, 'ss_new');
      expect(day.densityBlocks, isNull);
    });

    test('setDensityBlock with superset type clears entry', () {
      const day = Day(
        id: 'd1',
        name: 'Day',
        exercises: [],
        densityBlocks: {
          'ss_1': DensityBlockConfig.defaultCircuit,
        },
      );
      final cleared = setDensityBlock(
        day,
        'ss_1',
        const DensityBlockConfig(type: DensityBlockType.superset),
      );
      expect(cleared.densityBlocks, isNull);
    });
  });
}
