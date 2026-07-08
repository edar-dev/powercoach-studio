import 'dart:convert';

import '../constants/app_info.dart';
import '../notifications/notification_scheduler_service.dart';
import '../notifications/reminder.dart';
import '../notifications/reminder_store.dart';
import '../../features/settings/data/user_preferences_repository.dart';
import '../settings/settings_prefs_keys.dart';
import '../../features/auth/data/local_coach_profile_repository.dart';
import '../storage/offline_local_store.dart';
import '../sync/offline_models.dart';
import 'user_data_backup_codec.dart';
import 'backup_entity_groups.dart';

/// Builds and restores full offline user snapshots (JSON envelope v1).
class UserDataBackupService {
  UserDataBackupService._();

  static final UserDataBackupService instance = UserDataBackupService._();

  Future<Map<String, dynamic>> buildExportMap(String accountUserId) async {
    if (accountUserId.isEmpty) {
      throw StateError('accountUserId required');
    }
    final notificationsEnabled =
        await UserPreferencesRepository.instance.getNotificationsEnabled();
    final profile =
        await LocalCoachProfileRepository.instance.getProfile(accountUserId);
    final store = OfflineLocalStore.instance;

    final entities = await store.listEntitiesJsonForBackup(accountUserId);
    final reminders = await ReminderStore.instance.exportMaps();
    final counts = entityCountsFromBackupEntities(
      entities,
      reminders: reminders.length,
    );

    return <String, dynamic>{
      'schemaVersion': kUserBackupSchemaVersion,
      'exportFormat': kUserBackupExportFormat,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'appVersion': kAppVersionLabel,
      'entityCounts': entityCountsMapFromPreview(counts),
      'accountUserId': accountUserId,
      'preferences': <String, dynamic>{
        SettingsPrefsKeys.notificationsEnabled: notificationsEnabled,
      },
      'localUserProfile': profile.toJson(),
      'entities': entities,
      'pendingOperations': await store.listPendingJsonForBackup(accountUserId),
      'syncMeta': await store.listSyncMetaJsonForBackup(accountUserId),
      'reminders': reminders,
    };
  }

  Future<String> buildExportJsonPretty(String accountUserId) async {
    final map = await buildExportMap(accountUserId);
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  /// Replace-local snapshot for [accountUserId] with parsed backup (destructive).
  ///
  /// When [groups] is a strict subset of [kAllBackupEntityGroups], only the
  /// selected slices are replaced; other local data stays intact.
  Future<void> restoreParsed(
    ParsedUserBackup parsed,
    String accountUserId, {
    Set<BackupEntityGroup> groups = kAllBackupEntityGroups,
  }) async {
    if (accountUserId.isEmpty) {
      throw StateError('accountUserId required');
    }
    if (groups.isEmpty) return;

    final store = OfflineLocalStore.instance;
    final fullReplace = groups.containsAll(kAllBackupEntityGroups);

    if (fullReplace) {
      await store.replaceUserOfflineFromBackup(
        userId: accountUserId,
        entities: parsed.entities,
        pendingOperations: parsed.pendingOperations,
        syncMeta: parsed.syncMeta,
      );
    } else {
      final entityTypes = entityTypesForBackupGroups(groups);
      if (entityTypes.isNotEmpty) {
        await store.deleteEntitiesForUserByTypes(accountUserId, entityTypes);
        final entities = filterBackupEntities(parsed.entities, groups);
        for (final raw in entities) {
          await store.upsertEntityForUser(accountUserId, raw);
        }
      }
    }

    if (groups.contains(BackupEntityGroup.preferences)) {
      final profile = parsed.profileJson == null
          ? const LocalUserProfileData()
          : LocalUserProfileData.fromJson(parsed.profileJson!);
      await LocalCoachProfileRepository.instance.saveProfile(accountUserId, profile);
      await UserPreferencesRepository.instance.setNotificationsEnabled(
        parsed.notificationsEnabled,
      );
    }

    if (groups.contains(BackupEntityGroup.reminders)) {
      await ReminderStore.instance.replaceFromMaps(parsed.reminders);
    }

    if (groups.contains(BackupEntityGroup.preferences) ||
        groups.contains(BackupEntityGroup.reminders)) {
      await NotificationSchedulerService.instance
          .syncWithNotificationPreference();
    }
  }

  BackupPreviewCounts previewCounts(ParsedUserBackup parsed) =>
      previewCountsFromBackup(parsed);

  /// Merge backup entities by id, keeping the row with the newest [updatedAt].
  Future<void> mergeRestore(
    ParsedUserBackup parsed,
    String accountUserId, {
    Set<BackupEntityGroup> groups = kAllBackupEntityGroups,
  }) async {
    if (accountUserId.isEmpty) {
      throw StateError('accountUserId required');
    }
    if (groups.isEmpty) return;

    final store = OfflineLocalStore.instance;
    final entities = filterBackupEntities(parsed.entities, groups);
    for (final raw in entities) {
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

    if (groups.contains(BackupEntityGroup.preferences) &&
        parsed.profileJson != null) {
      final profile = LocalUserProfileData.fromJson(parsed.profileJson!);
      await LocalCoachProfileRepository.instance.saveProfile(accountUserId, profile);
    }

    if (groups.contains(BackupEntityGroup.preferences)) {
      await UserPreferencesRepository.instance.setNotificationsEnabled(
        parsed.notificationsEnabled,
      );
    }

    if (groups.contains(BackupEntityGroup.reminders) &&
        parsed.reminders.isNotEmpty) {
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

    if (groups.contains(BackupEntityGroup.preferences) ||
        groups.contains(BackupEntityGroup.reminders)) {
      await NotificationSchedulerService.instance
          .syncWithNotificationPreference();
    }
  }
}
