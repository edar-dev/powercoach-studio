/// Canonical Sentry release / dist naming for PowerCoach Studio.
///
/// Keep this in sync with `scripts/sentry-upload.sh` and build scripts that
/// pass `--dart-define=APP_VERSION=…` / `APP_BUILD=…`.
class SentryReleaseInfo {
  const SentryReleaseInfo._();

  /// Marketing / pubspec version without `+build` (e.g. `1.0.7`).
  static const String appVersion =
      String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');

  /// Pubspec build number after `+` (e.g. `8`).
  static const String appBuild =
      String.fromEnvironment('APP_BUILD', defaultValue: '0');

  /// Sentry `release` tag. Must match CI symbol / source-map uploads.
  static String get release => 'powercoach-studio@$appVersion';

  /// Sentry `dist` (build number) for correlating native/web artifacts.
  static String get dist => appBuild;
}
