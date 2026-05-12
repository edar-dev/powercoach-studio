/// SharedPreferences keys used across settings and backup export/import.
abstract final class SettingsPrefsKeys {
  static const notificationsEnabled = 'settings_notifications_enabled';
  static const appLocaleCode = 'app_locale_code';

  /// JSON array of reminder maps (Feature 02).
  static const remindersListJson = 'powercoach_reminders_json_v1';
}
