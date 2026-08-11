/// Canonical GoRouter paths for full-page features.
///
/// Every important screen must have a dedicated top-level path (see
/// `.cursor/rules/15-dedicated-routes.mdc`). Prefer these constants over
/// string literals when navigating or linking.
abstract final class AppPaths {
  static const subscription = '/subscription';

  /// Legacy nested path; kept for redirects and external bookmarks.
  static const subscriptionLegacy = '/settings/subscription';

  static const settings = '/settings';

  /// Gym mode — full-page session runner for today's scheduled sessions.
  static const gym = '/gym';
}
