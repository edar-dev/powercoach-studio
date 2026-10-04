/// Web-only PostHog bridge. No-op on non-web platforms.
bool get posthogWebIsInitialized => false;

/// Initializes posthog-js when a project key is present. No-op off web.
bool initPosthogWeb({
  required String apiKey,
  required String host,
}) {
  return false;
}

/// Captures a `$pageview` for [path]. No-op off web / when disabled.
void capturePosthogWebPageview(String path) {}

/// Identifies the current person by stable auth id. No-op off web / when disabled.
void identifyPosthogWeb(String distinctId) {}

/// Resets the PostHog person (e.g. on sign-out). No-op off web / when disabled.
void resetPosthogWeb() {}
