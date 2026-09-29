import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/backup/auto_cloud_snapshot_store.dart';
import 'package:powercoach_studio/core/backup/backup_activity_store.dart';
import 'package:powercoach_studio/core/backup/cloud_backup_repository.dart';
import 'package:powercoach_studio/core/backup/cloud_backup_storage.dart';
import 'package:powercoach_studio/core/backup/cloud_snapshot_scheduler.dart';
import 'package:powercoach_studio/core/backup/material_write_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeCloudBackupStorage implements CloudBackupStorage {
  final Map<String, String> files = {};
  int uploadCount = 0;

  @override
  Future<void> uploadJson(String path, String jsonString) async {
    uploadCount++;
    files[path] = jsonString;
  }

  @override
  Future<List<CloudBackupObject>> list(String prefix) async => [
        for (final path in files.keys)
          if (path.startsWith('$prefix/'))
            CloudBackupObject(
              path: path,
              name: path.split('/').last,
              createdAt: DateTime.now().toUtc(),
            ),
      ];

  @override
  Future<String> downloadJson(String path) async => files[path]!;

  @override
  Future<void> remove(List<String> paths) async {
    for (final path in paths) {
      files.remove(path);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late void Function()? pendingCallback;
  late Timer? pendingTimer;
  late _FakeCloudBackupStorage storage;
  late AutoCloudSnapshotStore autoStore;
  late CloudSnapshotScheduler scheduler;
  String? userId;
  var autoEnabled = true;
  var online = true;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    MaterialWriteNotifier.suppress = false;
    MaterialWriteNotifier.setListener(null);
    pendingCallback = null;
    pendingTimer = null;
    storage = _FakeCloudBackupStorage();
    autoStore = AutoCloudSnapshotStore(defaultEnabledOnWeb: true);
    userId = 'user-1';
    autoEnabled = true;
    online = true;

    scheduler = CloudSnapshotScheduler(
      debounce: const Duration(seconds: 90),
      cloudBackupRepository: CloudBackupRepository(storage: storage),
      autoStore: autoStore,
      activityStore: BackupActivityStore.instance,
      currentUserId: () async => userId,
      isOnline: () async => online,
      isAutoEnabled: () async => autoEnabled,
      buildExportJson: (_) async => '{"ok":true}',
      createTimer: (duration, callback) {
        pendingTimer?.cancel();
        pendingCallback = callback;
        pendingTimer = Timer(const Duration(hours: 1), () {});
        return pendingTimer!;
      },
    );
  });

  tearDown(() {
    pendingTimer?.cancel();
    MaterialWriteNotifier.suppress = false;
    scheduler.cancelPending();
  });

  Future<void> fireDebounce() async {
    final cb = pendingCallback;
    pendingCallback = null;
    pendingTimer?.cancel();
    pendingTimer = null;
    cb?.call();
    await Future<void>.delayed(Duration.zero);
  }

  test('scheduleAfterMaterialWrite uploads after debounce fires', () async {
    scheduler.scheduleAfterMaterialWrite();
    expect(pendingCallback, isNotNull);
    expect(storage.uploadCount, 0);

    await fireDebounce();
    expect(storage.uploadCount, 1);
    expect(await autoStore.lastSuccessAt('user-1'), isNotNull);
  });

  test('flushNow uploads immediately', () async {
    await scheduler.flushNow();
    expect(storage.uploadCount, 1);
  });

  test('does not upload when signed out', () async {
    userId = null;
    await scheduler.flushNow();
    expect(storage.uploadCount, 0);
  });

  test('does not upload when auto disabled', () async {
    autoEnabled = false;
    await scheduler.flushNow();
    expect(storage.uploadCount, 0);
  });

  test('does not upload when offline', () async {
    online = false;
    await scheduler.flushNow();
    expect(storage.uploadCount, 0);
  });

  test('suppressNotifications skips schedule and flush', () async {
    MaterialWriteNotifier.suppress = true;
    scheduler.scheduleAfterMaterialWrite();
    expect(pendingCallback, isNull);
    await scheduler.flushNow();
    expect(storage.uploadCount, 0);
  });

  test('reschedule replaces previous debounce callback', () async {
    scheduler.scheduleAfterMaterialWrite();
    final first = pendingCallback;
    scheduler.scheduleAfterMaterialWrite();
    expect(pendingCallback, isNot(same(first)));
    await fireDebounce();
    expect(storage.uploadCount, 1);
  });
}
