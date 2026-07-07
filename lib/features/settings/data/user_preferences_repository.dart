import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/settings/settings_prefs_keys.dart';

/// Default hours before a session when calendar reminders fire.
const kDefaultCalendarReminderLeadHours = 24;

/// Snapshot of coach app preferences stored in SharedPreferences.
class UserPreferences {
  const UserPreferences({
    required this.localeCode,
    required this.notificationsEnabled,
    required this.calendarRemindersEnabled,
    required this.calendarReminderLeadHours,
  });

  final String localeCode;
  final bool notificationsEnabled;
  final bool calendarRemindersEnabled;
  final int calendarReminderLeadHours;
}

/// Reads and writes settings-scoped SharedPreferences keys.
class UserPreferencesRepository {
  UserPreferencesRepository._();

  static final UserPreferencesRepository instance =
      UserPreferencesRepository._();

  Future<String> getLocaleCode({String defaultValue = 'it'}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SettingsPrefsKeys.appLocaleCode) ?? defaultValue;
  }

  Future<void> setLocaleCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SettingsPrefsKeys.appLocaleCode, code);
  }

  Future<bool> getNotificationsEnabled({bool defaultValue = true}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SettingsPrefsKeys.notificationsEnabled) ?? defaultValue;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SettingsPrefsKeys.notificationsEnabled, enabled);
  }

  Future<bool> getCalendarRemindersEnabled({bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SettingsPrefsKeys.calendarRemindersEnabled) ??
        defaultValue;
  }

  Future<void> setCalendarRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SettingsPrefsKeys.calendarRemindersEnabled, enabled);
  }

  Future<int> getCalendarReminderLeadHours({
    int defaultValue = kDefaultCalendarReminderLeadHours,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(SettingsPrefsKeys.calendarReminderLeadHours) ??
        defaultValue;
  }

  Future<void> setCalendarReminderLeadHours(int hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(SettingsPrefsKeys.calendarReminderLeadHours, hours);
  }

  Future<UserPreferences> loadAll() async {
    return UserPreferences(
      localeCode: await getLocaleCode(),
      notificationsEnabled: await getNotificationsEnabled(),
      calendarRemindersEnabled: await getCalendarRemindersEnabled(),
      calendarReminderLeadHours: await getCalendarReminderLeadHours(),
    );
  }
}
