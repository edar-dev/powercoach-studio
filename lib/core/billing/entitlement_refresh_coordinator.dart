import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'entitlement_repository.dart';

/// Keeps billing entitlements fresh on login, resume, and a light interval.
class EntitlementRefreshCoordinator {
  EntitlementRefreshCoordinator._();

  static final EntitlementRefreshCoordinator instance =
      EntitlementRefreshCoordinator._();

  static const Duration _refreshInterval = Duration(minutes: 15);

  Timer? _periodicTimer;
  StreamSubscription<AuthState>? _authSubscription;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;

    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(
      _refreshInterval,
      (_) => unawaited(refreshIfSignedIn()),
    );

    if (SupabaseBootstrap.isInitialized) {
      _authSubscription ??=
          Supabase.instance.client.auth.onAuthStateChange.listen((event) {
        if (event.session?.user != null) {
          unawaited(refreshIfSignedIn());
        } else {
          EntitlementRepository.instance.entitlement.value = null;
        }
      });
    }
  }

  void onAppResumed() {
    unawaited(refreshIfSignedIn());
  }

  Future<void> refreshIfSignedIn() async {
    if (SupabaseBootstrap.currentUser == null) return;
    if (!SupabaseBootstrap.isInitialized) return;
    try {
      await EntitlementRepository.instance.refresh();
    } catch (e, stack) {
      debugPrint('EntitlementRefreshCoordinator.refresh failed: $e\n$stack');
    }
  }

  void dispose() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    unawaited(_authSubscription?.cancel());
    _authSubscription = null;
    _started = false;
  }
}
