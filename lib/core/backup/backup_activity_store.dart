import 'package:shared_preferences/shared_preferences.dart';

import '../settings/settings_prefs_keys.dart';

/// Tracks the most recent successful backup (file export or cloud upload)
/// and the reminder snooze window shown on the dashboard/settings.
///
/// Keys are scoped per [userId] so account switches do not leak reminder state.
class BackupActivityStore {
  BackupActivityStore._();

  static final BackupActivityStore instance = BackupActivityStore._();

  String _lastBackupKey(String userId) =>
      '${SettingsPrefsKeys.lastSuccessfulBackupAt}_$userId';

  String _snoozeKey(String userId) =>
      '${SettingsPrefsKeys.backupReminderSnoozeUntil}_$userId';

  Future<DateTime?> lastSuccessfulBackupAt(String userId) async {
    if (userId.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastBackupKey(userId));
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  /// Records a successful backup (file export or cloud upload) at [at]
  /// (defaults to now) and clears any active reminder snooze for [userId].
  Future<void> markBackupSuccess(String userId, {DateTime? at}) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final timestamp = (at ?? DateTime.now()).toUtc();
    await prefs.setString(
      _lastBackupKey(userId),
      timestamp.toIso8601String(),
    );
    await prefs.remove(_snoozeKey(userId));
  }

  Future<DateTime?> reminderSnoozeUntil(String userId) async {
    if (userId.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_snoozeKey(userId));
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  /// Suppresses the backup reminder for [days] (defaults to 3) from [now].
  Future<void> snoozeReminder(
    String userId, {
    int days = 3,
    DateTime? now,
  }) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final base = (now ?? DateTime.now()).toUtc();
    final until = base.add(Duration(days: days));
    await prefs.setString(
      _snoozeKey(userId),
      until.toIso8601String(),
    );
  }

  /// Clears backup activity prefs for [userId] (call on sign-out).
  Future<void> clearForUser(String userId) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastBackupKey(userId));
    await prefs.remove(_snoozeKey(userId));
  }

  /// True when the coach has never backed up, or the last backup is older
  /// than [maxAgeDays] and the reminder isn't currently snoozed.
  Future<bool> shouldShowBackupReminder(
    String userId, {
    DateTime? now,
    int maxAgeDays = 7,
  }) async {
    if (userId.isEmpty) return false;
    final clock = now ?? DateTime.now();
    final snoozedUntil = await reminderSnoozeUntil(userId);
    if (snoozedUntil != null && clock.isBefore(snoozedUntil)) {
      return false;
    }
    final lastBackup = await lastSuccessfulBackupAt(userId);
    if (lastBackup == null) return true;
    return clock.difference(lastBackup) > Duration(days: maxAgeDays);
  }
}
