import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/supabase_bootstrap.dart';
import '../platform/web_storage_persistence.dart';
import '../platform/web_unload_hooks.dart';
import '../remote/coach_entities_migration_service.dart';
import 'auto_cloud_snapshot_store.dart';
import 'backup_activity_store.dart';
import 'cloud_backup_repository.dart';
import 'cloud_backup_storage.dart';
import 'cloud_snapshot_scheduler.dart';
import 'local_data_probe.dart';
import 'material_write_notifier.dart';
import 'sync_on_open_service.dart';
import 'user_data_backup_codec.dart';
import 'user_data_backup_service.dart';
import '../../features/settings/presentation/cloud_recovery_dialog.dart';
import '../../features/settings/presentation/coach_entities_migration_dialog.dart';
import '../../l10n/app_localizations.dart';

/// Coordinates web storage persist, auto cloud snapshots, recovery, and
/// sync-on-open after auth is ready.
class WebPersistenceCoordinator {
  WebPersistenceCoordinator({
    CloudBackupRepository? cloudBackupRepository,
    LocalDataProbe? localDataProbe,
    SyncOnOpenService? syncOnOpenService,
    CloudSnapshotScheduler? scheduler,
    AutoCloudSnapshotStore? autoStore,
    BackupActivityStore? activityStore,
    UserDataBackupService? backupService,
    CoachEntitiesMigrationService? migrationService,
    Future<void> Function()? requestPersist,
    Future<bool> Function()? isPersisted,
  }) : _cloudBackupRepository =
           cloudBackupRepository ?? CloudBackupRepository.instance,
       _localDataProbe = localDataProbe ?? LocalDataProbe.instance,
       _syncOnOpenService = syncOnOpenService ?? SyncOnOpenService.instance,
       _scheduler = scheduler ?? CloudSnapshotScheduler.instance,
       _autoStore = autoStore ?? AutoCloudSnapshotStore.instance,
       _activityStore = activityStore ?? BackupActivityStore.instance,
       _backupService = backupService ?? UserDataBackupService.instance,
       _migrationService =
           migrationService ?? CoachEntitiesMigrationService.instance,
       _requestPersist = requestPersist ?? requestPersistentStorage,
       _isPersisted = isPersisted ?? isStoragePersisted;

  static final WebPersistenceCoordinator instance = WebPersistenceCoordinator();

  final CloudBackupRepository _cloudBackupRepository;
  final LocalDataProbe _localDataProbe;
  final SyncOnOpenService _syncOnOpenService;
  final CloudSnapshotScheduler _scheduler;
  final AutoCloudSnapshotStore _autoStore;
  final BackupActivityStore _activityStore;
  final UserDataBackupService _backupService;
  final CoachEntitiesMigrationService _migrationService;
  final Future<void> Function() _requestPersist;
  final Future<bool> Function() _isPersisted;

  StreamSubscription<AuthState>? _authSubscription;
  bool _started = false;
  bool _storagePersisted = true;
  final Set<String> _recoverySnoozedUserIds = <String>{};
  final Set<String> _syncAttemptedUserIds = <String>{};
  final Set<String> _migrationAttemptedUserIds = <String>{};

  bool get storagePersisted => _storagePersisted;

  void start() {
    if (_started) return;
    _started = true;

    MaterialWriteNotifier.setListener(
      () => CloudSnapshotScheduler.instance.scheduleAfterMaterialWrite(),
    );
    registerWebUnloadHook(_onWebUnload);

    if (SupabaseBootstrap.isInitialized) {
      _authSubscription ??=
          Supabase.instance.client.auth.onAuthStateChange.listen((event) {
        final user = event.session?.user;
        if (user != null) {
          unawaited(_onSignedIn(user.id));
        } else {
          _onSignedOut();
        }
      });
      final current = SupabaseBootstrap.currentUser;
      if (current != null) {
        unawaited(_onSignedIn(current.id));
      }
    }
  }

  Future<void> _onSignedIn(String userId) async {
    if (kIsWeb) {
      try {
        await _requestPersist();
        _storagePersisted = await _isPersisted();
      } catch (e, stack) {
        debugPrint('WebPersistenceCoordinator: persist failed: $e\n$stack');
        _storagePersisted = false;
      }
    } else {
      _storagePersisted = true;
    }

    // Sync-on-open once per session per user (recovery is UI-driven).
    if (!_syncAttemptedUserIds.contains(userId)) {
      _syncAttemptedUserIds.add(userId);
      // Only merge when local is non-empty; empty waits for recovery dialog.
      final empty = await _localDataProbe.isCoachDataEmpty(userId);
      if (!empty) {
        unawaited(_syncOnOpenService.syncIfNeeded(userId: userId));
      }
    }
  }

  void _onSignedOut() {
    _scheduler.cancelPending();
    _recoverySnoozedUserIds.clear();
    _syncAttemptedUserIds.clear();
    _migrationAttemptedUserIds.clear();
  }

  /// Runs one-shot local→cloud migration when remote is empty and local has data.
  ///
  /// Returns `true` when a migration dialog ran and succeeded.
  Future<bool> maybeRunCoachEntitiesMigrationIfNeeded(
    BuildContext context,
  ) async {
    final user = SupabaseBootstrap.currentUser;
    if (user == null) return false;
    if (_migrationAttemptedUserIds.contains(user.id)) return false;

    try {
      final needed = await _migrationService.needsMigration(user.id);
      if (!needed) {
        _migrationAttemptedUserIds.add(user.id);
        return false;
      }
    } catch (e, stack) {
      debugPrint(
        'WebPersistenceCoordinator: migration probe failed: $e\n$stack',
      );
      return false;
    }
    if (!context.mounted) return false;

    final ok = await showCoachEntitiesMigrationDialog(
      context,
      userId: user.id,
      service: _migrationService,
    );
    if (ok) {
      _migrationAttemptedUserIds.add(user.id);
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(l10n.coachEntitiesMigrationSuccess)),
        );
      }
    }
    return ok;
  }

  void _onWebUnload() {
    unawaited(_scheduler.flushNow());
  }

  /// Shows cloud recovery when local coach data is empty and cloud has
  /// snapshots. Snoozed for the rest of the session after dismiss/restore.
  Future<bool> maybeShowCloudRecoveryIfNeeded(BuildContext context) async {
    final user = SupabaseBootstrap.currentUser;
    if (user == null) return false;
    if (_recoverySnoozedUserIds.contains(user.id)) return false;

    final empty = await _localDataProbe.isCoachDataEmpty(user.id);
    if (!empty) return false;

    List<CloudBackupObject> backups;
    try {
      backups = await _cloudBackupRepository.list(user.id);
    } catch (e, stack) {
      debugPrint('WebPersistenceCoordinator: cloud list failed: $e\n$stack');
      return false;
    }
    if (backups.isEmpty) return false;
    if (!context.mounted) return false;

    final l10n = AppLocalizations.of(context);
    final choice = await showCloudRecoveryDialog(context);
    if (!context.mounted) return false;

    // Only snooze on explicit "Not now"; failed/cancelled restore can retry.
    if (choice != CloudRecoveryChoice.restore) {
      _recoverySnoozedUserIds.add(user.id);
      return false;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsBackupImportConfirmTitle),
        content: Text(l10n.settingsBackupImportConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.signOutConfirmCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.settingsBackupImportConfirmReplace),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return false;

    try {
      final newest = backups.first;
      final json = await _cloudBackupRepository.download(user.id, newest.path);
      final parsed = parseUserBackupJson(json, user.id);
      await _backupService.restoreParsed(parsed, user.id);
      await _activityStore.markBackupSuccess(user.id);
      await _autoStore.markSuccess(user.id);
      _recoverySnoozedUserIds.add(user.id);
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(l10n.settingsBackupImportSuccess)),
        );
      }
      return true;
    } catch (e, stack) {
      debugPrint('WebPersistenceCoordinator: restore failed: $e\n$stack');
      await _autoStore.markError(user.id, e.toString());
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(l10n.settingsCloudBackupErrorGeneric)),
        );
      }
      return false;
    }
  }

  /// Settings pull-to-refresh / manual sync button.
  Future<bool> pullCloudSync() => _syncOnOpenService.syncIfNeeded();

  Future<bool> shouldShowStoragePersistHint(String userId) async {
    if (!kIsWeb) return false;
    if (_storagePersisted) return false;
    return !(await _autoStore.isStoragePersistHintDismissed(userId));
  }

  void dispose() {
    unregisterWebUnloadHook(_onWebUnload);
    unawaited(_authSubscription?.cancel());
    _authSubscription = null;
    _started = false;
  }
}
