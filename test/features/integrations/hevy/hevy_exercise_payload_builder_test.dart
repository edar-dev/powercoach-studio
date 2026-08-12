import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/integrations/hevy/domain/hevy_exercise_payload_builder.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/density_block.dart';

void main() {
  group('HevyExercisePayloadBuilder density notes', () {
    final builder = HevyExercisePayloadBuilder();

    test('prepends circuit density line to first exercise notes only', () {
      final day = Day(
        id: 'd1',
        name: 'Day A',
        exercises: const [
          Exercise(
            id: 'e1',
            name: 'Push-up',
            sets: '1',
            reps: '10',
            rpe: '',
            note: 'Chest up',
            supersetGroupId: 'ss_1',
          ),
          Exercise(
            id: 'e2',
            name: 'Row',
            sets: '1',
            reps: '10',
            rpe: '',
            note: 'Squeeze',
            supersetGroupId: 'ss_1',
          ),
        ],
        densityBlocks: {
          'ss_1': const DensityBlockConfig(
            type: DensityBlockType.circuit,
            rounds: 3,
            restSeconds: 90,
          ),
        },
      );

      final payload = builder.buildExercisesForDay(day, {
        'e1': 'tmpl-1',
        'e2': 'tmpl-2',
      });

      expect(payload, hasLength(2));
      expect(
        payload[0]['notes'] as String,
        startsWith('Circuit · 3× · 90s\nChest up'),
      );
      expect(payload[1]['notes'], isNot(contains('Circuit')));
      expect(payload[1]['notes'] as String, contains('Squeeze'));
    });

    test('prepends EMOM density line when present', () {
      final day = Day(
        id: 'd1',
        name: 'Day A',
        exercises: const [
          Exercise(
            id: 'e1',
            name: 'KB Swing',
            sets: '1',
            reps: '10',
            rpe: '',
            note: '',
            supersetGroupId: 'ss_emom',
          ),
          Exercise(
            id: 'e2',
            name: 'Burpee',
            sets: '1',
            reps: '5',
            rpe: '',
            note: '',
            supersetGroupId: 'ss_emom',
          ),
        ],
        densityBlocks: {
          'ss_emom': const DensityBlockConfig(
            type: DensityBlockType.emom,
            intervalSeconds: 60,
            durationMinutes: 12,
          ),
        },
      );

      final payload = builder.buildExercisesForDay(day, {
        'e1': 'tmpl-1',
        'e2': 'tmpl-2',
      });

      expect(
        payload.first['notes'] as String,
        startsWith('EMOM · 60s · 12min'),
      );
      expect(payload[1]['notes'] as String, isNot(startsWith('EMOM')));
    });

    test('omits density prefix for plain supersets without densityBlocks', () {
      final day = const Day(
        id: 'd1',
        name: 'Day A',
        exercises: [
          Exercise(
            id: 'e1',
            name: 'A',
            sets: '1',
            reps: '8',
            rpe: '',
            note: 'note-a',
            supersetGroupId: 'ss_x',
          ),
          Exercise(
            id: 'e2',
            name: 'B',
            sets: '1',
            reps: '8',
            rpe: '',
            note: 'note-b',
            supersetGroupId: 'ss_x',
          ),
        ],
      );

      final payload = builder.buildExercisesForDay(day, {
        'e1': 'tmpl-1',
        'e2': 'tmpl-2',
      });

      expect(payload.first['notes'] as String, isNot(contains('Superset')));
      expect(payload.first['notes'] as String, contains('note-a'));
      expect(payload[1]['notes'] as String, contains('note-b'));
    });
  });
}
