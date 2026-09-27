import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_item.dart';
import 'package:powercoach_studio/features/exercise_library/domain/exercise_catalog_source.dart';
import 'package:powercoach_studio/features/exercise_library/domain/exercise_library_tree_helpers.dart';

CustomExerciseItem _item({
  required String id,
  required String name,
  bool isMobility = false,
  String catalogSource = ExerciseCatalogSource.manual,
  List<CustomExerciseItem> children = const [],
}) {
  final now = DateTime(2026, 1, 1);
  return CustomExerciseItem(
    id: id,
    name: name,
    isMobility: isMobility,
    catalogSource: catalogSource,
    createdAt: now,
    updatedAt: now,
    children: children,
  );
}

void main() {
  group('filterExerciseRootsByMobility', () {
    test('lifts matching descendants when parent category differs', () {
      final roots = [
        _item(
          id: 'root',
          name: 'Standard root',
          isMobility: false,
          children: [
            _item(id: 'mob', name: 'Mobility child', isMobility: true),
          ],
        ),
      ];

      final mobility = filterExerciseRootsByMobility(roots, true);
      expect(mobility, hasLength(1));
      expect(mobility.single.name, 'Mobility child');
    });

    test('keeps matching root when mobility matches', () {
      final roots = [
        _item(
          id: 'root',
          name: 'Strength',
          isMobility: false,
          catalogSource: ExerciseCatalogSource.powercoach,
          children: [
            _item(id: 'child', name: 'Child', isMobility: false),
          ],
        ),
      ];

      final strength = filterExerciseRootsByMobility(roots, false);
      expect(strength, hasLength(1));
      expect(strength.single.name, 'Strength');
    });
  });

  group('flattenExerciseTree', () {
    test('returns all nodes depth-first', () {
      final roots = [
        _item(
          id: 'a',
          name: 'A',
          children: [_item(id: 'b', name: 'B')],
        ),
      ];

      expect(flattenExerciseTree(roots).map((e) => e.id), ['a', 'b']);
    });
  });

  group('filterExerciseTreeByQuery', () {
    test('keeps ancestors of matching leaves', () {
      final roots = [
        _item(
          id: 'squat',
          name: 'Squat',
          children: [
            _item(id: 'low', name: 'Low bar squat'),
            _item(id: 'front', name: 'Front squat'),
          ],
        ),
        _item(id: 'bench', name: 'Bench press'),
      ];

      final filtered = filterExerciseTreeByQuery(roots, 'low bar');
      expect(filtered, hasLength(1));
      expect(filtered.single.id, 'squat');
      expect(filtered.single.children.map((e) => e.id), ['low']);
    });

    test('keeps full children when parent name matches', () {
      final roots = [
        _item(
          id: 'squat',
          name: 'Squat',
          children: [
            _item(id: 'low', name: 'Low bar'),
            _item(id: 'high', name: 'High bar'),
          ],
        ),
      ];

      final filtered = filterExerciseTreeByQuery(roots, 'squat');
      expect(filtered, hasLength(1));
      expect(filtered.single.children.map((e) => e.id), ['low', 'high']);
    });

    test('returns empty when nothing matches', () {
      final roots = [_item(id: 'a', name: 'Curl')];
      expect(filterExerciseTreeByQuery(roots, 'squat'), isEmpty);
    });

    test('trims and ignores empty query', () {
      final roots = [_item(id: 'a', name: 'Curl')];
      expect(filterExerciseTreeByQuery(roots, '  '), same(roots));
    });
  });

  group('sortExerciseTree', () {
    test('keeps pinned roots first then alphabetical', () {
      final roots = [
        _item(id: 'b', name: 'Bench'),
        _item(id: 'a', name: 'Squat'),
        _item(id: 'c', name: 'Curl'),
      ];

      final sorted = sortExerciseTree(
        roots,
        mode: ExerciseLibrarySortMode.alphabetical,
        isPinned: (item) => item.id == 'c',
      );
      expect(sorted.map((e) => e.id), ['c', 'b', 'a']);
    });

    test('sorts by variant count descending', () {
      final roots = [
        _item(
          id: 'a',
          name: 'Alpha',
          children: [_item(id: 'a1', name: 'A1')],
        ),
        _item(
          id: 'b',
          name: 'Beta',
          children: [
            _item(id: 'b1', name: 'B1'),
            _item(id: 'b2', name: 'B2'),
          ],
        ),
      ];

      final sorted = sortExerciseTree(
        roots,
        mode: ExerciseLibrarySortMode.variantCount,
        isPinned: (_) => false,
      );
      expect(sorted.map((e) => e.id), ['b', 'a']);
    });
  });
}
