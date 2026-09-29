import 'package:flutter/foundation.dart';

import '../auth/supabase_bootstrap.dart';
import '../platform/web_online_status.dart';
import 'auto_cloud_snapshot_store.dart';
import 'backup_activity_store.dart';
import 'cloud_backup_repository.dart';
import 'cloud_backup_storage.dart';
import 'cloud_snapshot_scheduler.dart';
import 'local_data_probe.dart';
import 'user_data_backup_codec.dart';
import 'user_data_backup_service.dart';

/// Pulls a newer cloud snapshot on open and merges by `updatedAt`.
///
/// Empty local + cloud available is handled by recovery (replace-all), not here.
class SyncOnOpenService {
  SyncOnOpenService({
    CloudBackupRepository? cloudBackupRepository,
    UserDataBackupService? backupService,
    LocalDataProbe? localDataProbe,
    AutoCloudSnapshotStore? autoStore,
    BackupActivityStore? activityStore,
    CloudSnapshotScheduler? scheduler,
    Future<String?> Function()? currentUserId,
    Future<bool> Function()? isOnline,
  }) : _cloudBackupRepository =
           cloudBackupRepository ?? CloudBackupRepository.instance,
       _backupService = backupService ?? UserDataBackupService.instance,
       _localDataProbe = localDataProbe ?? LocalDataProbe.instance,
       _autoStore = autoStore ?? AutoCloudSnapshotStore.instance,
       _activityStore = activityStore ?? BackupActivityStore.instance,
       _scheduler = scheduler ?? CloudSnapshotScheduler.instance,
       _currentUserId =
           currentUserId ??
           (() async => SupabaseBootstrap.currentUser?.id),
       _isOnline = isOnline ?? (() async => isNavigatorOnline());

  static final SyncOnOpenService instance = SyncOnOpenService();

  final CloudBackupRepository _cloudBackupRepository;
  final UserDataBackupService _backupService;
  final LocalDataProbe _localDataProbe;
  final AutoCloudSnapshotStore _autoStore;
  final BackupActivityStore _activityStore;
  final CloudSnapshotScheduler _scheduler;
  final Future<String?> Function() _currentUserId;
  final Future<bool> Function() _isOnline;

  /// When local is non-empty and the newest cloud snapshot is newer than the
  /// local watermark, downloads and [UserDataBackupService.mergeRestore]s it.
  ///
  /// Returns true when a merge ran successfully.
  Future<bool> syncIfNeeded({String? userId}) async {
    final uid = userId ?? await _currentUserId();
    if (uid == null || uid.isEmpty) return false;

    final online = await _isOnline();
    if (!online) {
      debugPrint('SyncOnOpenService: offline; skip');
      return false;
    }

    final empty = await _localDataProbe.isCoachDataEmpty(uid);
    if (empty) {
      // Recovery dialog owns empty-local + cloud; do not merge here.
      debugPrint('SyncOnOpenService: local empty; skip merge (recovery path)');
      return false;
    }

    List<CloudBackupObject> backups;
    try {
      backups = await _cloudBackupRepository.list(uid);
    } catch (e, stack) {
      debugPrint('SyncOnOpenService: list failed: $e\n$stack');
      await _autoStore.markError(uid, e.toString());
      return false;
    }
    if (backups.isEmpty) return false;

    final newest = backups.first;
    final watermark = await _localWatermark(uid);
    if (watermark != null && !newest.createdAt.isAfter(watermark)) {
      debugPrint(
        'SyncOnOpenService: cloud not newer '
        '(cloud=${newest.createdAt}, watermark=$watermark)',
      );
      return false;
    }

    try {
      final json = await _cloudBackupRepository.download(uid, newest.path);
      final parsed = parseUserBackupJson(json, uid);
      await _backupService.mergeRestore(parsed, uid);
      await _autoStore.markCloudSyncSuccess(uid, at: newest.createdAt);
      await _activityStore.markBackupSuccess(uid);
      // Push local+merged state after open sync.
      _scheduler.scheduleAfterMaterialWrite();
      debugPrint('SyncOnOpenService: merged ${newest.path}');
      return true;
    } catch (e, stack) {
      debugPrint('SyncOnOpenService: merge failed: $e\n$stack');
      await _autoStore.markError(uid, e.toString());
      return false;
    }
  }

  Future<DateTime?> _localWatermark(String userId) async {
    DateTime? max;
    void consider(DateTime? value) {
      if (value == null) return;
      if (max == null || value.isAfter(max!)) max = value;
    }

    consider(await _localDataProbe.maxEntityUpdatedAt(userId));
    consider(await _activityStore.lastSuccessfulBackupAt(userId));
    consider(await _autoStore.lastCloudSyncAt(userId));
    return max;
  }
}
