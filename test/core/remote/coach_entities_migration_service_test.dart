import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/backup/local_data_probe.dart';
import 'package:powercoach_studio/core/remote/coach_entities_exceptions.dart';
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

  test('needsMigration false when remote has data and never started', () async {
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

  test('needsMigration true for partial upload retry (started, remote not empty)',
      () async {
    await seedLocalCustomer();
    await service.markMigrationStarted(userId);
    fake.seed(
      OfflineEntity(
        id: 'partial-c',
        type: OfflineEntityType.customer,
        scopeId: userId,
        payload: const <String, dynamic>{'id': 'partial-c'},
        updatedAt: DateTime.utc(2026, 10, 1),
      ),
    );
    expect(await service.needsMigration(userId), isTrue);
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

  test('runMigration marks started before upsert so failure can retry safely',
      () async {
    await seedLocalCustomer();
    fake.failNextUpsertAll = true;

    await expectLater(
      service.runMigration(userId: userId),
      throwsA(isA<Object>()),
    );

    expect(await service.isMigrationStarted(userId), isTrue);
    expect(await service.isMigrationComplete(userId), isFalse);
    expect(await service.needsMigration(userId), isTrue);
  });

  test('runMigration resume skips already-remote entities and upserts remainder',
      () async {
    await seedLocalCustomer();
    await OfflineLocalStore.instance.upsertEntityForUser(userId, {
      'id': 'c2',
      'type': OfflineEntityType.customer.name,
      'scopeId': userId,
      'payload': <String, dynamic>{'id': 'c2', 'userId': userId, 'name': 'Bob'},
      'updatedAt': DateTime.utc(2026, 9, 2).toIso8601String(),
      'deleted': false,
      'localOnly': false,
    });
    fake.seed(
      OfflineEntity(
        id: 'c1',
        type: OfflineEntityType.customer,
        scopeId: userId,
        payload: const <String, dynamic>{'id': 'c1'},
        updatedAt: DateTime.utc(2026, 9, 1),
      ),
    );
    await service.markMigrationStarted(userId);

    final progress = <(int, int)>[];
    await service.runMigration(
      userId: userId,
      onProgress: (done, total) => progress.add((done, total)),
    );

    expect(fake.upsertAllCalls, 1);
    final upsertedIds = fake.stored.map((e) => e.id).toSet();
    expect(upsertedIds, containsAll(['c1', 'c2']));
    expect(
      progress.any((p) => p.$1 == 1 && p.$2 == 2),
      isTrue,
      reason: 'reports alreadyRemote before uploading remainder',
    );
    expect(progress.last, (2, 2));
    expect(await service.isMigrationComplete(userId), isTrue);
  });

  test('runMigration clears progress prefs on complete', () async {
    await seedLocalCustomer();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      SettingsPrefsKeys.coachEntitiesMigrationProgressKey(userId),
      3,
    );

    await service.runMigration(userId: userId);

    expect(
      prefs.getInt(
        SettingsPrefsKeys.coachEntitiesMigrationProgressKey(userId),
      ),
      isNull,
    );
    expect(await service.isMigrationComplete(userId), isTrue);
  });

  test('runMigration all-already-remote marks complete without upsert', () async {
    await seedLocalCustomer();
    fake.seed(
      OfflineEntity(
        id: 'c1',
        type: OfflineEntityType.customer,
        scopeId: userId,
        payload: const <String, dynamic>{'id': 'c1'},
        updatedAt: DateTime.utc(2026, 9, 1),
        deleted: true,
      ),
    );
    await service.markMigrationStarted(userId);
    final before = fake.upsertAllCalls;

    final progress = <(int, int)>[];
    await service.runMigration(
      userId: userId,
      onProgress: (done, total) => progress.add((done, total)),
    );

    expect(fake.upsertAllCalls, before);
    expect(await service.isMigrationComplete(userId), isTrue);
    expect(await service.isMigrationStarted(userId), isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.containsKey(
        SettingsPrefsKeys.coachEntitiesMigrationProgressKey(userId),
      ),
      isFalse,
    );
    expect(progress.any((p) => p.$1 == 1 && p.$2 == 1), isTrue);
  });

  test('runMigration mid-chunk failure then resume skips uploaded rows', () async {
    // Seed 3 locals; fake chunk size is 100 so force fail after first upsertAll
    // by uploading in two runs with one entity already remote after failure.
    await seedLocalCustomer();
    await OfflineLocalStore.instance.upsertEntityForUser(userId, {
      'id': 'c2',
      'type': OfflineEntityType.customer.name,
      'scopeId': userId,
      'payload': <String, dynamic>{'id': 'c2'},
      'updatedAt': DateTime.utc(2026, 9, 2).toIso8601String(),
      'deleted': false,
      'localOnly': false,
    });

    // First attempt uploads c1 then fails before c2 (simulate via fail-after-1
    // with a custom path: succeed once then fail — but chunk size is 100 so
    // both would go in one call. Seed failure after success by inserting c1
    // remotely after a failed full upsert, then retry.)
    fake.failNextUpsertAll = true;
    await expectLater(
      service.runMigration(userId: userId),
      throwsA(isA<Object>()),
    );
    expect(await service.isMigrationStarted(userId), isTrue);

    // Partial remote state as if first chunk landed before a later failure.
    fake.seed(
      OfflineEntity(
        id: 'c1',
        type: OfflineEntityType.customer,
        scopeId: userId,
        payload: const <String, dynamic>{'id': 'c1'},
        updatedAt: DateTime.utc(2026, 9, 1),
      ),
    );

    final before = fake.upsertAllCalls;
    final progress = <(int, int)>[];
    await service.runMigration(
      userId: userId,
      onProgress: (done, total) => progress.add((done, total)),
    );

    expect(fake.upsertAllCalls, before + 1);
    expect(fake.stored.map((e) => e.id).toSet(), containsAll(['c1', 'c2']));
    expect(progress.first.$1, 1);
    expect(progress.first.$2, 2);
    expect(await service.isMigrationComplete(userId), isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getInt(
        SettingsPrefsKeys.coachEntitiesMigrationProgressKey(userId),
      ),
      isNull,
    );
  });

  test('runMigration throws when offline', () async {
    await seedLocalCustomer();
    final offlineService = CoachEntitiesMigrationService(
      remote: fake,
      store: OfflineLocalStore.instance,
      localProbe: LocalDataProbe(store: OfflineLocalStore.instance),
      support: OfflineRepositorySupport(
        remote: fake,
        resolveUserId: () => userId,
        isOnline: () => false,
      ),
      isOnline: () => false,
      resolveUserId: () => userId,
    );

    await expectLater(
      offlineService.runMigration(userId: userId),
      throwsA(isA<CoachEntitiesOnlineRequiredException>()),
    );
  });
}
