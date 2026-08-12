import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/domain/density_block.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';

void main() {
  group('DensityBlockConfig', () {
    test('round-trip encode/decode preserves fields', () {
      const config = DensityBlockConfig(
        type: DensityBlockType.circuit,
        rounds: 3,
        restSeconds: 90,
      );
      final restored = DensityBlockConfig.fromJson(config.toJson());
      expect(restored, config);
    });

    test('unknown type falls back to superset', () {
      final restored = DensityBlockConfig.fromJson({
        'type': 'tabata',
        'rounds': 2,
      });
      expect(restored.type, DensityBlockType.superset);
      expect(restored.rounds, 2);
    });

    test('omits null optional fields from json', () {
      const config = DensityBlockConfig(
        type: DensityBlockType.emom,
        intervalSeconds: 60,
      );
      final json = config.toJson();
      expect(json['type'], 'emom');
      expect(json['intervalSeconds'], 60);
      expect(json.containsKey('durationMinutes'), isFalse);
      expect(json.containsKey('rounds'), isFalse);
    });

    test('densityBlockSubtitle formats circuit and emom', () {
      expect(
        densityBlockSubtitle(
          const DensityBlockConfig(
            type: DensityBlockType.circuit,
            rounds: 3,
            restSeconds: 90,
          ),
        ),
        '3 rounds · 90s rest',
      );
      expect(
        densityBlockSubtitle(
          const DensityBlockConfig(
            type: DensityBlockType.emom,
            intervalSeconds: 60,
            durationMinutes: 12,
          ),
        ),
        'EMOM 60s · 12 min',
      );
      expect(
        densityBlockSubtitle(
          const DensityBlockConfig(type: DensityBlockType.superset),
        ),
        '',
      );
    });

    test('resolveDensityBlock reads day map', () {
      const day = Day(
        id: 'd1',
        name: 'Day',
        exercises: [],
        densityBlocks: {
          'ss_1': DensityBlockConfig.defaultCircuit,
        },
      );
      expect(resolveDensityBlock(day, 'ss_1')?.type, DensityBlockType.circuit);
      expect(resolveDensityBlock(day, 'missing'), isNull);
    });

    test('densityBlockExportDetail and Hevy prefix format circuit', () {
      const config = DensityBlockConfig(
        type: DensityBlockType.circuit,
        rounds: 3,
        restSeconds: 90,
      );
      expect(densityBlockExportDetail(config), '3× · 90s');
      expect(
        formatDensityBlockExportLine(config, typeLabel: 'Circuit'),
        'Circuit · 3× · 90s',
      );

      const day = Day(
        id: 'd1',
        name: 'Day',
        exercises: [
          Exercise(
            id: 'e1',
            name: 'A',
            sets: '1',
            reps: '8',
            rpe: '',
            supersetGroupId: 'ss_1',
          ),
        ],
        densityBlocks: {'ss_1': config},
      );
      expect(
        densityBlockHevyNotePrefix(day, day.exercises),
        'Circuit · 3× · 90s',
      );
    });
  });
}
