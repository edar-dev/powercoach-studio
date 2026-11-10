import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_item.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_repository.dart';
import 'package:powercoach_studio/features/exercise_library/domain/exercise_catalog_source.dart';
import 'package:powercoach_studio/features/exercise_library/domain/exercise_library_import_service.dart';

class _FakeExerciseRepo extends CustomExerciseRepository {
  _FakeExerciseRepo({List<Map<String, dynamic>>? created})
      : stored = created ?? <Map<String, dynamic>>[];

  final List<Map<String, dynamic>> stored;
  var nextId = 1;

  @override
  Future<List<CustomExerciseItem>> listFlat({
    bool? mobility,
    String? catalogSource,
  }) async {
    return stored
        .where((e) => e['id'] != null)
        .map(CustomExerciseItem.fromJson)
        .where((e) => mobility == null || e.isMobility == mobility)
        .where((e) => catalogSource == null || e.catalogSource == catalogSource)
        .toList();
  }

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final id = 'id_${nextId++}';
    final now = DateTime(2026, 1, 1).toIso8601String();
    final row = <String, dynamic>{
      'id': id,
      'name': body['name'],
      'parentId': body['parentId'],
      'isMobility': body['isMobility'] ?? false,
      'catalogSource': body['catalogSource'] ?? ExerciseCatalogSource.manual,
      'createdAt': now,
      'updatedAt': now,
      'rowVersion': 1,
      'children': <dynamic>[],
    };
    stored.add(row);
    return row;
  }

  @override
  Future<void> delete(String id) async {
    stored.removeWhere((e) => e['id'] == id);
  }
}

void main() {
  group('ExerciseLibraryImportService', () {
    test('imports parents before children using legacy ids', () async {
      final repo = _FakeExerciseRepo();
      final service = ExerciseLibraryImportService(exerciseRepo: repo);

      final count = await service.importItems(
        [
          {
            'id': 'legacy_child',
            'name': 'Child',
            'parentId': 'legacy_parent',
            'isMobility': false,
          },
          {
            'id': 'legacy_parent',
            'name': 'Parent',
            'isMobility': false,
          },
        ],
        fallbackMobilityWhenMissing: false,
        catalogSource: ExerciseCatalogSource.manual,
      );

      expect(count, 2);
      expect(repo.stored.first['name'], 'Parent');
      expect(repo.stored.last['parentId'], isNotNull);
    });

    test('powercoach re-import replaces existing rows instead of appending',
        () async {
      final repo = _FakeExerciseRepo();
      final service = ExerciseLibraryImportService(exerciseRepo: repo);
      const items = [
        {
          'id': 'legacy_squat',
          'name': 'Squat',
          'isMobility': false,
        },
        {
          'id': 'legacy_hb',
          'name': 'High bar',
          'parentId': 'legacy_squat',
          'isMobility': false,
        },
      ];

      final first = await service.importItems(
        items,
        fallbackMobilityWhenMissing: false,
        catalogSource: ExerciseCatalogSource.powercoach,
      );
      final second = await service.importItems(
        items,
        fallbackMobilityWhenMissing: false,
        catalogSource: ExerciseCatalogSource.powercoach,
      );

      expect(first, 2);
      expect(second, 2);
      expect(repo.stored, hasLength(2));
      expect(
        repo.stored.every(
          (e) => e['catalogSource'] == ExerciseCatalogSource.powercoach,
        ),
        isTrue,
      );
    });

    test('manual import does not delete existing powercoach rows', () async {
      final repo = _FakeExerciseRepo();
      final now = DateTime(2026, 1, 1).toIso8601String();
      repo.stored.add({
        'id': 'pc-1',
        'name': 'Squat',
        'catalogSource': ExerciseCatalogSource.powercoach,
        'isMobility': false,
        'createdAt': now,
        'updatedAt': now,
        'rowVersion': 1,
        'children': <dynamic>[],
      });
      final service = ExerciseLibraryImportService(exerciseRepo: repo);

      final count = await service.importItems(
        [
          {'id': 'manual-1', 'name': 'Custom squat', 'isMobility': false},
        ],
        fallbackMobilityWhenMissing: false,
        catalogSource: ExerciseCatalogSource.manual,
      );

      expect(count, 1);
      expect(repo.stored, hasLength(2));
      expect(
        repo.stored.where(
          (e) => e['catalogSource'] == ExerciseCatalogSource.powercoach,
        ),
        hasLength(1),
      );
    });
  });
}
