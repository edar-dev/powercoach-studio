import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_item.dart';
import 'package:powercoach_studio/features/exercise_library/domain/exercise_library_tree_helpers.dart';
import 'package:powercoach_studio/features/integrations/hevy/domain/exercise_catalog_source.dart';

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

    test('excludes hevy catalog nodes from mobility filter', () {
      final roots = [
        _item(
          id: 'hevy',
          name: 'Hevy',
          catalogSource: ExerciseCatalogSource.hevy,
          children: [
            _item(id: 'child', name: 'Child', isMobility: false),
          ],
        ),
      ];

      expect(filterExerciseRootsByMobility(roots, false), isEmpty);
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
}
