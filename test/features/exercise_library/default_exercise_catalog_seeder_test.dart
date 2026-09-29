import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/settings/settings_prefs_keys.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_item.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_repository.dart';
import 'package:powercoach_studio/features/exercise_library/data/default_exercise_catalog.dart';
import 'package:powercoach_studio/features/exercise_library/domain/default_exercise_catalog_seeder.dart';
import 'package:powercoach_studio/features/exercise_library/domain/exercise_library_import_service.dart';
import 'package:powercoach_studio/features/exercise_library/domain/exercise_catalog_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepo extends CustomExerciseRepository {
  final List<Map<String, dynamic>> stored = [];
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
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('DefaultExerciseCatalogSeeder', () {
    test('imports default catalog when powercoach source is empty', () async {
      final repo = _FakeRepo();
      final seeder = DefaultExerciseCatalogSeeder(
        exerciseRepo: repo,
        importService: ExerciseLibraryImportService(exerciseRepo: repo),
      );

      final count = await seeder.ensureSeeded();
      expect(count, defaultExerciseCatalogNodeCount());
      expect(
        repo.stored.every(
          (e) => e['catalogSource'] == ExerciseCatalogSource.powercoach,
        ),
        isTrue,
      );
    });

    test('skips import when powercoach exercises already exist', () async {
      final repo = _FakeRepo();
      final now = DateTime(2026, 1, 1).toIso8601String();
      repo.stored.add({
        'id': 'existing',
        'name': 'Panca piana',
        'catalogSource': ExerciseCatalogSource.powercoach,
        'isMobility': false,
        'createdAt': now,
        'updatedAt': now,
        'rowVersion': 1,
        'children': <dynamic>[],
      });
      final seeder = DefaultExerciseCatalogSeeder(
        exerciseRepo: repo,
        importService: ExerciseLibraryImportService(exerciseRepo: repo),
      );

      final count = await seeder.ensureSeeded();
      expect(count, 0);
      expect(repo.stored, hasLength(1));
    });

    test('skips import when auto-seed is suppressed after clear', () async {
      await DefaultExerciseCatalogSeeder.markAutoSeedSuppressed();
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getBool(SettingsPrefsKeys.exerciseLibrarySkipAutoSeed),
        isTrue,
      );

      final repo = _FakeRepo();
      final seeder = DefaultExerciseCatalogSeeder(
        exerciseRepo: repo,
        importService: ExerciseLibraryImportService(exerciseRepo: repo),
      );

      final count = await seeder.ensureSeeded();
      expect(count, 0);
      expect(repo.stored, isEmpty);

      await DefaultExerciseCatalogSeeder.clearAutoSeedSuppression();
      final afterClear = await seeder.ensureSeeded();
      expect(afterClear, defaultExerciseCatalogNodeCount());
    });
  });
}
