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
        FakePathProviderPlatform(prefix: 'powercoach_clear_all_');
  });

  setUp(() async {
    CustomExerciseRepository.resetLegacyHevyPurgeForTest();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await OfflineLocalStore.instance.clear();
  });

  test('deleteAll soft-deletes strength and mobility exercises', () async {
    final offline = OfflineRepositorySupport();
    final now = DateTime.now().toIso8601String();

    await offline.saveLocalEntity(
      type: OfflineEntityType.customExercise,
      id: 'strength-1',
      scopeId: 'library',
      payload: <String, dynamic>{
        'id': 'strength-1',
        'name': 'Squat',
        'isMobility': false,
        'catalogSource': ExerciseCatalogSource.manual,
        'createdAt': now,
        'updatedAt': now,
        'rowVersion': 1,
      },
    );
    await offline.saveLocalEntity(
      type: OfflineEntityType.customExercise,
      id: 'mobility-1',
      scopeId: 'library',
      payload: <String, dynamic>{
        'id': 'mobility-1',
        'name': 'Hip opener',
        'isMobility': true,
        'catalogSource': ExerciseCatalogSource.manual,
        'createdAt': now,
        'updatedAt': now,
        'rowVersion': 1,
      },
    );
    await offline.saveLocalEntity(
      type: OfflineEntityType.customer,
      id: 'customer-1',
      scopeId: 'customers',
      payload: <String, dynamic>{
        'id': 'customer-1',
        'name': 'Alice',
        'createdAt': now,
        'updatedAt': now,
        'rowVersion': 1,
      },
    );

    final repo = CustomExerciseRepository(offline: offline);
    final before = await repo.listFlat();
    expect(before.map((e) => e.id).toSet(), {'strength-1', 'mobility-1'});

    final deletedCount = await repo.deleteAll();
    expect(deletedCount, 2);

    final after = await repo.listFlat();
    expect(after, isEmpty);

    final customers = await offline.readLocalEntities(
      OfflineEntityType.customer,
      scopeId: 'customers',
    );
    expect(customers.map((e) => e['id']?.toString()), ['customer-1']);
  });

  test('deleteAll returns 0 when library is empty', () async {
    final repo = CustomExerciseRepository();
    expect(await repo.deleteAll(), 0);
    expect(await repo.listFlat(), isEmpty);
  });
}
