import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_exercise_mutations.dart';

void main() {
  WorkoutRoutine routineWithOneExercise() {
    return WorkoutRoutine.empty().copyWith(
      weeks: [
        const Week(
          id: 'w1',
          name: 'Week 1',
          days: [
            Day(
              id: 'd1',
              name: 'Day A',
              exercises: [
                Exercise(
                  id: 'e1',
                  name: 'Squat',
                  sets: '3',
                  reps: '8',
                  rpe: '',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  group('workout_exercise_mutations', () {
    test('addExerciseToDayInRoutine appends exercise', () {
      final routine = routineWithOneExercise();
      final updated = addExerciseToDayInRoutine(
        routine: routine,
        weekIndex: 0,
        dayIndex: 0,
        exercise: const Exercise(
          id: 'e2',
          name: 'Bench',
          sets: '3',
          reps: '10',
          rpe: '',
        ),
      );
      expect(updated!.weeks.single.days.single.exercises, hasLength(2));
    });

    test('removeExerciseFromDayInRoutine removes only matching exercise', () {
      final routine = addExerciseToDayInRoutine(
        routine: routineWithOneExercise(),
        weekIndex: 0,
        dayIndex: 0,
        exercise: const Exercise(
          id: 'e2',
          name: 'Bench',
          sets: '3',
          reps: '10',
          rpe: '',
        ),
      )!;

      final updated = removeExerciseFromDayInRoutine(
        routine: routine,
        weekIndex: 0,
        dayIndex: 0,
        exerciseId: 'e1',
      );

      final exercises = updated!.weeks.single.days.single.exercises;
      expect(exercises, hasLength(1));
      expect(exercises.single.id, 'e2');
    });

    test('moveExerciseInDayInRoutine ignores boundary moves', () {
      final routine = addExerciseToDayInRoutine(
        routine: routineWithOneExercise(),
        weekIndex: 0,
        dayIndex: 0,
        exercise: const Exercise(
          id: 'e2',
          name: 'Bench',
          sets: '3',
          reps: '10',
          rpe: '',
        ),
      )!;

      final unchanged = moveExerciseInDayInRoutine(
        routine: routine,
        weekIndex: 0,
        dayIndex: 0,
        exerciseId: 'e1',
        up: true,
      );

      expect(unchanged!.weeks.single.days.single.exercises.map((e) => e.id), [
        'e1',
        'e2',
      ]);
    });

    test('moveExerciseInDayInRoutine reorders within a day', () {
      final routine = addExerciseToDayInRoutine(
        routine: routineWithOneExercise(),
        weekIndex: 0,
        dayIndex: 0,
        exercise: const Exercise(
          id: 'e2',
          name: 'Bench',
          sets: '3',
          reps: '10',
          rpe: '',
        ),
      )!;

      final updated = moveExerciseInDayInRoutine(
        routine: routine,
        weekIndex: 0,
        dayIndex: 0,
        exerciseId: 'e2',
        up: true,
      );

      expect(updated!.weeks.single.days.single.exercises.map((e) => e.id), [
        'e2',
        'e1',
      ]);
    });

    test('addExerciseToSupersetInRoutine inserts after group', () {
      final routine = routineWithOneExercise().copyWith(
        weeks: [
          Week(
            id: 'w1',
            name: 'Week 1',
            days: [
              Day(
                id: 'd1',
                name: 'Day A',
                exercises: [
                  const Exercise(
                    id: 'e1',
                    name: 'A',
                    sets: '3',
                    reps: '8',
                    rpe: '',
                    supersetGroupId: 'ss1',
                  ),
                  const Exercise(
                    id: 'e2',
                    name: 'B',
                    sets: '3',
                    reps: '10',
                    rpe: '',
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      final updated = addExerciseToSupersetInRoutine(
        routine: routine,
        weekIndex: 0,
        dayIndex: 0,
        supersetGroupId: 'ss1',
        exercise: const Exercise(
          id: 'e3',
          name: 'C',
          sets: '3',
          reps: '12',
          rpe: '',
          supersetGroupId: 'ss1',
        ),
      );
      final names = updated!.weeks.single.days.single.exercises
          .map((e) => e.name)
          .toList();
      expect(names, ['A', 'C', 'B']);
    });

    test('assign and remove superset group', () {
      final routine = routineWithOneExercise();
      final assigned = assignExerciseToSupersetInRoutine(
        routine: routine,
        weekIndex: 0,
        dayIndex: 0,
        exerciseId: 'e1',
        supersetGroupId: 'ss1',
      );
      expect(
        assigned!.weeks.single.days.single.exercises.single.supersetGroupId,
        'ss1',
      );
      final removed = removeExerciseFromSupersetInRoutine(
        routine: assigned,
        weekIndex: 0,
        dayIndex: 0,
        exerciseId: 'e1',
      );
      expect(
        removed!.weeks.single.days.single.exercises.single.supersetGroupId,
        isNull,
      );
    });

    test('updateExerciseSetInRoutine edits a set line', () {
      final routine = routineWithOneExercise().copyWith(
        weeks: [
          Week(
            id: 'w1',
            name: 'Week 1',
            days: [
              Day(
                id: 'd1',
                name: 'Day A',
                exercises: [
                  const Exercise(
                    id: 'e1',
                    name: 'Squat',
                    sets: '1',
                    reps: '5',
                    rpe: '',
                    setDetails: [ExerciseSet(reps: '5', rpe: '@8')],
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      final updated = updateExerciseSetInRoutine(
        routine: routine,
        weekIndex: 0,
        dayIndex: 0,
        exerciseId: 'e1',
        setIndex: 0,
        line: '3x5 @9',
      );
      expect(
        updated!
            .weeks
            .single
            .days
            .single
            .exercises
            .single
            .setDetails!
            .single
            .line,
        '3x5 @9',
      );
    });

    test('removeExerciseSetInRoutine keeps at least one set', () {
      final routine = routineWithOneExercise().copyWith(
        weeks: [
          Week(
            id: 'w1',
            name: 'Week 1',
            days: [
              Day(
                id: 'd1',
                name: 'Day A',
                exercises: [
                  const Exercise(
                    id: 'e1',
                    name: 'Squat',
                    sets: '1',
                    reps: '5',
                    rpe: '',
                    setDetails: [ExerciseSet(reps: '5')],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      final updated = removeExerciseSetInRoutine(
        routine: routine,
        weekIndex: 0,
        dayIndex: 0,
        exerciseId: 'e1',
        setIndex: 0,
      );

      expect(
        updated!.weeks.single.days.single.exercises.single.effectiveSetDetails,
        hasLength(1),
      );
    });

    test('removeExerciseSetInRoutine removes valid set index', () {
      final routine = routineWithOneExercise().copyWith(
        weeks: [
          Week(
            id: 'w1',
            name: 'Week 1',
            days: [
              Day(
                id: 'd1',
                name: 'Day A',
                exercises: [
                  const Exercise(
                    id: 'e1',
                    name: 'Squat',
                    sets: '2',
                    reps: '5 | 3',
                    rpe: '',
                    setDetails: [
                      ExerciseSet(reps: '5'),
                      ExerciseSet(reps: '3'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      final updated = removeExerciseSetInRoutine(
        routine: routine,
        weekIndex: 0,
        dayIndex: 0,
        exerciseId: 'e1',
        setIndex: 0,
      );

      final sets = updated!
          .weeks
          .single
          .days
          .single
          .exercises
          .single
          .effectiveSetDetails;
      expect(sets, hasLength(1));
      expect(sets.single.reps, '3');
    });
  });
}
