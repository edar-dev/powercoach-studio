import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_routine_plan_encoder.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_load_helpers.dart';

void main() {
  WorkoutRoutine routineWithTwoDays() {
    return WorkoutRoutine.empty().copyWith(
      weeks: [
        const Week(
          id: 'w1',
          name: 'Week 1',
          days: [
            Day(id: 'd1', name: 'Day A', exercises: []),
            Day(id: 'd2', name: 'Day B', exercises: []),
          ],
        ),
      ],
    );
  }

  group('resolveWorkoutBuilderDeepLinkSelection', () {
    test('returns null when week or day query is missing', () {
      final routine = routineWithTwoDays();

      expect(
        resolveWorkoutBuilderDeepLinkSelection(routine),
        isNull,
      );
      expect(
        resolveWorkoutBuilderDeepLinkSelection(
          routine,
          pendingWeekIndex: 0,
        ),
        isNull,
      );
    });

    test('returns null when week index is out of range', () {
      final routine = routineWithTwoDays();

      expect(
        resolveWorkoutBuilderDeepLinkSelection(
          routine,
          pendingWeekIndex: 3,
          pendingDayIndex: 0,
        ),
        isNull,
      );
    });

    test('clamps invalid day index to zero within the week', () {
      final routine = routineWithTwoDays();

      expect(
        resolveWorkoutBuilderDeepLinkSelection(
          routine,
          pendingWeekIndex: 0,
          pendingDayIndex: 9,
        ),
        const WorkoutBuilderWeekDaySelection(0, 0),
      );
    });

    test('returns requested week and day when valid', () {
      final routine = routineWithTwoDays();

      expect(
        resolveWorkoutBuilderDeepLinkSelection(
          routine,
          pendingWeekIndex: 0,
          pendingDayIndex: 1,
        ),
        const WorkoutBuilderWeekDaySelection(0, 1),
      );
    });
  });

  group('buildEditorPlanSnapshot', () {
    test('hydrates routine metadata and deep-link selection', () {
      final routine = routineWithTwoDays().copyWith(name: 'Loaded plan');
      final plan = WorkoutPlanApiModel(
        id: 'plan-1',
        customerId: 'cust-1',
        userId: 'user-1',
        name: 'Plan A',
        initialWeekNumber: 2,
        phase: 'Hypertrophy',
        tags: 'tag',
        notes: 'note',
        planData: encodeWorkoutRoutinePlanData(routine),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      final snapshot = buildEditorPlanSnapshot(
        plan,
        pendingWeekIndex: 0,
        pendingDayIndex: 1,
      );

      expect(snapshot.planId, 'plan-1');
      expect(snapshot.initialWeekNumber, 2);
      expect(snapshot.phase, 'Hypertrophy');
      expect(snapshot.tags, 'tag');
      expect(snapshot.notes, 'note');
      expect(snapshot.weekIndex, 0);
      expect(snapshot.dayIndex, 1);
      expect(snapshot.routine.name, 'Loaded plan');
      expect(snapshot.planCompleted, isFalse);
      expect(snapshot.planArchived, isFalse);
    });
  });
}
