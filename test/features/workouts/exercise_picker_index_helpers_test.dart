import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_item.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/exercise_picker_index_helpers.dart';
import 'package:powercoach_studio/features/workouts/domain/library_exercise_name_enrichment.dart';

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
      expect(exercisePickerDisplayName(index.flat[0], index.parentNameById),
          'Squat');
    });

    test('variant display name keeps base exercise context', () {
      final index = buildExercisePickerIndex([
        _item(
          id: 'gm',
          name: 'Good morning',
          children: [_item(id: 'ssb', name: 'Safety bar')],
        ),
      ]);
      final variant = index.flat.firstWhere((e) => e.id == 'ssb');
      expect(
        exercisePickerDisplayName(variant, index.parentNameById),
        'Good morning › Safety bar',
      );
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

  group('libraryExerciseNamesToEnrich', () {
    test('rewrites bare variant names linked to library parents', () {
      final now = DateTime(2026, 1, 1);
      final roots = [
        CustomExerciseItem(
          id: 'gm',
          name: 'Good morning',
          createdAt: now,
          updatedAt: now,
          children: [
            CustomExerciseItem(
              id: 'ssb',
              name: 'Safety bar',
              parentId: 'gm',
              createdAt: now,
              updatedAt: now,
            ),
          ],
        ),
      ];
      final day = Day(
        id: 'd1',
        name: 'Giorno 1',
        exercises: [
          Exercise(
            id: 'e1',
            name: 'Safety bar',
            sets: '3',
            reps: '10',
            rpe: '',
            customExerciseId: 'ssb',
          ),
          Exercise(
            id: 'e2',
            name: 'Custom rename',
            sets: '1',
            reps: '5',
            rpe: '',
            customExerciseId: 'ssb',
          ),
        ],
      );
      final updates = libraryExerciseNamesToEnrich(
        day: day,
        libraryRoots: roots,
      );
      expect(updates, {'e1': 'Good morning › Safety bar'});
    });
  });
}
