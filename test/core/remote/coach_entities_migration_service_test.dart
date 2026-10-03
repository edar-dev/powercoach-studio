import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/backup/local_data_probe.dart';
import 'package:powercoach_studio/core/remote/coach_entities_migration_service.dart';
import 'package:powercoach_studio/core/settings/settings_prefs_keys.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/core/sync/offline_models.dart';
import 'package:powercoach_studio/core/sync/offline_repository_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_coach_entities_remote.dart';
import '../../support/fake_path_provider_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const userId = 'migrate-user-1';

  late FakeCoachEntitiesRemote fake;
  late CoachEntitiesMigrationService service;

  setUpAll(() {
    PathProviderPlatform.instance = FakePathProviderPlatform(
      prefix: 'powercoach_migration_service_test_',
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await OfflineLocalStore.instance.clear();
    fake = FakeCoachEntitiesRemote();
    service = CoachEntitiesMigrationService(
      remote: fake,
      store: OfflineLocalStore.instance,
      localProbe: LocalDataProbe(store: OfflineLocalStore.instance),
      support: OfflineRepositorySupport(
        remote: fake,
        resolveUserId: () => userId,
        isOnline: () => true,
      ),
      isOnline: () => true,
      resolveUserId: () => userId,
    );
  });

  Future<void> seedLocalCustomer() async {
    await OfflineLocalStore.instance.upsertEntityForUser(userId, {
      'id': 'c1',
      'type': OfflineEntityType.customer.name,
      'scopeId': userId,
      'payload': <String, dynamic>{'id': 'c1', 'userId': userId, 'name': 'Ada'},
      'updatedAt': DateTime.utc(2026, 9, 1).toIso8601String(),
      'deleted': false,
      'localOnly': false,
    });
  }

  test('needsMigration true when remote empty, local has data, prefs unset',
      () async {
    await seedLocalCustomer();
    expect(await service.needsMigration(userId), isTrue);
  });

  test('needsMigration false when prefs already complete', () async {
    await seedLocalCustomer();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      SettingsPrefsKeys.coachEntitiesMigrationCompleteKey(userId),
      true,
    );
    expect(await service.needsMigration(userId), isFalse);
  });

  test('needsMigration false when remote has data', () async {
    await seedLocalCustomer();
    fake.seed(
      OfflineEntity(
        id: 'remote-c',
        type: OfflineEntityType.customer,
        scopeId: userId,
        payload: const <String, dynamic>{'id': 'remote-c'},
        updatedAt: DateTime.utc(2026, 10, 1),
      ),
    );
    expect(await service.needsMigration(userId), isFalse);
  });

  test('needsMigration false when local coach data empty', () async {
    expect(await service.needsMigration(userId), isFalse);
  });

  test('runMigration upserts local entities, marks prefs, reports progress',
      () async {
    await seedLocalCustomer();
    await OfflineLocalStore.instance.upsertEntityForUser(userId, {
      'id': 'c-del',
      'type': OfflineEntityType.customer.name,
      'scopeId': userId,
      'payload': <String, dynamic>{'id': 'c-del'},
      'updatedAt': DateTime.utc(2026, 9, 2).toIso8601String(),
      'deleted': true,
      'localOnly': false,
    });

    final progress = <(int, int)>[];
    await service.runMigration(
      userId: userId,
      onProgress: (done, total) => progress.add((done, total)),
    );

    expect(fake.upsertAllCalls, greaterThan(0));
    expect(fake.stored.map((e) => e.id), containsAll(['c1', 'c-del']));
    expect(fake.stored.firstWhere((e) => e.id == 'c-del').deleted, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getBool(
        SettingsPrefsKeys.coachEntitiesMigrationCompleteKey(userId),
      ),
      isTrue,
    );
    expect(progress, isNotEmpty);
    expect(progress.last.$1, progress.last.$2);
    expect(await service.needsMigration(userId), isFalse);
  });

  test('runMigration no-op when complete and remote not empty', () async {
    fake.seed(
      OfflineEntity(
        id: 'remote-c',
        type: OfflineEntityType.customer,
        scopeId: userId,
        payload: const <String, dynamic>{'id': 'remote-c'},
        updatedAt: DateTime.utc(2026, 10, 1),
      ),
    );
    await service.markMigrationComplete(userId);
    final before = fake.upsertAllCalls;

    await service.runMigration(userId: userId);
    expect(fake.upsertAllCalls, before);
  });
}
