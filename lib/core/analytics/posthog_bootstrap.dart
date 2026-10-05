import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/supabase_bootstrap.dart';
import 'analytics_consent_store.dart';
import 'posthog_web.dart';

/// Default PostHog ingest host (EU cloud).
///
/// Chosen because the product’s primary locale/market is Italy; override with
/// [posthogHostEnvKey] when the PostHog project is US-hosted.
///
/// Local / non-Vercel web should keep this absolute URL. Vercel production web
/// uses the first-party reverse proxy path [posthogFirstPartyProxyPath] instead
/// (see `vercel.json` / `scripts/package-vercel-prebuilt.sh`).
const posthogDefaultHost = 'https://eu.i.posthog.com';

/// Same-origin PostHog reverse-proxy path on Vercel (EU ingest + assets).
const posthogFirstPartyProxyPath = '/pcs-ph';

/// PostHog EU app host for toolbar / recording UI links (never the proxy path).
const posthogUiHost = 'https://eu.posthog.com';

const posthogApiKeyEnvKey = 'POSTHOG_API_KEY';
const posthogHostEnvKey = 'POSTHOG_HOST';

/// Env-gated PostHog bootstrap for Flutter **web** only.
///
/// Init runs only after analytics consent is granted (EU). Empty
/// `POSTHOG_API_KEY` keeps PostHog fully off. Mobile/native is always a no-op.
class PostHogBootstrap {
  PostHogBootstrap._();

  static StreamSubscription<AuthState>? _authSubscription;
  static bool _initAttempted = false;
  static bool _routerBound = false;
  static GoRouter? _router;
  static String? _lastPath;
  static AnalyticsConsent? _consentCache;

  /// True when a non-empty `POSTHOG_API_KEY` is present in dotenv.
  static bool get isConfigured {
    final key = dotenv.env[posthogApiKeyEnvKey]?.trim();
    return key != null && key.isNotEmpty;
  }

  /// True after a successful web JS `init` (requires prior consent).
  static bool get isEnabled => posthogWebIsInitialized;

  /// Last known consent decision (may be null before [loadConsent] / bootstrap).
  static AnalyticsConsent? get consent => _consentCache;

  /// True when web + key configured and the user has not decided yet.
  static bool get needsConsentBanner {
    if (!kIsWeb || !isConfigured) return false;
    return _consentCache == null;
  }

  /// Resolved ingest host (env or [posthogDefaultHost]).
  ///
  /// Accepts absolute PostHog cloud hosts (`https://eu.i.posthog.com`) or a
  /// relative first-party proxy path ([posthogFirstPartyProxyPath]) for Vercel
  /// web production. Passed through to `posthog-js` as `api_host`.
  static String get resolvedHost {
    final host = dotenv.env[posthogHostEnvKey]?.trim();
    if (host == null || host.isEmpty) return posthogDefaultHost;
    return host;
  }

  /// Loads persisted consent into memory. Safe to call on all platforms.
  static Future<AnalyticsConsent?> loadConsent() async {
    if (!kIsWeb || !isConfigured) {
      _consentCache = AnalyticsConsent.denied;
      return _consentCache;
    }
    _consentCache = await AnalyticsConsentStore.instance.read();
    return _consentCache;
  }

  /// Registers [router] for `$pageview` binding once PostHog is enabled.
  static void bindRouter(GoRouter router) {
    _router = router;
    _tryBindRouter();
  }

  /// Initializes PostHog when consent was previously granted.
  ///
  /// Prefer calling after [loadConsent]. No-op off-web, without key, or when
  /// consent is missing/denied.
  static void ensureInitialized() {
    if (_initAttempted) return;
    _initAttempted = true;

    if (!kIsWeb) return;
    if (!isConfigured) {
      if (kDebugMode) {
        debugPrint(
          'powercoach-studio: $posthogApiKeyEnvKey not set; PostHog disabled.',
        );
      }
      return;
    }
    if (_consentCache != AnalyticsConsent.granted) {
      if (kDebugMode) {
        debugPrint(
          'powercoach-studio: PostHog waiting for analytics consent.',
        );
      }
      return;
    }

    _initJsBridge();
  }

  /// Full web bootstrap: load consent → init if granted → bind router.
  static Future<void> bootstrapWithConsent(GoRouter router) async {
    _router = router;
    await loadConsent();
    if (_consentCache == AnalyticsConsent.granted) {
      _initAttempted = false;
      ensureInitialized();
      _tryBindRouter();
    }
  }

  /// User accepted analytics + session replay.
  static Future<void> acceptConsent() async {
    await AnalyticsConsentStore.instance.set(AnalyticsConsent.granted);
    _consentCache = AnalyticsConsent.granted;
    _initAttempted = false;
    ensureInitialized();
    if (isEnabled) {
      optInPosthogWebCapturing();
      _tryBindRouter();
      bindAuthIdentity();
    }
  }

  /// User declined analytics + session replay (no capture).
  static Future<void> declineConsent() async {
    await AnalyticsConsentStore.instance.set(AnalyticsConsent.denied);
    _consentCache = AnalyticsConsent.denied;
    if (isEnabled) {
      optOutPosthogWebCapturing();
      resetPosthogWeb();
    }
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

  static void _initJsBridge() {
    final key = dotenv.env[posthogApiKeyEnvKey]?.trim();
    if (key == null || key.isEmpty) return;

    final ok = initPosthogWeb(apiKey: key, host: resolvedHost);
    if (ok) {
      optInPosthogWebCapturing();
      debugPrint(
        'powercoach-studio: PostHog enabled (host=$resolvedHost, replay on).',
      );
    }
  }

  static void _tryBindRouter() {
    final router = _router;
    if (!isEnabled || _routerBound || router == null) return;
    _routerBound = true;

    void emit() {
      if (!isEnabled) return;
      try {
        final matched = router.state.matchedLocation.trim();
        final path = matched.isEmpty ? '/' : _sanitizePagePath(matched);
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

  static void _syncIdentity(String? userId) {
    final id = userId?.trim();
    if (id == null || id.isEmpty) return;
    identifyPosthogWeb(id);
  }

  /// Redacts entity ids from router paths before `$pageview` (no client UUIDs).
  static String _sanitizePagePath(String path) {
    var result = path;
    // Standard UUIDs.
    result = result.replaceAll(
      RegExp(
        r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}',
      ),
      ':id',
    );
    // Offline temp ids (e.g. customer_…, workout_…).
    result = result.replaceAllMapped(
      RegExp(r'/(customer|workout|measurement|note)_[A-Za-z0-9]+'),
      (m) => '/:id',
    );
    return result.isEmpty ? '/' : result;
  }

  /// Test-only: reset one-shot init / auth binding flags.
  @visibleForTesting
  static void debugReset() {
    unawaited(_authSubscription?.cancel());
    _authSubscription = null;
    _initAttempted = false;
    _routerBound = false;
    _router = null;
    _lastPath = null;
    _consentCache = null;
  }

  /// Last pageview path emitted by [bindRouter].
  @visibleForTesting
  static String? get debugLastPath => _lastPath;

  /// Test-only: expose path sanitization used for `$pageview`.
  @visibleForTesting
  static String debugSanitizePagePath(String path) => _sanitizePagePath(path);

  /// Test-only: seed consent cache without touching SharedPreferences.
  @visibleForTesting
  static void debugSetConsent(AnalyticsConsent? consent) {
    _consentCache = consent;
  }
}
