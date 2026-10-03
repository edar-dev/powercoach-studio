/// SharedPreferences keys used across settings and backup export/import.
abstract final class SettingsPrefsKeys {
  static const notificationsEnabled = 'settings_notifications_enabled';
  static const appLocaleCode = 'app_locale_code';


  /// JSON list of recently selected custom exercise IDs.
  static const recentExerciseIdsJson = 'recent_exercise_ids_json_v1';

  /// JSON list of pinned custom exercise IDs.
  static const pinnedExerciseIdsJson = 'pinned_exercise_ids_json_v1';

  /// When true, skip auto-seeding the default PowerCoach catalog after an
  /// intentional library clear (until the user imports the default catalog).
  static const exerciseLibrarySkipAutoSeed =
      'exercise_library_skip_auto_seed_v1';

  /// When true, schedule reminders before planned calendar sessions.
  static const calendarRemindersEnabled = 'settings_calendar_reminders_enabled';

  /// Hours before a session when the calendar reminder fires (default 24).
  static const calendarReminderLeadHours =
      'settings_calendar_reminder_lead_hours';

  /// When true, always use compact exercise-add sheet; when false, use width-based auto.
  static const workoutBuilderCompactAdd = 'workout_builder_compact_add_v1';

  /// Default for new plans: include mobility tab in workout builder.
  static const workoutBuilderIncludeMobilityDefault =
      'workout_builder_include_mobility_default_v1';

  /// ISO8601 timestamp of the last successful backup (file export or cloud upload).
  static const lastSuccessfulBackupAt = 'backup_last_successful_at_v1';

  /// ISO8601 timestamp until which the backup-age reminder stays snoozed.
  static const backupReminderSnoozeUntil = 'backup_reminder_snooze_until_v1';

  /// When true, debounced automatic cloud snapshots are enabled.
  static const autoCloudSnapshotEnabled = 'auto_cloud_snapshot_enabled_v1';

  /// Last automatic cloud snapshot error message (per user suffix).
  static const autoCloudSnapshotLastError = 'auto_cloud_snapshot_last_error_v1';

  /// ISO8601 timestamp of the last successful cloud snapshot upload
  /// (automatic scheduler or manual Settings upload).
  static const autoCloudSnapshotLastAt = 'auto_cloud_snapshot_last_at_v1';

  /// When true, the web storage-persist hint was dismissed in Settings.
  static const storagePersistedHintDismissed =
      'storage_persisted_hint_dismissed_v1';

  /// ISO8601 timestamp of the last successful sync-on-open cloud merge.
  static const lastCloudSyncAt = 'last_cloud_sync_at_v1';

  /// Prefix for per-user one-shot coach_entities local→remote migration flag.
  /// Full key: `coach_entities_migration_v1_<userId>`.
  static const coachEntitiesMigrationCompletePrefix =
      'coach_entities_migration_v1_';

  /// SharedPreferences key marking migration upload complete for [userId].
  static String coachEntitiesMigrationCompleteKey(String userId) =>
      '$coachEntitiesMigrationCompletePrefix$userId';

  /// Prefix for in-progress migration (set before first upsert; cleared on success).
  /// Full key: `coach_entities_migration_started_v1_<userId>`.
  static const coachEntitiesMigrationStartedPrefix =
      'coach_entities_migration_started_v1_';

  static String coachEntitiesMigrationStartedKey(String userId) =>
      '$coachEntitiesMigrationStartedPrefix$userId';
}
