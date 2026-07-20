import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_split_presets.dart';

void main() {
  group('buildWorkoutRoutineSkeleton', () {
    test('creates requested weeks and days with upper/lower names', () {
      final routine = buildWorkoutRoutineSkeleton(
        planName: 'Test plan',
        weekCount: 2,
        daysPerWeek: 4,
        preset: WorkoutSplitPreset.upperLower,
      );

      expect(routine.name, 'Test plan');
      expect(routine.weeks, hasLength(2));
      expect(routine.weeks.first.days, hasLength(4));
      expect(routine.weeks.first.days[0].name, 'Upper');
      expect(routine.weeks.first.days[1].name, 'Lower');
      expect(routine.weeks.first.days[0].exercises, isEmpty);
    });

    test('push pull legs cycles day names', () {
      final routine = buildWorkoutRoutineSkeleton(
        planName: 'PPL',
        weekCount: 1,
        daysPerWeek: 3,
        preset: WorkoutSplitPreset.pushPullLegs,
      );

      expect(routine.weeks.single.days.map((d) => d.name), [
        'Push 1',
        'Pull 1',
        'Legs 1',
      ]);
    });
  });
}
