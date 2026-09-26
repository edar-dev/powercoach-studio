import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/core/sync/offline_models.dart';
import 'package:powercoach_studio/core/sync/offline_repository_support.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_repository.dart';
import 'package:powercoach_studio/features/exercise_library/domain/exercise_catalog_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    PathProviderPlatform.instance =
        FakePathProviderPlatform(prefix: 'powercoach_hevy_purge_');
  });

  setUp(() async {
    CustomExerciseRepository.resetLegacyHevyPurgeForTest();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'hevy_api_key_v1': 'secret-key',
      'hevy_exercise_mappings_json_v1': '{"x":"y"}',
    });
    await OfflineLocalStore.instance.clear();
  });

  test('listFlat purges Hevy catalog rows and clears legacy prefs', () async {
    final offline = OfflineRepositorySupport();
    final now = DateTime.now().toIso8601String();

    await offline.saveLocalEntity(
      type: OfflineEntityType.customExercise,
      id: 'manual-1',
      scopeId: 'library',
      payload: <String, dynamic>{
        'id': 'manual-1',
        'name': 'Manual squat',
        'isMobility': false,
        'catalogSource': ExerciseCatalogSource.manual,
        'createdAt': now,
        'updatedAt': now,
        'rowVersion': 1,
      },
    );
    await offline.saveLocalEntity(
      type: OfflineEntityType.customExercise,
      id: 'hevy-1',
      scopeId: 'library',
      payload: <String, dynamic>{
        'id': 'hevy-1',
        'name': 'Hevy bench',
        'isMobility': false,
        'catalogSource': 'hevy',
        'createdAt': now,
        'updatedAt': now,
        'rowVersion': 1,
      },
    );

    final repo = CustomExerciseRepository(offline: offline);
    final items = await repo.listFlat();

    expect(items.map((e) => e.id), ['manual-1']);
    expect(items.any((e) => e.catalogSource == 'hevy'), isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('hevy_api_key_v1'), isFalse);
    expect(prefs.containsKey('hevy_exercise_mappings_json_v1'), isFalse);
  });
}
