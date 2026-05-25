import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/integrations/hevy/data/hevy_api_models.dart';

void main() {
  group('parseHevyCreatedRoutineId', () {
    test('reads id from wrapped routine object', () {
      expect(
        parseHevyCreatedRoutineId({
          'routine': {'id': 42, 'title': 'Leg day'},
        }),
        '42',
      );
    });

    test('reads id when routine is a single-element list', () {
      expect(
        parseHevyCreatedRoutineId({
          'routine': [
            {'id': 'abc-123', 'title': 'Push'},
          ],
        }),
        'abc-123',
      );
    });

    test('reads id from unwrapped routine body', () {
      expect(
        parseHevyCreatedRoutineId({
          'id': 'direct-id',
          'title': 'Bench',
          'exercises': [],
        }),
        'direct-id',
      );
    });

    test('returns null when id cannot be resolved', () {
      expect(parseHevyCreatedRoutineId({'routine': []}), isNull);
      expect(parseHevyCreatedRoutineId({}), isNull);
    });
  });

  group('parseHevyCreatedWorkoutId', () {
    test('reads id from wrapped workout object', () {
      expect(
        parseHevyCreatedWorkoutId({
          'workout': {'id': 99, 'title': 'Leg day'},
        }),
        '99',
      );
    });

    test('reads id when workout is a single-element list', () {
      expect(
        parseHevyCreatedWorkoutId({
          'workout': [
            {'id': 'workout-7', 'title': 'Push'},
          ],
        }),
        'workout-7',
      );
    });

    test('reads id from unwrapped workout body', () {
      expect(
        parseHevyCreatedWorkoutId({
          'id': 'direct-workout',
          'start_time': '2025-01-01T00:00:00Z',
          'exercises': [],
        }),
        'direct-workout',
      );
    });

    test('returns null when id cannot be resolved', () {
      expect(parseHevyCreatedWorkoutId({'workout': []}), isNull);
      expect(parseHevyCreatedWorkoutId({}), isNull);
    });
  });
}
