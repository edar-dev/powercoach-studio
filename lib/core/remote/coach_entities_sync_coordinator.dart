import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/supabase_bootstrap.dart';
import '../sync/offline_repository_support.dart';
import 'coach_entities_remote.dart';

/// Pulls cloud `coach_entities` into the Drift cache on sign-in and resume.
class CoachEntitiesSyncCoordinator {
  CoachEntitiesSyncCoordinator({
    OfflineRepositorySupport? support,
  }) : _support = support ??
            OfflineRepositorySupport(remote: CoachEntitiesRemote());

  static final CoachEntitiesSyncCoordinator instance =
      CoachEntitiesSyncCoordinator();

  final OfflineRepositorySupport _support;
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

  Future<void> pullIfSignedIn() async {
    if (!SupabaseBootstrap.isInitialized) return;
    if (SupabaseBootstrap.currentUser == null) return;
    if (_pullInFlight) return;
    _pullInFlight = true;
    try {
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
