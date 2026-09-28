/// Canonical GoRouter paths for full-page features.
///
/// Every important screen must have a dedicated top-level path (see
/// `.cursor/rules/15-dedicated-routes.mdc`). Prefer these constants over
/// string literals when navigating or linking.
///
/// Removed surfaces (gym hub, plan-diff, coach stats, release notes) keep
/// legacy URL redirects in [resolveAppRouteRedirect] / [buildAppRoutes] only —
/// do not reintroduce path constants for those destinations.
abstract final class AppPaths {
  static const subscription = '/subscription';

  /// Legacy nested path; kept for redirects and external bookmarks.
  static const subscriptionLegacy = '/settings/subscription';

  static const settings = '/settings';

  /// Personal info (canonical destination for legacy `/profile`).
  static const personalInfo = '/settings/personal-info';
}
