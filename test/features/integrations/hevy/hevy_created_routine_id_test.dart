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
}
