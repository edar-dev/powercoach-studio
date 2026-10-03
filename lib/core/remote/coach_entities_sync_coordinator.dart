import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/supabase_bootstrap.dart';
import '../backup/local_data_probe.dart';
import '../sync/offline_repository_support.dart';
import 'coach_entities_remote.dart';

/// Pulls cloud `coach_entities` into the Drift cache on sign-in and resume.
///
/// Skips full-replace when the remote is empty and local coach data exists so
/// the one-shot migration upload (PR3) can run without wiping Drift first.
class CoachEntitiesSyncCoordinator {
  CoachEntitiesSyncCoordinator({
    CoachEntitiesRemote? remote,
    OfflineRepositorySupport? support,
    LocalDataProbe? localProbe,
  }) : this._(
          remote: remote ?? CoachEntitiesRemote(),
          support: support,
          localProbe: localProbe ?? LocalDataProbe.instance,
        );

  CoachEntitiesSyncCoordinator._({
    required CoachEntitiesRemote remote,
    OfflineRepositorySupport? support,
    required LocalDataProbe localProbe,
  })  : _remote = remote,
        _localProbe = localProbe,
        _support = support ?? OfflineRepositorySupport(remote: remote);

  static final CoachEntitiesSyncCoordinator instance =
      CoachEntitiesSyncCoordinator();

  final CoachEntitiesRemote _remote;
  final OfflineRepositorySupport _support;
  final LocalDataProbe _localProbe;
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

  /// True when pull must wait for one-shot local→remote migration.
  @visibleForTesting
  Future<bool> shouldDeferPullForMigration(String userId) async {
    final remoteEmpty = await _remote.isRemoteEmpty();
    if (!remoteEmpty) return false;
    final localEmpty = await _localProbe.isCoachDataEmpty(userId);
    return !localEmpty;
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
          'CoachEntitiesSyncCoordinator: skip pull — remote empty, '
          'local data present (awaiting migration upload)',
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
