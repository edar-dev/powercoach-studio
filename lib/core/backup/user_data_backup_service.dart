import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../notifications/notification_scheduler_service.dart';
import '../notifications/reminder.dart';
import '../notifications/reminder_store.dart';
import '../settings/settings_prefs_keys.dart';
import '../storage/local_user_profile_store.dart';
import '../storage/offline_local_store.dart';
import '../sync/offline_models.dart';
import 'user_data_backup_codec.dart';

/// Builds and restores full offline user snapshots (JSON envelope v1).
class UserDataBackupService {
  UserDataBackupService._();

  static final UserDataBackupService instance = UserDataBackupService._();

  Future<Map<String, dynamic>> buildExportMap(String accountUserId) async {
    if (accountUserId.isEmpty) {
      throw StateError('accountUserId required');
    }
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled =
        prefs.getBool(SettingsPrefsKeys.notificationsEnabled) ?? true;
    final profile =
        await LocalUserProfileStore.instance.read(accountUserId);
    final store = OfflineLocalStore.instance;

    return <String, dynamic>{
      'schemaVersion': kUserBackupSchemaVersion,
      'exportFormat': kUserBackupExportFormat,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'accountUserId': accountUserId,
      'preferences': <String, dynamic>{
        SettingsPrefsKeys.notificationsEnabled: notificationsEnabled,
      },
      'localUserProfile': profile.toJson(),
      'entities': await store.listEntitiesJsonForBackup(accountUserId),
      'pendingOperations': await store.listPendingJsonForBackup(accountUserId),
      'syncMeta': await store.listSyncMetaJsonForBackup(accountUserId),
      'reminders': await ReminderStore.instance.exportMaps(),
    };
  }

  Future<String> buildExportJsonPretty(String accountUserId) async {
    final map = await buildExportMap(accountUserId);
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  /// Replace-local snapshot for [accountUserId] with parsed backup (destructive).
  Future<void> restoreParsed(ParsedUserBackup parsed, String accountUserId) async {
    if (accountUserId.isEmpty) {
      throw StateError('accountUserId required');
    }
    await OfflineLocalStore.instance.replaceUserOfflineFromBackup(
      userId: accountUserId,
      entities: parsed.entities,
      pendingOperations: parsed.pendingOperations,
      syncMeta: parsed.syncMeta,
    );
    final profile = parsed.profileJson == null
        ? const LocalUserProfileData()
        : LocalUserProfileData.fromJson(parsed.profileJson!);
    await LocalUserProfileStore.instance.write(accountUserId, profile);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      SettingsPrefsKeys.notificationsEnabled,
      parsed.notificationsEnabled,
    );
    await ReminderStore.instance.replaceFromMaps(parsed.reminders);
    await NotificationSchedulerService.instance
        .syncWithNotificationPreference();
  }

  BackupPreviewCounts previewCounts(ParsedUserBackup parsed) =>
      previewCountsFromBackup(parsed);

  /// Merge backup entities by id, keeping the row with the newest [updatedAt].
  Future<void> mergeRestore(
    ParsedUserBackup parsed,
    String accountUserId,
  ) async {
    if (accountUserId.isEmpty) {
      throw StateError('accountUserId required');
    }
    final store = OfflineLocalStore.instance;
    for (final raw in parsed.entities) {
      final body = Map<String, dynamic>.from(raw)..remove('userId');
      if (!body.containsKey('type') || !body.containsKey('payload')) {
        continue;
      }
      final incoming = OfflineEntity.fromJson(body);
      final existing = await store.readEntityById(incoming.type, incoming.id);
      if (existing == null ||
          !existing.updatedAt.isAfter(incoming.updatedAt)) {
        await store.upsertEntity(incoming);
      }
    }

    if (parsed.profileJson != null) {
      final profile = LocalUserProfileData.fromJson(parsed.profileJson!);
      await LocalUserProfileStore.instance.write(accountUserId, profile);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      SettingsPrefsKeys.notificationsEnabled,
      parsed.notificationsEnabled,
    );

    if (parsed.reminders.isNotEmpty) {
      final existing = await ReminderStore.instance.loadAll();
      final byId = {for (final r in existing) r.id: r};
      for (final raw in parsed.reminders) {
        final reminder = Reminder.tryFromJson(raw);
        if (reminder != null) {
          byId[reminder.id] = reminder;
        }
      }
      await ReminderStore.instance.replaceFromMaps(
        byId.values.map((r) => r.toJson()).toList(),
      );
    }

    await NotificationSchedulerService.instance
        .syncWithNotificationPreference();
  }
}
