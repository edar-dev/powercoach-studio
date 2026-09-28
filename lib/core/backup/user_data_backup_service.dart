import 'dart:convert';

import '../constants/app_info.dart';
import '../notifications/notification_scheduler_service.dart';
import '../../features/settings/data/user_preferences_repository.dart';
import '../../features/auth/data/local_coach_profile_repository.dart';
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
    final preferences =
        await UserPreferencesRepository.instance.exportForBackup();
    final profile =
        await LocalCoachProfileRepository.instance.getProfile(accountUserId);
    final store = OfflineLocalStore.instance;

    final entities = await store.listEntitiesJsonForBackup(accountUserId);
    // Manual ReminderStore reminders are no longer exported; keep empty list
    // for envelope backward compatibility. Calendar prefs live under preferences.
    const reminders = <Map<String, dynamic>>[];
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
      'preferences': preferences,
      'localUserProfile': profile.toJson(),
      'entities': entities,
      'reminders': reminders,
    };
  }

  Future<String> buildExportJsonPretty(String accountUserId) async {
    final map = await buildExportMap(accountUserId);
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  /// Replace-local snapshot for [accountUserId] with parsed backup (destructive).
  ///
  /// Always restores all entity types. Legacy `pendingOperations` / `syncMeta` /
  /// `reminders` / `exerciseRecord` rows in the envelope are ignored.
  Future<void> restoreParsed(
    ParsedUserBackup parsed,
    String accountUserId,
  ) async {
    if (accountUserId.isEmpty) {
      throw StateError('accountUserId required');
    }

    final store = OfflineLocalStore.instance;
    await store.replaceUserOfflineFromBackup(
      userId: accountUserId,
      entities: parsed.entities,
    );

    final profile = parsed.profileJson == null
        ? const LocalUserProfileData()
        : LocalUserProfileData.fromJson(parsed.profileJson!);
    await LocalCoachProfileRepository.instance.saveProfile(accountUserId, profile);
    await UserPreferencesRepository.instance
        .applyFromBackupMap(parsed.preferences.raw);
    if (parsed.preferences.raw.isEmpty) {
      await UserPreferencesRepository.instance.setNotificationsEnabled(
        parsed.notificationsEnabled,
      );
    }
    await NotificationSchedulerService.instance
        .syncWithNotificationPreference();
  }

  BackupPreviewCounts previewCounts(ParsedUserBackup parsed) =>
      previewCountsFromBackup(parsed);

  /// Merge backup entities by id, keeping the row with the newest [updatedAt].
  ///
  /// Always merges all known entity types (legacy `exerciseRecord` skipped).
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
      if (!isKnownOfflineEntityTypeName(body['type']?.toString())) {
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
      await LocalCoachProfileRepository.instance.saveProfile(accountUserId, profile);
    }

    await UserPreferencesRepository.instance
        .applyFromBackupMap(parsed.preferences.raw);
    if (parsed.preferences.raw.isEmpty) {
      await UserPreferencesRepository.instance.setNotificationsEnabled(
        parsed.notificationsEnabled,
      );
    }
    await NotificationSchedulerService.instance
        .syncWithNotificationPreference();
  }
}
