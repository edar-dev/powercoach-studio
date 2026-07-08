import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_item.dart';
import 'package:powercoach_studio/features/workouts/domain/exercise_load_percent_helpers.dart';
import 'package:powercoach_studio/features/workouts/domain/exercise_picker_index_helpers.dart';

CustomExerciseItem _item({
  required String id,
  required String name,
  List<CustomExerciseItem> children = const [],
}) {
  final now = DateTime(2026, 1, 1);
  return CustomExerciseItem(
    id: id,
    name: name,
    createdAt: now,
    updatedAt: now,
    children: children,
  );
}

void main() {
  group('exercise load percent helpers', () {
    test('detects mass units', () {
      expect(isMassBasedExerciseRecordUnit('kg'), isTrue);
      expect(isMassBasedExerciseRecordUnit('reps'), isFalse);
    });

    test('formats rounded loads', () {
      expect(formatExerciseLoadForDisplay(75.0), '75');
      expect(formatExerciseLoadForDisplay(82.55), '82.6');
    });
  });

  group('exercise picker index helpers', () {
    test('builds depth and parent name maps', () {
      final index = buildExercisePickerIndex([
        _item(
          id: 'root',
          name: 'Squat',
          children: [_item(id: 'var', name: 'High bar')],
        ),
      ]);

      expect(index.flat, hasLength(2));
      expect(index.depthById['var'], 1);
      expect(exercisePickerDisplayName(index.flat[1], index.parentNameById),
          'Squat › High bar');
    });

    test('sorts pinned and recent before alphabetical', () {
      final flat = [
        _item(id: 'a', name: 'Alpha'),
        _item(id: 'b', name: 'Beta'),
        _item(id: 'c', name: 'Charlie'),
      ];
      final sorted = sortExercisePickerOptions(
        flat: flat,
        pinnedIds: {'c'},
        recentIds: ['b'],
        displayName: (e) => e.name,
      );
      expect(sorted.map((e) => e.id), ['c', 'b', 'a']);
    });
  });
}
