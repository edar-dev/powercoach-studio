import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/settings/settings_prefs_keys.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_item.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_repository.dart';
import 'package:powercoach_studio/features/exercise_library/domain/exercise_catalog_source.dart';
import 'package:powercoach_studio/features/workouts/domain/powercoach_catalog_dedupe_cleanup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepo extends CustomExerciseRepository {
  final List<Map<String, dynamic>> stored = [];

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
  Future<void> delete(String id) async {
    stored.removeWhere((e) => e['id'] == id);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    resetPowercoachCatalogDedupeCleanupInFlightForTest();
  });

  test('soft-deletes duplicate powercoach rows once and skips manuals',
      () async {
    final older = DateTime(2025, 1, 1).toIso8601String();
    final newer = DateTime(2026, 6, 1).toIso8601String();
    final repo = _FakeRepo()
      ..stored.addAll([
        {
          'id': 'squat-a',
          'name': 'Squat con bilanciere',
          'isMobility': false,
          'catalogSource': ExerciseCatalogSource.powercoach,
          'createdAt': older,
          'updatedAt': older,
          'rowVersion': 1,
        },
        {
          'id': 'hb-a',
          'name': 'High bar',
          'parentId': 'squat-a',
          'isMobility': false,
          'catalogSource': ExerciseCatalogSource.powercoach,
          'createdAt': older,
          'updatedAt': older,
          'rowVersion': 1,
        },
        {
          'id': 'squat-b',
          'name': 'Squat con bilanciere',
          'isMobility': false,
          'catalogSource': ExerciseCatalogSource.powercoach,
          'createdAt': newer,
          'updatedAt': newer,
          'rowVersion': 1,
        },
        {
          'id': 'hb-b',
          'name': 'High bar',
          'parentId': 'squat-b',
          'isMobility': false,
          'catalogSource': ExerciseCatalogSource.powercoach,
          'createdAt': newer,
          'updatedAt': newer,
          'rowVersion': 1,
        },
        {
          'id': 'manual-1',
          'name': 'Squat con bilanciere',
          'isMobility': false,
          'catalogSource': ExerciseCatalogSource.manual,
          'createdAt': newer,
          'updatedAt': newer,
          'rowVersion': 1,
        },
      ]);

    final deleted = await ensurePowercoachCatalogDedupeCleanup(
      exerciseRepo: repo,
    );

    expect(deleted, 2);
    expect(
      repo.stored.map((e) => e['id']).toSet(),
      {'squat-a', 'hb-a', 'manual-1'},
    );

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getBool(SettingsPrefsKeys.exerciseLibraryPowercoachDedupeCleanupV1),
      isTrue,
    );

    final secondPass = await ensurePowercoachCatalogDedupeCleanup(
      exerciseRepo: repo,
    );
    expect(secondPass, 0);
    expect(repo.stored, hasLength(3));
  });

  test('skips work when prefs gate is already set', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      SettingsPrefsKeys.exerciseLibraryPowercoachDedupeCleanupV1: true,
    });
    final repo = _FakeRepo()
      ..stored.add({
        'id': 'squat-a',
        'name': 'Squat',
        'isMobility': false,
        'catalogSource': ExerciseCatalogSource.powercoach,
        'createdAt': DateTime(2025, 1, 1).toIso8601String(),
        'updatedAt': DateTime(2025, 1, 1).toIso8601String(),
        'rowVersion': 1,
      })
      ..stored.add({
        'id': 'squat-b',
        'name': 'Squat',
        'isMobility': false,
        'catalogSource': ExerciseCatalogSource.powercoach,
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        'updatedAt': DateTime(2026, 1, 1).toIso8601String(),
        'rowVersion': 1,
      });

    final deleted = await ensurePowercoachCatalogDedupeCleanup(
      exerciseRepo: repo,
    );

    expect(deleted, 0);
    expect(repo.stored, hasLength(2));
  });
}
