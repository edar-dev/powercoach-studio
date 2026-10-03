import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/backup/user_data_backup_codec.dart';
import 'package:powercoach_studio/core/backup/user_data_backup_service.dart';
import 'package:powercoach_studio/core/remote/coach_entities_exceptions.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/core/sync/offline_models.dart';
import 'package:powercoach_studio/core/sync/offline_repository_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_coach_entities_remote.dart';
import '../../support/fake_macos_notifications_platform.dart';
import '../../support/fake_path_provider_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const uid = 'restore-remote-user';

  late FakeCoachEntitiesRemote fake;
  late UserDataBackupService backup;

  setUpAll(() {
    PathProviderPlatform.instance = FakePathProviderPlatform(
      prefix: 'powercoach_backup_remote_restore_test_',
    );
    registerFakeMacOSNotificationsPlatform();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await OfflineLocalStore.instance.clear();
    fake = FakeCoachEntitiesRemote();
    backup = UserDataBackupService(
      remote: fake,
      support: OfflineRepositorySupport(
        remote: fake,
        resolveUserId: () => uid,
        isOnline: () => true,
      ),
      isOnline: () => true,
      resolveUserId: () => uid,
    );
  });

  Map<String, dynamic> customerEntity({
    required String id,
    required String name,
    required DateTime updatedAt,
    bool deleted = false,
  }) {
    return <String, dynamic>{
      'id': id,
      'type': OfflineEntityType.customer.name,
      'scopeId': id,
      'payload': <String, dynamic>{'id': id, 'name': name, 'userId': uid},
      'updatedAt': updatedAt.toIso8601String(),
      'deleted': deleted,
      'localOnly': false,
    };
  }

  test('restoreParsed upserts to remote then refreshes Drift cache', () async {
    await OfflineLocalStore.instance.upsertEntityForUser(
      uid,
      customerEntity(
        id: 'stale',
        name: 'Stale',
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    );

    final parsed = ParsedUserBackup(
      entities: [
        customerEntity(
          id: 'imported',
          name: 'Imported',
          updatedAt: DateTime.utc(2026, 6, 1),
        ),
      ],
      pendingOperations: const [],
      syncMeta: const [],
      profileJson: null,
      preferences: const BackupPreferences(notificationsEnabled: true),
      reminders: const [],
    );

    await backup.restoreParsed(parsed, uid);

    expect(fake.upsertAllCalls, 1);
    expect(fake.stored.map((e) => e.id), ['imported']);
    expect(fake.pullCalls, 1);

    final cached =
        await OfflineLocalStore.instance.listEntitiesJsonForBackup(uid);
    final customers = cached
        .where((e) => e['type'] == OfflineEntityType.customer.name)
        .toList();
    expect(customers.map((e) => e['id']), ['imported']);
    expect(customers.map((e) => e['id']), isNot(contains('stale')));
  });

  test('restoreParsed requires online when remote is wired', () async {
    final offlineBackup = UserDataBackupService(
      remote: fake,
      support: OfflineRepositorySupport(
        remote: fake,
        resolveUserId: () => uid,
        isOnline: () => false,
      ),
      isOnline: () => false,
      resolveUserId: () => uid,
    );

    final parsed = ParsedUserBackup(
      entities: [
        customerEntity(
          id: 'c1',
          name: 'A',
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ],
      pendingOperations: const [],
      syncMeta: const [],
      profileJson: null,
      preferences: const BackupPreferences(notificationsEnabled: true),
      reminders: const [],
    );

    expect(
      () => offlineBackup.restoreParsed(parsed, uid),
      throwsA(
        isA<CoachEntitiesOnlineRequiredException>().having(
          (e) => e.reason,
          'reason',
          CoachEntitiesOnlineRequiredReason.offline,
        ),
      ),
    );
    expect(fake.upsertAllCalls, 0);
  });

  test('mergeRestore upserts merged set then pulls cache', () async {
    await OfflineLocalStore.instance.upsertEntityForUser(
      uid,
      customerEntity(
        id: 'local-c',
        name: 'Local',
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    );

    final parsed = ParsedUserBackup(
      entities: [
        customerEntity(
          id: 'import-c',
          name: 'Imported',
          updatedAt: DateTime.utc(2026, 6, 1),
        ),
      ],
      pendingOperations: const [],
      syncMeta: const [],
      profileJson: null,
      preferences: const BackupPreferences(notificationsEnabled: true),
      reminders: const [],
    );

    await backup.mergeRestore(parsed, uid);

    expect(fake.upsertAllCalls, 1);
    expect(
      fake.stored.map((e) => e.id),
      containsAll(['local-c', 'import-c']),
    );
    expect(fake.pullCalls, 1);

    final cached =
        await OfflineLocalStore.instance.listEntitiesJsonForBackup(uid);
    expect(
      cached.map((e) => e['id']),
      containsAll(['local-c', 'import-c']),
    );
  });
}
