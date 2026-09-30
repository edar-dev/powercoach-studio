import 'dart:async';

import 'package:flutter/foundation.dart';

import '../auth/supabase_bootstrap.dart';
import '../platform/web_online_status.dart';
import 'auto_cloud_snapshot_store.dart';
import 'backup_activity_store.dart';
import 'cloud_backup_repository.dart';
import 'material_write_notifier.dart';
import 'user_data_backup_service.dart';

/// Debounces material local writes into automatic Supabase Storage snapshots.
class CloudSnapshotScheduler {
  CloudSnapshotScheduler({
    this.debounce = const Duration(seconds: 90),
    CloudBackupRepository? cloudBackupRepository,
    UserDataBackupService? backupService,
    AutoCloudSnapshotStore? autoStore,
    BackupActivityStore? activityStore,
    Future<String?> Function()? currentUserId,
    Future<bool> Function()? isOnline,
    Future<bool> Function()? isAutoEnabled,
    Future<String> Function(String userId)? buildExportJson,
    Timer Function(Duration duration, void Function() callback)? createTimer,
  }) : _cloudBackupRepository =
           cloudBackupRepository ?? CloudBackupRepository.instance,
       _backupService = backupService ?? UserDataBackupService.instance,
       _autoStore = autoStore ?? AutoCloudSnapshotStore.instance,
       _activityStore = activityStore ?? BackupActivityStore.instance,
       _currentUserId =
           currentUserId ??
           (() async => SupabaseBootstrap.currentUser?.id),
       _isOnline = isOnline ?? (() async => isNavigatorOnline()),
       _isAutoEnabled =
           isAutoEnabled ??
           (() => (autoStore ?? AutoCloudSnapshotStore.instance).isAutoEnabled()),
       _buildExportJson = buildExportJson,
       _createTimer = createTimer ?? Timer.new;

  static final CloudSnapshotScheduler instance = CloudSnapshotScheduler();

  /// Debounce window after a material write before uploading.
  final Duration debounce;

  final CloudBackupRepository _cloudBackupRepository;
  final UserDataBackupService _backupService;
  final AutoCloudSnapshotStore _autoStore;
  final BackupActivityStore _activityStore;
  final Future<String?> Function() _currentUserId;
  final Future<bool> Function() _isOnline;
  final Future<bool> Function() _isAutoEnabled;
  final Future<String> Function(String userId)? _buildExportJson;
  final Timer Function(Duration duration, void Function() callback)
  _createTimer;

  /// When true, [scheduleAfterMaterialWrite] is a no-op (bulk restore / merge).
  bool get suppressNotifications => MaterialWriteNotifier.suppress;

  set suppressNotifications(bool value) => MaterialWriteNotifier.suppress = value;

  Timer? _debounceTimer;
  bool _uploadInProgress = false;
  bool _pendingAfterUpload = false;

  /// Schedules a debounced cloud snapshot after a material local write.
  void scheduleAfterMaterialWrite() {
    if (MaterialWriteNotifier.suppress) return;
    _debounceTimer?.cancel();
    _debounceTimer = _createTimer(debounce, () {
      _debounceTimer = null;
      unawaited(flushNow());
    });
  }

  /// Cancels any pending debounce and uploads immediately when gates pass.
  Future<void> flushNow() async {
    _debounceTimer?.cancel();
    _debounceTimer = null;

    if (MaterialWriteNotifier.suppress) return;
    if (_uploadInProgress) {
      _pendingAfterUpload = true;
      return;
    }

    final userId = await _currentUserId();
    if (userId == null || userId.isEmpty) return;

    final enabled = await _isAutoEnabled();
    if (!enabled) return;

    final online = await _isOnline();
    if (!online) {
      debugPrint('CloudSnapshotScheduler: offline; skip upload');
      return;
    }

    _uploadInProgress = true;
    try {
      final exportJson = _buildExportJson;
      final json = exportJson != null
          ? await exportJson(userId)
          : await _backupService.buildExportJsonPretty(userId);
      await _cloudBackupRepository.upload(userId, json);
      await _activityStore.markBackupSuccess(userId);
      await _autoStore.markSuccess(userId);
      debugPrint('CloudSnapshotScheduler: upload ok for $userId');
    } catch (e, stack) {
      debugPrint('CloudSnapshotScheduler: upload failed: $e\n$stack');
      await _autoStore.markError(userId, e.toString());
    } finally {
      _uploadInProgress = false;
      if (_pendingAfterUpload) {
        _pendingAfterUpload = false;
        scheduleAfterMaterialWrite();
      }
    }
  }

  /// Runs [action] with scheduling suppressed (restore / merge paths).
  Future<T> runSuppressed<T>(Future<T> Function() action) =>
      MaterialWriteNotifier.runSuppressed(action);

  void cancelPending() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  bool get hasPendingTimer => _debounceTimer != null;
}
