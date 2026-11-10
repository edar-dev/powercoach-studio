import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_item.dart';
import 'package:powercoach_studio/features/exercise_library/domain/exercise_autocomplete_filter.dart';
import 'package:powercoach_studio/features/exercise_library/domain/exercise_catalog_source.dart';
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
