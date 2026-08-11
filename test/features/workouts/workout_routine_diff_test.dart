import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/density_block.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_routine_diff.dart';

WorkoutRoutine _routine({required List<Week> weeks}) => WorkoutRoutine(
  name: 'Plan',
  mobilitySections: const [],
  mobilityItems: const [],
  weeks: weeks,
);

void main() {
  group('diffWorkoutRoutines', () {
    test('identical plans produce no changes', () {
      final weeks = [
        Week(
          id: 'w1',
          name: 'Week 1',
          days: [
            const Day(
              id: 'd1',
              name: 'Day A',
              exercises: [
                Exercise(id: 'e1', name: 'Squat', sets: '3', reps: '5', rpe: '100kg'),
              ],
            ),
          ],
        ),
      ];
      final result = diffWorkoutRoutines(
        planA: _routine(weeks: weeks),
        planB: _routine(weeks: weeks),
      );

      expect(result.hasChanges, isFalse);
      expect(result.addedDayCount, 0);
      expect(result.removedDayCount, 0);
      expect(result.changedDayCount, 0);
    });

    test('ignores session state when comparing structure', () {
      final weeks = [
        Week(
          id: 'w1',
          name: 'Week 1',
          days: [
            const Day(
              id: 'd1',
              name: 'Day A',
              exercises: [
                Exercise(id: 'e1', name: 'Squat', sets: '3', reps: '5', rpe: '100kg'),
              ],
            ),
          ],
        ),
      ];
      final planA = _routine(weeks: weeks).copyWith(
        sessionCompletionByKey: const {'0-0': true},
      );
      final planB = _routine(weeks: weeks);

      final result = diffWorkoutRoutines(planA: planA, planB: planB);

      expect(result.hasChanges, isFalse);
    });

    test('detects an added day', () {
      final planA = _routine(
        weeks: [
          const Week(id: 'w1', name: 'Week 1', days: []),
        ],
      );
      final planB = _routine(
        weeks: [
          Week(
            id: 'w1',
            name: 'Week 1',
            days: [
              const Day(
                id: 'd1',
                name: 'Day A',
                exercises: [
                  Exercise(id: 'e1', name: 'Squat', sets: '3', reps: '5', rpe: ''),
                ],
              ),
            ],
          ),
        ],
      );

      final result = diffWorkoutRoutines(planA: planA, planB: planB);

      expect(result.addedDayCount, 1);
      expect(result.hasChanges, isTrue);
      final dayDiff = result.weekDiffs.single.dayDiffs.single;
      expect(dayDiff.kind, WorkoutRoutineDiffKind.added);
      expect(dayDiff.exerciseDiffs.single.kind, WorkoutRoutineDiffKind.added);
    });

    test('detects a removed exercise within a matched day', () {
      final dayA = const Day(
        id: 'd1',
        name: 'Day A',
        exercises: [
          Exercise(id: 'e1', name: 'Squat', sets: '3', reps: '5', rpe: ''),
          Exercise(id: 'e2', name: 'Bench', sets: '3', reps: '8', rpe: ''),
        ],
      );
      final dayB = const Day(
        id: 'd1',
        name: 'Day A',
        exercises: [
          Exercise(id: 'e1', name: 'Squat', sets: '3', reps: '5', rpe: ''),
        ],
      );
      final result = diffWorkoutRoutines(
        planA: _routine(weeks: [Week(id: 'w1', name: 'Week 1', days: [dayA])]),
        planB: _routine(weeks: [Week(id: 'w1', name: 'Week 1', days: [dayB])]),
      );

      expect(result.removedExerciseCount, 1);
      final exerciseDiffs = result.weekDiffs.single.dayDiffs.single.exerciseDiffs;
      expect(exerciseDiffs, hasLength(2));
      expect(
        exerciseDiffs.firstWhere((e) => e.name == 'Bench').kind,
        WorkoutRoutineDiffKind.removed,
      );
      expect(
        exerciseDiffs.firstWhere((e) => e.name == 'Squat').kind,
        WorkoutRoutineDiffKind.unchanged,
      );
    });

    test('matches renamed exercise by id and detects set changes', () {
      final dayA = const Day(
        id: 'd1',
        name: 'Day A',
        exercises: [
          Exercise(
            id: 'e1',
            name: 'Back Squat',
            sets: '3',
            reps: '5',
            rpe: '100kg',
          ),
        ],
      );
      final dayB = const Day(
        id: 'd1',
        name: 'Day A',
        exercises: [
          Exercise(
            id: 'e1',
            name: 'Squat',
            sets: '3',
            reps: '5',
            rpe: '105kg',
          ),
        ],
      );
      final result = diffWorkoutRoutines(
        planA: _routine(weeks: [Week(id: 'w1', name: 'Week 1', days: [dayA])]),
        planB: _routine(weeks: [Week(id: 'w1', name: 'Week 1', days: [dayB])]),
      );

      final exerciseDiff =
          result.weekDiffs.single.dayDiffs.single.exerciseDiffs.single;
      expect(exerciseDiff.kind, WorkoutRoutineDiffKind.changed);
      expect(exerciseDiff.name, 'Squat');
      final setDiff = exerciseDiff.setDiffs.single;
      expect(setDiff.kind, WorkoutRoutineDiffKind.changed);
      expect(setDiff.before?.rpe, '100kg');
      expect(setDiff.after?.rpe, '105kg');
    });

    test('matches exercise by normalized name when id differs', () {
      final dayA = const Day(
        id: 'd1',
        name: 'Day A',
        exercises: [
          Exercise(id: '', name: 'Deadlift', sets: '3', reps: '5', rpe: ''),
        ],
      );
      final dayB = const Day(
        id: 'd1',
        name: 'Day A',
        exercises: [
          Exercise(id: '', name: ' deadlift ', sets: '3', reps: '6', rpe: ''),
        ],
      );
      final result = diffWorkoutRoutines(
        planA: _routine(weeks: [Week(id: 'w1', name: 'Week 1', days: [dayA])]),
        planB: _routine(weeks: [Week(id: 'w1', name: 'Week 1', days: [dayB])]),
      );

      final exerciseDiffs = result.weekDiffs.single.dayDiffs.single.exerciseDiffs;
      expect(exerciseDiffs, hasLength(1));
      expect(exerciseDiffs.single.kind, WorkoutRoutineDiffKind.changed);
    });

    test('detects a coaching note change on a matched day', () {
      final dayA = const Day(
        id: 'd1',
        name: 'Day A',
        exercises: [],
        coachingNote: 'Warm up 10 min',
      );
      final dayB = const Day(
        id: 'd1',
        name: 'Day A',
        exercises: [],
        coachingNote: 'Warm up 15 min, focus on hips',
      );
      final result = diffWorkoutRoutines(
        planA: _routine(weeks: [Week(id: 'w1', name: 'Week 1', days: [dayA])]),
        planB: _routine(weeks: [Week(id: 'w1', name: 'Week 1', days: [dayB])]),
      );

      final dayDiff = result.weekDiffs.single.dayDiffs.single;
      expect(dayDiff.coachingNoteChanged, isTrue);
      expect(dayDiff.kind, WorkoutRoutineDiffKind.changed);
      expect(result.hasChanges, isTrue);
    });

    test('detects a removed week when plan B has fewer weeks', () {
      final planA = _routine(
        weeks: [
          const Week(id: 'w1', name: 'Week 1', days: []),
          const Week(id: 'w2', name: 'Week 2', days: []),
        ],
      );
      final planB = _routine(
        weeks: [const Week(id: 'w1', name: 'Week 1', days: [])],
      );

      final result = diffWorkoutRoutines(planA: planA, planB: planB);

      expect(result.weekDiffs, hasLength(2));
      expect(result.weekDiffs[1].kind, WorkoutRoutineDiffKind.removed);
    });

    test('detects density block rounds changed', () {
      final dayA = Day(
        id: 'd1',
        name: 'Day A',
        exercises: const [],
        densityBlocks: {
          'ss_1': const DensityBlockConfig(
            type: DensityBlockType.circuit,
            rounds: 3,
            restSeconds: 90,
          ),
        },
      );
      final dayB = Day(
        id: 'd1',
        name: 'Day A',
        exercises: const [],
        densityBlocks: {
          'ss_1': const DensityBlockConfig(
            type: DensityBlockType.circuit,
            rounds: 4,
            restSeconds: 90,
          ),
        },
      );
      final result = diffWorkoutRoutines(
        planA: _routine(weeks: [Week(id: 'w1', name: 'Week 1', days: [dayA])]),
        planB: _routine(weeks: [Week(id: 'w1', name: 'Week 1', days: [dayB])]),
      );

      final dayDiff = result.weekDiffs.single.dayDiffs.single;
      expect(dayDiff.kind, WorkoutRoutineDiffKind.changed);
      expect(dayDiff.densityBlockDiffs, hasLength(1));
      final densityDiff = dayDiff.densityBlockDiffs.single;
      expect(densityDiff.groupId, 'ss_1');
      expect(densityDiff.kind, WorkoutRoutineDiffKind.changed);
      expect(densityDiff.before?.rounds, 3);
      expect(densityDiff.after?.rounds, 4);
    });

    test('detects density block added', () {
      final dayA = const Day(id: 'd1', name: 'Day A', exercises: []);
      final dayB = Day(
        id: 'd1',
        name: 'Day A',
        exercises: const [],
        densityBlocks: {
          'ss_new': const DensityBlockConfig(
            type: DensityBlockType.emom,
            intervalSeconds: 60,
          ),
        },
      );
      final result = diffWorkoutRoutines(
        planA: _routine(weeks: [Week(id: 'w1', name: 'Week 1', days: [dayA])]),
        planB: _routine(weeks: [Week(id: 'w1', name: 'Week 1', days: [dayB])]),
      );

      final densityDiff =
          result.weekDiffs.single.dayDiffs.single.densityBlockDiffs.single;
      expect(densityDiff.kind, WorkoutRoutineDiffKind.added);
      expect(densityDiff.after?.type, DensityBlockType.emom);
    });

    test('detects density block removed', () {
      final dayA = Day(
        id: 'd1',
        name: 'Day A',
        exercises: const [],
        densityBlocks: {
          'ss_old': const DensityBlockConfig(
            type: DensityBlockType.circuit,
            rounds: 3,
          ),
        },
      );
      final dayB = const Day(id: 'd1', name: 'Day A', exercises: []);
      final result = diffWorkoutRoutines(
        planA: _routine(weeks: [Week(id: 'w1', name: 'Week 1', days: [dayA])]),
        planB: _routine(weeks: [Week(id: 'w1', name: 'Week 1', days: [dayB])]),
      );

      final densityDiff =
          result.weekDiffs.single.dayDiffs.single.densityBlockDiffs.single;
      expect(densityDiff.kind, WorkoutRoutineDiffKind.removed);
      expect(densityDiff.before?.rounds, 3);
    });
  });
}
