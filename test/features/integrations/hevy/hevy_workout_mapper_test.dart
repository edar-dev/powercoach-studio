import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/integrations/hevy/domain/hevy_workout_mapper.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';

void main() {
  group('HevyWorkoutMapper', () {
    final mapper = HevyWorkoutMapper();

    test('buildWorkoutBody includes times and mapped exercises', () {
      final day = Day(
        id: 'day-1',
        name: 'Push',
        exercises: const [
          Exercise(
            id: 'ex-1',
            name: 'Bench Press',
            sets: '3',
            reps: '8',
            rpe: '80kg',
          ),
        ],
      );
      final start = DateTime.utc(2025, 6, 1, 9, 0);
      final end = DateTime.utc(2025, 6, 1, 10, 30);

      final body = mapper.buildWorkoutBody(
        title: 'Program · Push',
        day: day,
        exerciseNameToTemplateId: {'ex-1': 'hevy-tmpl-1'},
        description: 'Exported from PowerCoach Studio',
        startTime: start,
        endTime: end,
      );

      final workout = body['workout'] as Map<String, dynamic>;
      expect(workout['title'], 'Program · Push');
      expect(workout['description'], 'Exported from PowerCoach Studio');
      expect(workout['is_private'], false);
      expect(workout['start_time'], '2025-06-01T09:00:00Z');
      expect(workout['end_time'], '2025-06-01T10:30:00Z');

      final exercises = workout['exercises'] as List<dynamic>;
      expect(exercises, hasLength(1));
      expect(exercises.first['exercise_template_id'], 'hevy-tmpl-1');
      final sets = exercises.first['sets'] as List<dynamic>;
      expect(sets, isNotEmpty);
      expect(sets.first['reps'], 8);
    });
  });
}
