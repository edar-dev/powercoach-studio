import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_routine_coordinator.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_screen_load_handler.dart';

void main() {
  group('WorkoutBuilderEditorLoadApplication', () {
    test('fromResult clears deep link when selection resolves', () {
      final routine = WorkoutRoutine.empty().copyWith(
        weeks: [
          const Week(
            id: 'w1',
            name: 'Week 1',
            days: [
              Day(id: 'd1', name: 'Day 1', exercises: []),
              Day(id: 'd2', name: 'Day 2', exercises: []),
            ],
          ),
        ],
      );
      final result = WorkoutBuilderEditorLoadResult(
        loadedInitialWeek: 2,
        routine: routine,
        weekIndex: 0,
        dayIndex: 1,
        loadedPlanId: 'plan-1',
      );

      final application = WorkoutBuilderEditorLoadApplication.fromResult(
        result,
        pendingWeekIndex: 0,
        pendingDayIndex: 1,
      );

      expect(application.clearDeepLink, isTrue);
      expect(application.loadedPlanId, 'plan-1');
      expect(application.initialWeekNumber, 2);
      expect(application.weekIndex, 0);
      expect(application.dayIndex, 1);
    });

    test('fallback keeps default week selection', () {
      final application = WorkoutBuilderEditorLoadApplication.fallback(
        initialWeekNumber: 3,
      );

      expect(application.routine, isNull);
      expect(application.weekIndex, 0);
      expect(application.dayIndex, 0);
      expect(application.initialWeekNumber, 3);
      expect(application.clearDeepLink, isFalse);
    });
  });
}
