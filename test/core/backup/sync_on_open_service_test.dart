import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/backup/auto_cloud_snapshot_store.dart';
import 'package:powercoach_studio/core/backup/backup_activity_store.dart';
import 'package:powercoach_studio/core/backup/cloud_backup_repository.dart';
import 'package:powercoach_studio/core/backup/cloud_backup_storage.dart';
import 'package:powercoach_studio/core/backup/cloud_snapshot_scheduler.dart';
import 'package:powercoach_studio/core/backup/local_data_probe.dart';
import 'package:powercoach_studio/core/backup/material_write_notifier.dart';
import 'package:powercoach_studio/core/backup/sync_on_open_service.dart';
import 'package:powercoach_studio/core/backup/user_data_backup_codec.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/core/sync/offline_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_macos_notifications_platform.dart';
import '../../support/fake_path_provider_platform.dart';

class _FakeCloudBackupStorage implements CloudBackupStorage {
  final Map<String, String> files = {};
  final Map<String, DateTime> createdAtByPath = {};

  @override
  Future<void> uploadJson(String path, String jsonString) async {
    files[path] = jsonString;
    createdAtByPath[path] = DateTime.now().toUtc();
  }

  @override
  Future<List<CloudBackupObject>> list(String prefix) async => [
        for (final path in files.keys)
          if (path.startsWith('$prefix/'))
            CloudBackupObject(
              path: path,
              name: path.split('/').last,
              createdAt: createdAtByPath[path]!,
            ),
      ];

  @override
  Future<String> downloadJson(String path) async {
    final content = files[path];
    if (content == null) throw StateError('missing: $path');
    return content;
  }

  @override
  Future<void> remove(List<String> paths) async {
    for (final path in paths) {
      files.remove(path);
      createdAtByPath.remove(path);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const uid = '__legacy__';

  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PathProviderPlatform.instance = FakePathProviderPlatform(
      prefix: 'powercoach_sync_on_open_test_',
    );
    registerFakeMacOSNotificationsPlatform();
  });

  late _FakeCloudBackupStorage storage;
  late CloudBackupRepository repo;
  late AutoCloudSnapshotStore autoStore;
  late SyncOnOpenService syncService;
  late CloudSnapshotScheduler scheduler;

  Map<String, dynamic> customerEntity({
    required String id,
    required String name,
    required DateTime updatedAt,
  }) {
    return <String, dynamic>{
      'id': id,
      'type': OfflineEntityType.customer.name,
      'scopeId': id,
      'payload': <String, dynamic>{'id': id, 'name': name, 'userId': uid},
      'updatedAt': updatedAt.toIso8601String(),
      'deleted': false,
      'localOnly': false,
    };
  }

  String backupJson({
    required List<Map<String, dynamic>> entities,
  }) {
    return jsonEncode(<String, dynamic>{
      'schemaVersion': kUserBackupSchemaVersion,
      'exportFormat': kUserBackupExportFormat,
      'accountUserId': uid,
      'entities': entities,
      'preferences': <String, dynamic>{},
    });
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    MaterialWriteNotifier.suppress = false;
    MaterialWriteNotifier.setListener(null);
    await OfflineLocalStore.instance.clear();
    storage = _FakeCloudBackupStorage();
    repo = CloudBackupRepository(storage: storage);
    autoStore = AutoCloudSnapshotStore(defaultEnabledOnWeb: true);
    scheduler = CloudSnapshotScheduler(
      cloudBackupRepository: repo,
      autoStore: autoStore,
      activityStore: BackupActivityStore.instance,
      currentUserId: () async => uid,
      isOnline: () async => true,
      isAutoEnabled: () async => true,
      buildExportJson: (_) async => '{}',
      createTimer: (duration, callback) => Timer(duration, callback),
    );
    syncService = SyncOnOpenService(
      cloudBackupRepository: repo,
      localDataProbe: LocalDataProbe(store: OfflineLocalStore.instance),
      autoStore: autoStore,
      activityStore: BackupActivityStore.instance,
      scheduler: scheduler,
      currentUserId: () async => uid,
      isOnline: () async => true,
    );
  });

  test('merges when cloud snapshot is newer than local watermark', () async {
    final store = OfflineLocalStore.instance;
    await store.upsertEntityForUser(
      uid,
      customerEntity(
        id: 'local-c',
        name: 'Local',
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    );

    final cloudPath = '$uid/backups/cloud.json';
    storage.files[cloudPath] = backupJson(
      entities: [
        customerEntity(
          id: 'cloud-c',
          name: 'Cloud',
          updatedAt: DateTime.utc(2026, 6, 1),
        ),
      ],
    );
    storage.createdAtByPath[cloudPath] = DateTime.utc(2026, 6, 2);

    final merged = await syncService.syncIfNeeded(userId: uid);
    expect(merged, isTrue);

    final customers = await store.readEntities(OfflineEntityType.customer);
    expect(customers.map((e) => e.id), containsAll(['local-c', 'cloud-c']));
    expect(await autoStore.lastCloudSyncAt(uid), isNotNull);
  });

  test('skips merge when cloud is not newer than local watermark', () async {
    final store = OfflineLocalStore.instance;
    await store.upsertEntityForUser(
      uid,
      customerEntity(
        id: 'local-c',
        name: 'Local',
        updatedAt: DateTime.utc(2026, 8, 1),
      ),
    );

    final cloudPath = '$uid/backups/cloud.json';
    storage.files[cloudPath] = backupJson(
      entities: [
        customerEntity(
          id: 'cloud-c',
          name: 'Cloud',
          updatedAt: DateTime.utc(2026, 6, 1),
        ),
      ],
    );
    storage.createdAtByPath[cloudPath] = DateTime.utc(2026, 6, 2);

    final merged = await syncService.syncIfNeeded(userId: uid);
    expect(merged, isFalse);

    final customers = await store.readEntities(OfflineEntityType.customer);
    expect(customers.map((e) => e.id), ['local-c']);
  });

  test('empty local does not merge (recovery path)', () async {
    final cloudPath = '$uid/backups/cloud.json';
    storage.files[cloudPath] = backupJson(
      entities: [
        customerEntity(
          id: 'cloud-c',
          name: 'Cloud',
          updatedAt: DateTime.utc(2026, 6, 1),
        ),
      ],
    );
    storage.createdAtByPath[cloudPath] = DateTime.utc(2026, 6, 2);

    final probe = LocalDataProbe(store: OfflineLocalStore.instance);
    expect(await probe.isCoachDataEmpty(uid), isTrue);

    final merged = await syncService.syncIfNeeded(userId: uid);
    expect(merged, isFalse);

    final customers = await storeEntities();
    expect(customers, isEmpty);
  });
}

Future<List<OfflineEntity>> storeEntities() {
  return OfflineLocalStore.instance.readEntities(OfflineEntityType.customer);
}
