import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_session_controller.dart';

void main() {
  WorkoutRoutine routineWithTwoDays() {
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
            Day(id: 'd2', name: 'Day B', exercises: []),
          ],
        ),
      ],
    );
  }

  group('WorkoutBuilderSessionController', () {
    test('setRoutine clamps selected week and day', () {
      final controller = WorkoutBuilderSessionController(
        routine: routineWithTwoDays(),
      );
      addTearDown(controller.dispose);

      controller.setRoutine(
        routineWithTwoDays(),
        selectedWeekIndex: 99,
        selectedDayIndex: 99,
      );

      expect(controller.selectedWeekIndex, 0);
      expect(controller.selectedDayIndex, 1);
    });

    test('addWeek selects the new week', () {
      final controller = WorkoutBuilderSessionController(
        routine: routineWithTwoDays(),
      );
      addTearDown(controller.dispose);

      controller.addWeek(
        weekId: 'w2',
        weekName: 'Week 2',
        firstDayId: 'w2-d1',
        firstDayName: 'Day 1',
      );

      expect(controller.routine.weeks, hasLength(2));
      expect(controller.selectedWeekIndex, 1);
      expect(controller.selectedDayIndex, 0);
    });

    test('deleteDay keeps selection in range', () {
      final controller = WorkoutBuilderSessionController(
        routine: routineWithTwoDays(),
      );
      addTearDown(controller.dispose);
      controller.selectDay(1);

      final deleted = controller.deleteDay(0, 1);

      expect(deleted, isTrue);
      expect(controller.selectedDayIndex, 0);
    });

    test('exercise mutations update routine through controller', () {
      final controller = WorkoutBuilderSessionController(
        routine: routineWithTwoDays(),
      );
      addTearDown(controller.dispose);

      final added = controller.addExerciseToDay(
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
      final moved = controller.moveExercise(
        weekIndex: 0,
        dayIndex: 0,
        exerciseId: 'e2',
        up: true,
      );

      expect(added, isTrue);
      expect(moved, isTrue);
      expect(
        controller.routine.weeks.single.days.first.exercises.map((e) => e.id),
        ['e2', 'e1'],
      );
    });

    test('duplicateExercise appends a copied exercise with a new id', () {
      final controller = WorkoutBuilderSessionController(
        routine: routineWithTwoDays(),
      );
      addTearDown(controller.dispose);
      final source =
          controller.routine.weeks.single.days.first.exercises.single;

      final duplicated = controller.duplicateExercise(
        weekIndex: 0,
        dayIndex: 0,
        source: source,
        newExerciseId: 'e-copy',
      );

      final exercises = controller.routine.weeks.single.days.first.exercises;
      expect(duplicated, isTrue);
      expect(exercises, hasLength(2));
      expect(exercises.last.id, 'e-copy');
      expect(exercises.last.name, source.name);
    });

    test('setDayScheduledWeekday updates the selected day', () {
      final controller = WorkoutBuilderSessionController(
        routine: routineWithTwoDays(),
      );
      addTearDown(controller.dispose);

      final updated = controller.setDayScheduledWeekday(
        weekIndex: 0,
        dayIndex: 0,
        weekday: DateTime.monday,
      );

      expect(updated, isTrue);
      expect(
        controller.routine.weeks.single.days.first.scheduledWeekday,
        DateTime.monday,
      );
    });

    test('clearDayScheduledWeekday clears the selected day weekday', () {
      final controller = WorkoutBuilderSessionController(
        routine: routineWithTwoDays(),
      );
      addTearDown(controller.dispose);

      controller.setDayScheduledWeekday(
        weekIndex: 0,
        dayIndex: 0,
        weekday: DateTime.wednesday,
      );
      final cleared = controller.clearDayScheduledWeekday(
        weekIndex: 0,
        dayIndex: 0,
      );

      expect(cleared, isTrue);
      expect(
        controller.routine.weeks.single.days.first.scheduledWeekday,
        isNull,
      );
    });
  });
}
