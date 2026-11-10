import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_item.dart';
import 'package:powercoach_studio/features/exercise_library/domain/exercise_autocomplete_filter.dart';
import 'package:powercoach_studio/features/exercise_library/domain/exercise_catalog_source.dart';
import 'package:powercoach_studio/features/exercise_library/domain/exercise_library_tree_helpers.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/exercise_picker_index_helpers.dart';
import 'package:powercoach_studio/features/workouts/domain/library_exercise_name_enrichment.dart';

CustomExerciseItem _item({
  required String id,
  required String name,
  List<CustomExerciseItem> children = const [],
  String catalogSource = ExerciseCatalogSource.manual,
  DateTime? createdAt,
}) {
  final now = createdAt ?? DateTime(2026, 1, 1);
  return CustomExerciseItem(
    id: id,
    name: name,
    catalogSource: catalogSource,
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

    test('dedupes same id then collapses duplicate powercoach display paths',
        () {
      final older = DateTime(2025, 1, 1);
      final newer = DateTime(2026, 6, 1);
      final flat = [
        _item(
          id: 'squat-a',
          name: 'Squat',
          catalogSource: ExerciseCatalogSource.powercoach,
          createdAt: older,
        ),
        _item(
          id: 'squat-a',
          name: 'Squat',
          catalogSource: ExerciseCatalogSource.powercoach,
          createdAt: older,
        ),
        _item(
          id: 'hb-a',
          name: 'High bar',
          catalogSource: ExerciseCatalogSource.powercoach,
          createdAt: older,
        ),
        _item(
          id: 'squat-b',
          name: 'Squat',
          catalogSource: ExerciseCatalogSource.powercoach,
          createdAt: newer,
        ),
        _item(
          id: 'hb-b',
          name: 'High bar',
          catalogSource: ExerciseCatalogSource.powercoach,
          createdAt: newer,
        ),
      ];
      final parentNameById = {
        'hb-a': 'Squat',
        'hb-b': 'Squat',
      };

      final deduped = dedupeExercisePickerFlat(
        flat,
        parentNameById: parentNameById,
      );

      expect(deduped.map((e) => e.id), ['squat-a', 'hb-a']);
    });

    test('keeps manual exercises with the same display name', () {
      final flat = [
        _item(id: 'manual-1', name: 'Custom squat'),
        _item(id: 'manual-2', name: 'Custom squat'),
      ];

      final deduped = dedupeExercisePickerFlat(
        flat,
        parentNameById: const {},
      );

      expect(deduped.map((e) => e.id), ['manual-1', 'manual-2']);
    });

    test('buildExercisePickerIndex collapses duplicate powercoach squat trees',
        () {
      final older = DateTime(2025, 1, 1);
      final newer = DateTime(2026, 6, 1);
      final index = buildExercisePickerIndex([
        _item(
          id: 'squat-a',
          name: 'Squat',
          catalogSource: ExerciseCatalogSource.powercoach,
          createdAt: older,
          children: [
            _item(
              id: 'hb-a',
              name: 'High bar',
              catalogSource: ExerciseCatalogSource.powercoach,
              createdAt: older,
            ),
          ],
        ),
        _item(
          id: 'squat-b',
          name: 'Squat',
          catalogSource: ExerciseCatalogSource.powercoach,
          createdAt: newer,
          children: [
            _item(
              id: 'hb-b',
              name: 'High bar',
              catalogSource: ExerciseCatalogSource.powercoach,
              createdAt: newer,
            ),
          ],
        ),
        _item(id: 'manual-1', name: 'Squat'),
        _item(id: 'manual-2', name: 'Squat'),
      ]);

      expect(index.flat.map((e) => e.id).toList(), [
        'squat-a',
        'hb-a',
        'manual-1',
        'manual-2',
      ]);

      final filtered = filterExercisesByQuery(
        query: 'squat',
        options: index.flat,
        displayName: (e) => exercisePickerDisplayName(e, index.parentNameById),
      ).toList();

      expect(filtered.map((e) => e.id).toSet().length, filtered.length);
      expect(
        filtered
            .where((e) => e.catalogSource == ExerciseCatalogSource.powercoach)
            .map((e) => exercisePickerDisplayName(e, index.parentNameById))
            .toSet()
            .length,
        filtered
            .where((e) => e.catalogSource == ExerciseCatalogSource.powercoach)
            .length,
      );
      expect(
        filtered.where((e) => e.catalogSource == ExerciseCatalogSource.manual),
        hasLength(2),
      );
      expect(index.treeRoots.map((e) => e.id), ['squat-a', 'manual-1', 'manual-2']);
      expect(index.treeRoots.first.children.map((e) => e.id), ['hb-a']);
    });
  });

  group('buildParentSelectionIndex', () {
    test('matches picker depth and parentName maps without excludes', () {
      final roots = [
        _item(
          id: 'root',
          name: 'Squat',
          children: [_item(id: 'var', name: 'High bar')],
        ),
      ];
      final picker = buildExercisePickerIndex(roots);
      final parent = buildParentSelectionIndex(roots);

      expect(parent.flat.map((e) => e.id), picker.flat.map((e) => e.id));
      expect(parent.depthById, picker.depthById);
      expect(parent.parentNameById, picker.parentNameById);
      expect(
        exercisePickerDisplayName(parent.flat[1], parent.parentNameById),
        'Squat › High bar',
      );
    });

    test('excludeIds removes node and lifts remaining siblings', () {
      final roots = [
        _item(
          id: 'squat',
          name: 'Squat',
          children: [
            _item(id: 'hb', name: 'High bar'),
            _item(id: 'lb', name: 'Low bar'),
          ],
        ),
        _item(id: 'bench', name: 'Bench'),
      ];

      final index = buildParentSelectionIndex(
        roots,
        excludeIds: {'squat', 'hb', 'lb'},
      );

      expect(index.flat.map((e) => e.id), ['bench']);
      expect(index.depthById['bench'], 0);
      expect(index.parentNameById.containsKey('bench'), isFalse);
    });

    test('excludeIds on middle node lifts descendants', () {
      final roots = [
        _item(
          id: 'root',
          name: 'Root',
          children: [
            _item(
              id: 'mid',
              name: 'Mid',
              children: [_item(id: 'leaf', name: 'Leaf')],
            ),
          ],
        ),
      ];

      final index = buildParentSelectionIndex(
        roots,
        excludeIds: {'mid'},
      );

      expect(index.flat.map((e) => e.id), ['root', 'leaf']);
      expect(index.depthById['leaf'], 1);
      expect(index.parentNameById['leaf'], 'Root');
    });

    test('still applies powercoach display-path dedupe', () {
      final older = DateTime(2025, 1, 1);
      final newer = DateTime(2026, 6, 1);
      final roots = [
        _item(
          id: 'squat-a',
          name: 'Squat',
          catalogSource: ExerciseCatalogSource.powercoach,
          createdAt: older,
          children: [
            _item(
              id: 'hb-a',
              name: 'High bar',
              catalogSource: ExerciseCatalogSource.powercoach,
              createdAt: older,
            ),
          ],
        ),
        _item(
          id: 'squat-b',
          name: 'Squat',
          catalogSource: ExerciseCatalogSource.powercoach,
          createdAt: newer,
          children: [
            _item(
              id: 'hb-b',
              name: 'High bar',
              catalogSource: ExerciseCatalogSource.powercoach,
              createdAt: newer,
            ),
          ],
        ),
      ];

      final index = buildParentSelectionIndex(roots);
      expect(index.flat.map((e) => e.id), ['squat-a', 'hb-a']);
    });
  });

  group('pruneExerciseTreeToIds', () {
    test('keeps parent with pruned children', () {
      final roots = [
        _item(
          id: 'squat',
          name: 'Squat',
          children: [
            _item(id: 'hb', name: 'High bar'),
            _item(id: 'lb', name: 'Low bar'),
          ],
        ),
      ];

      final pruned = pruneExerciseTreeToIds(roots, {'squat', 'hb'});

      expect(pruned, hasLength(1));
      expect(pruned.first.id, 'squat');
      expect(pruned.first.children.map((e) => e.id), ['hb']);
    });

    test('lifts orphan children when parent is dropped', () {
      final roots = [
        _item(
          id: 'parent-drop',
          name: 'Parent',
          children: [
            _item(id: 'child-keep', name: 'Child'),
            _item(
              id: 'mid-drop',
              name: 'Mid',
              children: [_item(id: 'grand-keep', name: 'Grand')],
            ),
          ],
        ),
      ];

      final pruned = pruneExerciseTreeToIds(
        roots,
        {'child-keep', 'grand-keep'},
      );

      expect(pruned.map((e) => e.id), ['child-keep', 'grand-keep']);
      expect(pruned.every((e) => e.children.isEmpty), isTrue);
    });

    test('duplicate powercoach trees prune to kept ids only', () {
      final older = DateTime(2025, 1, 1);
      final newer = DateTime(2026, 6, 1);
      final roots = [
        _item(
          id: 'squat-a',
          name: 'Squat',
          catalogSource: ExerciseCatalogSource.powercoach,
          createdAt: older,
          children: [
            _item(
              id: 'hb-a',
              name: 'High bar',
              catalogSource: ExerciseCatalogSource.powercoach,
              createdAt: older,
            ),
          ],
        ),
        _item(
          id: 'squat-b',
          name: 'Squat',
          catalogSource: ExerciseCatalogSource.powercoach,
          createdAt: newer,
          children: [
            _item(
              id: 'hb-b',
              name: 'High bar',
              catalogSource: ExerciseCatalogSource.powercoach,
              createdAt: newer,
            ),
          ],
        ),
      ];
      final index = buildExercisePickerIndex(roots);
      final keptIds = index.flat.map((e) => e.id).toSet();
      final pruned = pruneExerciseTreeToIds(roots, keptIds);

      expect(pruned.map((e) => e.id), ['squat-a']);
      expect(pruned.single.children.map((e) => e.id), ['hb-a']);
      expect(index.treeRoots.map((e) => e.id), ['squat-a']);
      expect(index.treeRoots.single.children.map((e) => e.id), ['hb-a']);
    });
  });

  group('search filter + expand ids after prune', () {
    test('keeps parent when child matches and marks parents for expand', () {
      final roots = [
        _item(
          id: 'squat',
          name: 'Squat',
          children: [
            _item(id: 'box', name: 'Box squat'),
            _item(id: 'pause', name: 'Pause squat'),
          ],
        ),
        _item(id: 'bench', name: 'Bench press'),
      ];
      final pruned = pruneExerciseTreeToIds(
        roots,
        {'squat', 'box', 'pause', 'bench'},
      );
      final filtered = filterExerciseTreeByQuery(pruned, 'box');

      expect(filtered.map((e) => e.id), ['squat']);
      expect(filtered.single.children.map((e) => e.id), ['box']);
      expect(exercisePickerTreeExpandIds(filtered), {'squat'});
    });

    test('compact/search path uses short names and no duplicate powercoach roots',
        () {
      final older = DateTime(2025, 1, 1);
      final newer = DateTime(2026, 6, 1);
      final index = buildExercisePickerIndex([
        _item(
          id: 'squat-a',
          name: 'Squat con bilanciere',
          catalogSource: ExerciseCatalogSource.powercoach,
          createdAt: older,
          children: [
            _item(
              id: 'hb-a',
              name: 'High bar',
              catalogSource: ExerciseCatalogSource.powercoach,
              createdAt: older,
            ),
          ],
        ),
        _item(
          id: 'squat-b',
          name: 'Squat con bilanciere',
          catalogSource: ExerciseCatalogSource.powercoach,
          createdAt: newer,
          children: [
            _item(
              id: 'hb-b',
              name: 'High bar',
              catalogSource: ExerciseCatalogSource.powercoach,
              createdAt: newer,
            ),
          ],
        ),
      ]);
      final filtered =
          filterExerciseTreeByQuery(index.treeRoots, 'high bar');

      expect(index.treeRoots.map((e) => e.name), ['Squat con bilanciere']);
      expect(filtered, hasLength(1));
      expect(filtered.single.name, 'Squat con bilanciere');
      expect(filtered.single.children.map((e) => e.name), ['High bar']);
      expect(
        flattenExerciseTree(filtered).any((e) => e.name.contains('›')),
        isFalse,
      );
      expect(exercisePickerTreeExpandIds(filtered), {'squat-a'});
    });

    test('sortExercisePickerTree pins roots then sorts children A-Z', () {
      final roots = [
        _item(
          id: 'b',
          name: 'Beta',
          children: [
            _item(id: 'b2', name: 'Zebra'),
            _item(id: 'b1', name: 'Alpha child'),
          ],
        ),
        _item(id: 'a', name: 'Alpha'),
      ];
      final sorted = sortExercisePickerTree(roots, pinnedIds: {'b'});

      expect(sorted.map((e) => e.id), ['b', 'a']);
      expect(sorted.first.children.map((e) => e.id), ['b1', 'b2']);
    });
  });

  group('powercoachIdsToSoftDelete', () {
    test('marks newer duplicate squat trees for soft-delete', () {
      final older = DateTime(2025, 1, 1);
      final newer = DateTime(2026, 6, 1);
      final roots = [
        _item(
          id: 'squat-a',
          name: 'Squat con bilanciere',
          catalogSource: ExerciseCatalogSource.powercoach,
          createdAt: older,
          children: [
            _item(
              id: 'hb-a',
              name: 'High bar',
              catalogSource: ExerciseCatalogSource.powercoach,
              createdAt: older,
            ),
            _item(
              id: 'lb-a',
              name: 'Low bar',
              catalogSource: ExerciseCatalogSource.powercoach,
              createdAt: older,
            ),
          ],
        ),
        _item(
          id: 'squat-b',
          name: 'Squat con bilanciere',
          catalogSource: ExerciseCatalogSource.powercoach,
          createdAt: newer,
          children: [
            _item(
              id: 'hb-b',
              name: 'High bar',
              catalogSource: ExerciseCatalogSource.powercoach,
              createdAt: newer,
            ),
            _item(
              id: 'lb-b',
              name: 'Low bar',
              catalogSource: ExerciseCatalogSource.powercoach,
              createdAt: newer,
            ),
          ],
        ),
      ];

      expect(
        powercoachIdsToSoftDelete(roots),
        {'squat-b', 'hb-b', 'lb-b'},
      );
    });

    test('keeps smaller id when createdAt ties', () {
      final created = DateTime(2025, 1, 1);
      final roots = [
        _item(
          id: 'squat-z',
          name: 'Squat',
          catalogSource: ExerciseCatalogSource.powercoach,
          createdAt: created,
        ),
        _item(
          id: 'squat-a',
          name: 'Squat',
          catalogSource: ExerciseCatalogSource.powercoach,
          createdAt: created,
        ),
      ];

      expect(powercoachIdsToSoftDelete(roots), {'squat-z'});
    });

    test('does not soft-delete manual rows with colliding names', () {
      final older = DateTime(2025, 1, 1);
      final newer = DateTime(2026, 6, 1);
      final roots = [
        _item(
          id: 'pc-1',
          name: 'Squat',
          catalogSource: ExerciseCatalogSource.powercoach,
          createdAt: older,
        ),
        _item(
          id: 'pc-2',
          name: 'Squat',
          catalogSource: ExerciseCatalogSource.powercoach,
          createdAt: newer,
        ),
        _item(id: 'manual-1', name: 'Squat'),
        _item(id: 'manual-2', name: 'Squat'),
      ];

      expect(powercoachIdsToSoftDelete(roots), {'pc-2'});
    });

    test('returns empty when there are no powercoach duplicates', () {
      final roots = [
        _item(
          id: 'pc-1',
          name: 'Bench',
          catalogSource: ExerciseCatalogSource.powercoach,
        ),
        _item(id: 'manual-1', name: 'Custom'),
      ];

      expect(powercoachIdsToSoftDelete(roots), isEmpty);
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
      final day = const Day(
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
