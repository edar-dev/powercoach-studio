import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/backup/local_data_probe.dart';
import 'package:powercoach_studio/core/remote/coach_entities_exceptions.dart';
import 'package:powercoach_studio/core/remote/coach_entities_migration_service.dart';
import 'package:powercoach_studio/core/remote/coach_entities_remote.dart';
import 'package:powercoach_studio/core/remote/coach_entities_sync_coordinator.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/core/sync/offline_models.dart';
import 'package:powercoach_studio/core/sync/offline_repository_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_coach_entities_remote.dart';
import '../../support/fake_path_provider_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CoachEntitiesRemote row mapping', () {
    test('entityFromRow / rowFromEntity round-trip', () {
      final entity = OfflineEntity(
        id: 'c1',
        type: OfflineEntityType.customer,
        scopeId: 'user-1',
        payload: <String, dynamic>{'id': 'c1', 'name': 'Ada'},
        updatedAt: DateTime.utc(2026, 10, 3, 12),
        deleted: false,
      );

      final row = CoachEntitiesRemote.rowFromEntity(entity, 'user-1');
      expect(row['user_id'], 'user-1');
      expect(row['type'], 'customer');
      expect(row['scope_id'], 'user-1');
      expect(row['deleted'], isFalse);

      final back = CoachEntitiesRemote.entityFromRow(row);
      expect(back.id, entity.id);
      expect(back.type, entity.type);
      expect(back.scopeId, entity.scopeId);
      expect(back.payload['name'], 'Ada');
      expect(back.deleted, isFalse);
    });

    test('entityFromRow maps scope_id and soft-delete', () {
      final entity = CoachEntitiesRemote.entityFromRow(<String, dynamic>{
        'user_id': 'u',
        'type': 'workoutPlan',
        'id': 'p1',
        'scope_id': 'cust-9',
        'payload': <String, dynamic>{'customerId': 'cust-9'},
        'updated_at': '2026-10-03T10:00:00.000Z',
        'deleted': true,
      });
      expect(entity.type, OfflineEntityType.workoutPlan);
      expect(entity.scopeId, 'cust-9');
      expect(entity.deleted, isTrue);
    });
  });

  group('OfflineRepositorySupport remote-first', () {
    const userId = 'user-remote-first';

    setUpAll(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      PathProviderPlatform.instance = FakePathProviderPlatform(
        prefix: 'powercoach_remote_first_',
      );
    });

    setUp(() async {
      await OfflineLocalStore.instance.clear();
    });

    OfflineRepositorySupport support(FakeCoachEntitiesRemote fake) {
      return OfflineRepositorySupport(
        remote: fake,
        resolveUserId: () => userId,
        isOnline: () => true,
      );
    }

    test('write success calls remote then updates cache', () async {
      final fake = FakeCoachEntitiesRemote();
      final repo = support(fake);

      await repo.saveLocalEntity(
        type: OfflineEntityType.customer,
        id: 'c1',
        scopeId: userId,
        payload: <String, dynamic>{
          'id': 'c1',
          'userId': userId,
          'name': 'Remote Ada',
        },
      );

      expect(fake.upsertCalls, 1);
      expect(fake.stored, hasLength(1));
      expect(fake.stored.single.payload['name'], 'Remote Ada');

      final cached = await OfflineLocalStore.instance.listEntitiesJsonForBackup(
        userId,
      );
      expect(cached, hasLength(1));
      expect(cached.single['id'], 'c1');
      expect(
        (cached.single['payload'] as Map)['name'],
        'Remote Ada',
      );
    });

    test('write failure does not update cache with new data', () async {
      final fake = FakeCoachEntitiesRemote();
      final repo = support(fake);

      await OfflineLocalStore.instance.upsertEntityForUser(userId, {
        'id': 'c1',
        'type': OfflineEntityType.customer.name,
        'scopeId': userId,
        'payload': <String, dynamic>{
          'id': 'c1',
          'userId': userId,
          'name': 'Old Name',
        },
        'updatedAt': DateTime.utc(2026, 1, 1).toIso8601String(),
        'deleted': false,
        'localOnly': false,
      });

      fake.failNextWrite = true;
      await expectLater(
        repo.saveLocalEntity(
          type: OfflineEntityType.customer,
          id: 'c1',
          scopeId: userId,
          payload: <String, dynamic>{
            'id': 'c1',
            'userId': userId,
            'name': 'New Name',
          },
        ),
        throwsA(isA<CoachEntitiesRemoteException>()),
      );

      final cached = await OfflineLocalStore.instance.listEntitiesJsonForBackup(
        userId,
      );
      expect(cached, hasLength(1));
      expect((cached.single['payload'] as Map)['name'], 'Old Name');
    });

    test('pullAndReplaceCache replaces per type', () async {
      final fake = FakeCoachEntitiesRemote();
      final repo = support(fake);

      await OfflineLocalStore.instance.upsertEntityForUser(userId, {
        'id': 'stale-c',
        'type': OfflineEntityType.customer.name,
        'scopeId': userId,
        'payload': <String, dynamic>{'id': 'stale-c', 'userId': userId},
        'updatedAt': DateTime.utc(2026, 1, 1).toIso8601String(),
        'deleted': false,
        'localOnly': false,
      });
      await OfflineLocalStore.instance.upsertEntityForUser(userId, {
        'id': 'stale-p',
        'type': OfflineEntityType.workoutPlan.name,
        'scopeId': 'cust',
        'payload': <String, dynamic>{'id': 'stale-p', 'customerId': 'cust'},
        'updatedAt': DateTime.utc(2026, 1, 1).toIso8601String(),
        'deleted': false,
        'localOnly': false,
      });

      fake.seed(
        OfflineEntity(
          id: 'fresh-c',
          type: OfflineEntityType.customer,
          scopeId: userId,
          payload: <String, dynamic>{'id': 'fresh-c', 'userId': userId},
          updatedAt: DateTime.utc(2026, 10, 1),
        ),
      );
      fake.seed(
        OfflineEntity(
          id: 'fresh-p',
          type: OfflineEntityType.workoutPlan,
          scopeId: 'cust',
          payload: <String, dynamic>{'id': 'fresh-p', 'customerId': 'cust'},
          updatedAt: DateTime.utc(2026, 10, 1),
          deleted: true,
        ),
      );

      await repo.pullAndReplaceCache();
      expect(fake.pullCalls, 1);

      final customers =
          await OfflineLocalStore.instance.listEntitiesJsonForBackup(userId);
      final customerRows = customers
          .where((e) => e['type'] == OfflineEntityType.customer.name)
          .toList();
      final planRows = customers
          .where((e) => e['type'] == OfflineEntityType.workoutPlan.name)
          .toList();

      expect(customerRows.map((e) => e['id']), ['fresh-c']);
      expect(planRows.map((e) => e['id']), ['fresh-p']);
      expect(planRows.single['deleted'], isTrue);
      expect(customers.map((e) => e['id']), isNot(contains('stale-c')));
      expect(customers.map((e) => e['id']), isNot(contains('stale-p')));
    });

    test('throws when offline and remote is configured', () async {
      final fake = FakeCoachEntitiesRemote();
      final repo = OfflineRepositorySupport(
        remote: fake,
        resolveUserId: () => userId,
        isOnline: () => false,
      );

      await expectLater(
        repo.saveLocalEntity(
          type: OfflineEntityType.customer,
          id: 'c1',
          scopeId: userId,
          payload: <String, dynamic>{'id': 'c1'},
        ),
        throwsA(
          isA<CoachEntitiesOnlineRequiredException>().having(
            (e) => e.reason,
            'reason',
            CoachEntitiesOnlineRequiredReason.offline,
          ),
        ),
      );
      expect(fake.upsertCalls, 0);
    });

    test('defers pull when remote empty and local coach data exists', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final fake = FakeCoachEntitiesRemote();
      await OfflineLocalStore.instance.upsertEntity(
        OfflineEntity(
          id: 'local-c',
          type: OfflineEntityType.customer,
          scopeId: userId,
          payload: <String, dynamic>{'id': 'local-c', 'userId': userId},
          updatedAt: DateTime.utc(2026, 9, 1),
        ),
      );

      final coordinator = CoachEntitiesSyncCoordinator(
        remote: fake,
        support: OfflineRepositorySupport(
          remote: fake,
          resolveUserId: () => userId,
          isOnline: () => true,
        ),
        localProbe: LocalDataProbe(),
      );

      expect(await coordinator.shouldDeferPullForMigration(userId), isTrue);

      // Multi-device: remote populated elsewhere, migration never started here.
      fake.seed(
        OfflineEntity(
          id: 'remote-c',
          type: OfflineEntityType.customer,
          scopeId: userId,
          payload: <String, dynamic>{'id': 'remote-c'},
          updatedAt: DateTime.utc(2026, 10, 1),
        ),
      );
      expect(await coordinator.shouldDeferPullForMigration(userId), isFalse);
    });

    test('defers pull after partial migration (started, remote not empty)',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final fake = FakeCoachEntitiesRemote();
      await OfflineLocalStore.instance.upsertEntity(
        OfflineEntity(
          id: 'local-c',
          type: OfflineEntityType.customer,
          scopeId: userId,
          payload: <String, dynamic>{'id': 'local-c', 'userId': userId},
          updatedAt: DateTime.utc(2026, 9, 1),
        ),
      );
      fake.seed(
        OfflineEntity(
          id: 'partial-c',
          type: OfflineEntityType.customer,
          scopeId: userId,
          payload: <String, dynamic>{'id': 'partial-c'},
          updatedAt: DateTime.utc(2026, 10, 1),
        ),
      );

      final migration = CoachEntitiesMigrationService(
        remote: fake,
        localProbe: LocalDataProbe(),
        resolveUserId: () => userId,
        isOnline: () => true,
      );
      await migration.markMigrationStarted(userId);

      final coordinator = CoachEntitiesSyncCoordinator(
        remote: fake,
        support: OfflineRepositorySupport(
          remote: fake,
          resolveUserId: () => userId,
          isOnline: () => true,
        ),
        localProbe: LocalDataProbe(),
        migration: migration,
      );

      expect(await coordinator.shouldDeferPullForMigration(userId), isTrue);
    });
  });
}
