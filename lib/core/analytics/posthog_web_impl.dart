import 'dart:js_interop';

import 'package:flutter/foundation.dart';

@JS('__powercoachPostHog')
external PowerCoachPosthogJs? get _powerCoachPosthog;

/// JS bridge installed by `web/posthog_loader.js`.
extension type PowerCoachPosthogJs(JSObject _) implements JSObject {
  external bool get initialized;

  external bool init(String apiKey, String host);

  external void capturePageview(String path);

  external void identify(String distinctId);

  external void reset();
}

/// Whether the JS bridge has completed `init` with a project key.
bool get posthogWebIsInitialized {
  final bridge = _powerCoachPosthog;
  if (bridge == null) return false;
  try {
    return bridge.initialized;
  } catch (_) {
    return false;
  }
}

/// Initializes posthog-js via the HTML loader bridge.
bool initPosthogWeb({
  required String apiKey,
  required String host,
}) {
  final bridge = _powerCoachPosthog;
  if (bridge == null) {
    debugPrint(
      'powercoach-studio: PostHog loader missing (web/posthog_loader.js); skipped.',
    );
    return false;
  }
  try {
    return bridge.init(apiKey, host);
  } catch (e) {
    debugPrint('powercoach-studio: PostHog init failed: $e');
    return false;
  }
}

/// Captures a `$pageview` for [path].
void capturePosthogWebPageview(String path) {
  if (!posthogWebIsInitialized) return;
  final trimmed = path.trim();
  if (trimmed.isEmpty) return;
  try {
    _powerCoachPosthog?.capturePageview(trimmed);
  } catch (_) {
    // Best-effort analytics; never break navigation.
  }
}

/// Identifies the current person by stable auth id (no email).
void identifyPosthogWeb(String distinctId) {
  if (!posthogWebIsInitialized) return;
  final id = distinctId.trim();
  if (id.isEmpty) return;
  try {
    _powerCoachPosthog?.identify(id);
  } catch (_) {}
}

/// Resets the PostHog person (e.g. on sign-out).
void resetPosthogWeb() {
  if (!posthogWebIsInitialized) return;
  try {
    _powerCoachPosthog?.reset();
  } catch (_) {}
}
