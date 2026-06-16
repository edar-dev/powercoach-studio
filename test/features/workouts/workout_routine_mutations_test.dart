import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_routine_mutations.dart';

void main() {
  group('cloneWeekInRoutine', () {
    test('deep-copies week days and exercises with new ids', () {
      final routine = WorkoutRoutine.empty().copyWith(
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
                    rpe: '@8',
                    setDetails: [ExerciseSet(reps: '8', rpe: '@8')],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      final cloned = cloneWeekInRoutine(
        routine: routine,
        weekIndex: 0,
        newWeekName: 'Week 1 (copy)',
        newWeekId: 'w2',
      );

      expect(cloned, isNotNull);
      expect(cloned!.weeks, hasLength(2));
      expect(cloned.weeks.last.name, 'Week 1 (copy)');
      expect(cloned.weeks.last.id, 'w2');
      expect(cloned.weeks.last.days.single.id, 'w2_d_d1');
      final exercise = cloned.weeks.last.days.single.exercises.single;
      expect(exercise.id, 'e1_w2');
      expect(exercise.name, 'Squat');
      expect(exercise.setDetails, isNotNull);
      expect(exercise.setDetails!.single.reps, '8');
      expect(cloned.weeks.first.days.single.exercises.single.id, 'e1');
    });

    test('returns null for invalid week index', () {
      final routine = WorkoutRoutine.empty();
      expect(
        cloneWeekInRoutine(
          routine: routine,
          weekIndex: 0,
          newWeekName: 'Copy',
          newWeekId: 'w2',
        ),
        isNull,
      );
    });
  });

  group('week/day structure mutations', () {
    late WorkoutRoutine routine;

    setUp(() {
      routine = WorkoutRoutine.empty().copyWith(
        weeks: WorkoutRoutine.defaultWeeks(),
      );
    });

    test('addWeekToRoutine appends a week with one day', () {
      final updated = addWeekToRoutine(
        routine: routine,
        weekId: 'w_new',
        weekName: 'Week 2',
        firstDayId: 'w_new_d1',
        firstDayName: 'Day 1',
      );
      expect(updated.weeks, hasLength(2));
      expect(updated.weeks.last.name, 'Week 2');
      expect(updated.weeks.last.days, hasLength(1));
    });

    test('deleteWeekFromRoutine removes week by index', () {
      final withTwo = addWeekToRoutine(
        routine: routine,
        weekId: 'w2',
        weekName: 'Week 2',
        firstDayId: 'w2_d1',
        firstDayName: 'Day 1',
      );
      final updated = deleteWeekFromRoutine(routine: withTwo, weekIndex: 1);
      expect(updated!.weeks, hasLength(1));
      expect(updated.weeks.single.id, withTwo.weeks.first.id);
    });

    test('deleteDayFromRoutine keeps at least one day', () {
      final week = routine.weeks.single;
      expect(
        deleteDayFromRoutine(routine: routine, weekIndex: 0, dayIndex: 0),
        isNull,
      );
      final withTwoDays = routine.copyWith(
        weeks: [
          week.copyWith(
            days: [
              ...week.days,
              Day(id: 'd2', name: 'Day 2', exercises: const []),
            ],
          ),
        ],
      );
      final updated = deleteDayFromRoutine(
        routine: withTwoDays,
        weekIndex: 0,
        dayIndex: 1,
      );
      expect(updated!.weeks.single.days, hasLength(1));
    });

    test('renameWeekInRoutine and renameDayInRoutine trim names', () {
      final renamedWeek = renameWeekInRoutine(
        routine: routine,
        weekIndex: 0,
        newName: '  Strength  ',
      );
      expect(renamedWeek!.weeks.single.name, 'Strength');

      final renamedDay = renameDayInRoutine(
        routine: routine,
        weekIndex: 0,
        dayIndex: 0,
        newName: '  Push  ',
      );
      expect(renamedDay!.weeks.single.days.single.name, 'Push');
    });

    test('setDayScheduledWeekdayInRoutine updates weekday', () {
      final updated = setDayScheduledWeekdayInRoutine(
        routine: routine,
        weekIndex: 0,
        dayIndex: 0,
        weekday: DateTime.wednesday,
      );
      expect(
        updated!.weeks.single.days.single.scheduledWeekday,
        DateTime.wednesday,
      );
    });
  });
}
