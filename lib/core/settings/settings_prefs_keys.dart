/// SharedPreferences keys used across settings and backup export/import.
abstract final class SettingsPrefsKeys {
  static const notificationsEnabled = 'settings_notifications_enabled';
  static const appLocaleCode = 'app_locale_code';

  /// JSON array of reminder maps (Feature 02).
  static const remindersListJson = 'powercoach_reminders_json_v1';

  /// Hevy Pro API key (coach account).
  static const hevyApiKey = 'hevy_api_key_v1';

  /// JSON map powercoachKey → hevyTemplateId for manual export overrides.
  static const hevyExerciseMappingsJson = 'hevy_exercise_mappings_json_v1';

  /// JSON list of recently selected custom exercise IDs.
  static const recentExerciseIdsJson = 'recent_exercise_ids_json_v1';

  /// JSON list of pinned custom exercise IDs.
  static const pinnedExerciseIdsJson = 'pinned_exercise_ids_json_v1';

  /// When true, schedule reminders before planned calendar sessions.
  static const calendarRemindersEnabled = 'settings_calendar_reminders_enabled';

  /// Hours before a session when the calendar reminder fires (default 24).
  static const calendarReminderLeadHours = 'settings_calendar_reminder_lead_hours';

  /// When true, always use compact exercise-add sheet; when false, use width-based auto.
  static const workoutBuilderCompactAdd = 'workout_builder_compact_add_v1';

  /// Default for new plans: include mobility tab in workout builder.
  static const workoutBuilderIncludeMobilityDefault =
      'workout_builder_include_mobility_default_v1';
}
