import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/supabase_bootstrap.dart';
import 'posthog_web.dart';

/// Default PostHog ingest host (EU cloud).
///
/// Chosen because the product’s primary locale/market is Italy; override with
/// [posthogHostEnvKey] when the PostHog project is US-hosted.
const posthogDefaultHost = 'https://eu.i.posthog.com';

const posthogApiKeyEnvKey = 'POSTHOG_API_KEY';
const posthogHostEnvKey = 'POSTHOG_HOST';

/// Env-gated PostHog bootstrap for Flutter **web** only.
///
/// Mirrors Sentry’s “empty key = off” pattern. Unlike Sentry, debug/profile
/// also initialize when the key is set so heatmap go/no-go can be validated
/// locally with `flutter run -d chrome`.
class PostHogBootstrap {
  PostHogBootstrap._();

  static StreamSubscription<AuthState>? _authSubscription;
  static bool _initAttempted = false;
  static bool _routerBound = false;
  static String? _lastPath;

  /// True when a non-empty `POSTHOG_API_KEY` is present in dotenv.
  static bool get isConfigured {
    final key = dotenv.env[posthogApiKeyEnvKey]?.trim();
    return key != null && key.isNotEmpty;
  }

  /// True after a successful web JS `init`.
  static bool get isEnabled => posthogWebIsInitialized;

  /// Resolved ingest host (env or [posthogDefaultHost]).
  static String get resolvedHost {
    final host = dotenv.env[posthogHostEnvKey]?.trim();
    if (host == null || host.isEmpty) return posthogDefaultHost;
    return host;
  }

  /// Loads posthog-js when running on web with a configured API key.
  static void ensureInitialized() {
    if (_initAttempted) return;
    _initAttempted = true;

    if (!kIsWeb) {
      return;
    }

    final key = dotenv.env[posthogApiKeyEnvKey]?.trim();
    if (key == null || key.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          'powercoach-studio: $posthogApiKeyEnvKey not set; PostHog disabled.',
        );
      }
      return;
    }

    final ok = initPosthogWeb(apiKey: key, host: resolvedHost);
    if (ok) {
      debugPrint(
        'powercoach-studio: PostHog enabled (host=$resolvedHost).',
      );
    }
  }

  /// Emits `$pageview` on go_router location changes (matched path).
  ///
  /// Preferred over [NavigatorObserver] alone because many GoRoutes omit
  /// `name`, so `route.settings.name` is often null.
  static void bindRouter(GoRouter router) {
    if (!isEnabled || _routerBound) return;
    _routerBound = true;

    void emit() {
      if (!isEnabled) return;
      try {
        final matched = router.state.matchedLocation.trim();
        final path = matched.isEmpty ? '/' : matched;
        if (path == _lastPath) return;
        _lastPath = path;
        capturePosthogWebPageview(path);
      } catch (_) {
        // Router not ready yet; ignore.
      }
    }

    router.routerDelegate.addListener(emit);
    emit();
  }

  /// Binds identify/reset to Supabase auth changes. Safe to call after
  /// [SupabaseBootstrap.ensureInitialized].
  static void bindAuthIdentity() {
    if (!isEnabled || !SupabaseBootstrap.isInitialized) return;
    if (_authSubscription != null) return;

    _syncIdentity(SupabaseBootstrap.currentUser?.id);
    try {
      _authSubscription =
          Supabase.instance.client.auth.onAuthStateChange.listen((state) {
        final event = state.event;
        if (event == AuthChangeEvent.signedOut) {
          resetPosthogWeb();
          return;
        }
        final id = state.session?.user.id ?? SupabaseBootstrap.currentUser?.id;
        _syncIdentity(id);
      });
    } catch (_) {
      // Auth client unavailable; leave anonymous distinct id.
    }
  }

  static void _syncIdentity(String? userId) {
    final id = userId?.trim();
    if (id == null || id.isEmpty) return;
    identifyPosthogWeb(id);
  }

  /// Test-only: reset one-shot init / auth binding flags.
  @visibleForTesting
  static void debugReset() {
    unawaited(_authSubscription?.cancel());
    _authSubscription = null;
    _initAttempted = false;
    _routerBound = false;
    _lastPath = null;
  }

  /// Last pageview path emitted by [bindRouter].
  @visibleForTesting
  static String? get debugLastPath => _lastPath;
}
