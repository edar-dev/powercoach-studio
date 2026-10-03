import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/supabase_bootstrap.dart';
import '../backup/local_data_probe.dart';
import '../sync/offline_repository_support.dart';
import 'coach_entities_migration_service.dart';
import 'coach_entities_remote.dart';

/// Pulls cloud `coach_entities` into the Drift cache on sign-in and resume.
///
/// Skips full-replace when local data still awaits (or must retry) one-shot
/// migration upload, so a partial remote snapshot cannot wipe Drift.
class CoachEntitiesSyncCoordinator {
  CoachEntitiesSyncCoordinator({
    CoachEntitiesRemote? remote,
    OfflineRepositorySupport? support,
    LocalDataProbe? localProbe,
    CoachEntitiesMigrationService? migration,
  }) : this._(
          remote: remote ?? CoachEntitiesRemote(),
          support: support,
          localProbe: localProbe ?? LocalDataProbe.instance,
          migration: migration,
        );

  CoachEntitiesSyncCoordinator._({
    required CoachEntitiesRemote remote,
    OfflineRepositorySupport? support,
    required LocalDataProbe localProbe,
    CoachEntitiesMigrationService? migration,
  })  : _remote = remote,
        _localProbe = localProbe,
        _migration = migration ??
            CoachEntitiesMigrationService(
              remote: remote,
              localProbe: localProbe,
            ),
        _support = support ?? OfflineRepositorySupport(remote: remote);

  static final CoachEntitiesSyncCoordinator instance =
      CoachEntitiesSyncCoordinator();

  final CoachEntitiesRemote _remote;
  final OfflineRepositorySupport _support;
  final LocalDataProbe _localProbe;
  final CoachEntitiesMigrationService _migration;
  StreamSubscription<AuthState>? _authSubscription;
  bool _started = false;
  bool _pullInFlight = false;

  void start() {
    if (_started) return;
    _started = true;

    if (SupabaseBootstrap.isInitialized) {
      _authSubscription ??=
          Supabase.instance.client.auth.onAuthStateChange.listen((event) {
        if (event.session?.user != null) {
          unawaited(pullIfSignedIn());
        }
      });
      if (SupabaseBootstrap.currentUser != null) {
        unawaited(pullIfSignedIn());
      }
    }
  }

  void onAppResumed() {
    unawaited(pullIfSignedIn());
  }

  /// True when pull must wait for one-shot local→remote migration (or retry).
  ///
  /// Defers when:
  /// - remote empty + local entities, or
  /// - migration started but not complete (partial upload) + local entities.
  ///
  /// Does **not** defer when remote already has data and migration was never
  /// started on this device (multi-device: pull cloud SoT into cache).
  @visibleForTesting
  Future<bool> shouldDeferPullForMigration(String userId) async {
    if (await _migration.isMigrationComplete(userId)) return false;
    final hasLocal = await _localProbe.hasAnyNonDeletedEntities(userId);
    if (!hasLocal) return false;
    final remoteEmpty = await _remote.isRemoteEmpty();
    if (remoteEmpty) return true;
    return _migration.isMigrationStarted(userId);
  }

  Future<void> pullIfSignedIn() async {
    if (!SupabaseBootstrap.isInitialized) return;
    final user = SupabaseBootstrap.currentUser;
    if (user == null) return;
    if (_pullInFlight) return;
    _pullInFlight = true;
    try {
      if (await shouldDeferPullForMigration(user.id)) {
        debugPrint(
          'CoachEntitiesSyncCoordinator: skip pull — awaiting migration '
          '(remote empty or partial upload in progress)',
        );
        return;
      }
      await _support.pullAndReplaceCache();
    } catch (e, stack) {
      debugPrint('CoachEntitiesSyncCoordinator.pull failed: $e\n$stack');
    } finally {
      _pullInFlight = false;
    }
  }

  void dispose() {
    unawaited(_authSubscription?.cancel());
    _authSubscription = null;
    _started = false;
  }
}
