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
    this.workoutBuilderCompactAdd,
    this.workoutBuilderIncludeMobilityDefault = true,
  });

  final String localeCode;
  final bool notificationsEnabled;
  final bool calendarRemindersEnabled;
  final int calendarReminderLeadHours;

  /// When non-null, overrides auto compact-add detection in the workout builder.
  final bool? workoutBuilderCompactAdd;

  /// Default mobility tab visibility for newly created workout plans.
  final bool workoutBuilderIncludeMobilityDefault;
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

  Future<bool?> getWorkoutBuilderCompactAdd() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(SettingsPrefsKeys.workoutBuilderCompactAdd)) {
      return null;
    }
    return prefs.getBool(SettingsPrefsKeys.workoutBuilderCompactAdd);
  }

  Future<void> setWorkoutBuilderCompactAdd(bool? enabled) async {
    final prefs = await SharedPreferences.getInstance();
    if (enabled == null) {
      await prefs.remove(SettingsPrefsKeys.workoutBuilderCompactAdd);
      return;
    }
    await prefs.setBool(SettingsPrefsKeys.workoutBuilderCompactAdd, enabled);
  }

  Future<bool> getWorkoutBuilderIncludeMobilityDefault({
    bool defaultValue = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SettingsPrefsKeys.workoutBuilderIncludeMobilityDefault) ??
        defaultValue;
  }

  Future<void> setWorkoutBuilderIncludeMobilityDefault(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      SettingsPrefsKeys.workoutBuilderIncludeMobilityDefault,
      enabled,
    );
  }

  Future<UserPreferences> loadAll() async {
    return UserPreferences(
      localeCode: await getLocaleCode(),
      notificationsEnabled: await getNotificationsEnabled(),
      calendarRemindersEnabled: await getCalendarRemindersEnabled(),
      calendarReminderLeadHours: await getCalendarReminderLeadHours(),
      workoutBuilderCompactAdd: await getWorkoutBuilderCompactAdd(),
      workoutBuilderIncludeMobilityDefault:
          await getWorkoutBuilderIncludeMobilityDefault(),
    );
  }
}
