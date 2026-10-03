import 'dart:convert';

import '../constants/app_info.dart';
import '../constants/workout_plan_template_scope.dart';
import '../notifications/notification_scheduler_service.dart';
import '../../features/settings/data/user_preferences_repository.dart';
import '../../features/auth/data/local_coach_profile_repository.dart';
import '../platform/web_online_status.dart';
import '../remote/coach_entities_exceptions.dart';
import '../remote/coach_entities_remote.dart';
import '../storage/offline_local_store.dart';
import '../sync/offline_models.dart';
import '../sync/offline_repository_support.dart';
import 'user_data_backup_codec.dart';
import 'material_write_notifier.dart';

/// Builds and restores full offline user snapshots (JSON envelope v1).
///
/// When [remote] is non-null (production default), restore writes entities to
/// Supabase first and refreshes the Drift cache. When [remote] is null
/// (unit tests), restore stays Drift-only.
class UserDataBackupService {
  UserDataBackupService({
    OfflineLocalStore? store,
    CoachEntitiesRemote? remote,
    OfflineRepositorySupport? support,
    bool Function()? isOnline,
    String? Function()? resolveUserId,
  })  : _store = store ?? OfflineLocalStore.instance,
        _remote = remote,
        _isOnline = isOnline ?? (remote != null ? isNavigatorOnline : null),
        _support = support ??
            (remote != null
                ? OfflineRepositorySupport(
                    remote: remote,
                    store: store,
                    isOnline: isOnline ?? isNavigatorOnline,
                    resolveUserId: resolveUserId,
                  )
                : null);

  /// Production singleton: restore targets cloud SoT + Drift cache.
  static final UserDataBackupService instance = UserDataBackupService(
    remote: CoachEntitiesRemote(),
  );

  final OfflineLocalStore _store;
  final CoachEntitiesRemote? _remote;
  final OfflineRepositorySupport? _support;
  final bool Function()? _isOnline;

  Future<Map<String, dynamic>> buildExportMap(String accountUserId) async {
    if (accountUserId.isEmpty) {
      throw StateError('accountUserId required');
    }
    final preferences =
        await UserPreferencesRepository.instance.exportForBackup();
    final profile =
        await LocalCoachProfileRepository.instance.getProfile(accountUserId);

    final entities = (await _store.listEntitiesJsonForBackup(accountUserId))
        // Data policy: omit retired template-scoped workout plans from export.
        .where((e) => !isLegacyWorkoutPlanTemplateEntity(e))
        .toList();
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
  /// With a remote client: upserts entities to Supabase then pulls into Drift.
  /// Without remote: writes Drift only (tests / break-glass).
  ///
  /// Always restores all entity types. Legacy `pendingOperations` / `syncMeta` /
  /// `reminders` / `exerciseRecord` rows in the envelope are ignored.
  Future<void> restoreParsed(
    ParsedUserBackup parsed,
    String accountUserId,
  ) async {
    await MaterialWriteNotifier.runSuppressed(
      () => _restoreParsedUnsuppressed(parsed, accountUserId),
    );
  }

  Future<void> _restoreParsedUnsuppressed(
    ParsedUserBackup parsed,
    String accountUserId,
  ) async {
    if (accountUserId.isEmpty) {
      throw StateError('accountUserId required');
    }

    // Data policy: skip template-scoped workout plans on import/restore.
    final entities = parsed.entities
        .where((e) => !isLegacyWorkoutPlanTemplateEntity(e))
        .toList();

    final remote = _remote;
    final support = _support;
    if (remote != null && support != null) {
      _ensureRemoteRestoreAllowed();
      final offlineEntities = _entitiesFromBackupMaps(entities);
      await remote.upsertAll(offlineEntities);
      await support.pullAndReplaceCache();
    } else {
      await _store.replaceUserOfflineFromBackup(
        userId: accountUserId,
        entities: entities,
      );
    }

    await _applyReplaceProfileAndPreferences(parsed, accountUserId);
  }

  /// Merge backup entities by id, keeping the row with the newest [updatedAt].
  ///
  /// With a remote client: merges in memory, upserts the full resulting set,
  /// then pulls the Drift cache. Without remote: Drift-only merge.
  Future<void> mergeRestore(
    ParsedUserBackup parsed,
    String accountUserId,
  ) async {
    await MaterialWriteNotifier.runSuppressed(
      () => _mergeRestoreUnsuppressed(parsed, accountUserId),
    );
  }

  Future<void> _mergeRestoreUnsuppressed(
    ParsedUserBackup parsed,
    String accountUserId,
  ) async {
    if (accountUserId.isEmpty) {
      throw StateError('accountUserId required');
    }

    final remote = _remote;
    final support = _support;
    if (remote != null && support != null) {
      _ensureRemoteRestoreAllowed();
      final merged = await _computeMergedEntities(parsed, accountUserId);
      await remote.upsertAll(merged);
      await support.pullAndReplaceCache();
    } else {
      for (final raw in parsed.entities) {
        // Data policy: skip template-scoped workout plans on merge restore.
        if (isLegacyWorkoutPlanTemplateEntity(raw)) continue;
        final body = Map<String, dynamic>.from(raw)..remove('userId');
        if (!body.containsKey('type') || !body.containsKey('payload')) {
          continue;
        }
        if (!isKnownOfflineEntityTypeName(body['type']?.toString())) {
          continue;
        }
        final incoming = OfflineEntity.fromJson(body);
        final existing = await _store.readEntityById(incoming.type, incoming.id);
        if (existing == null ||
            !existing.updatedAt.isAfter(incoming.updatedAt)) {
          await _store.upsertEntity(incoming);
        }
      }
    }

    await _applyMergeProfileAndPreferences(parsed, accountUserId);
  }

  BackupPreviewCounts previewCounts(ParsedUserBackup parsed) =>
      previewCountsFromBackup(parsed);

  Future<List<OfflineEntity>> _computeMergedEntities(
    ParsedUserBackup parsed,
    String accountUserId,
  ) async {
    final byKey = <String, OfflineEntity>{};
    final localRaw = await _store.listEntitiesJsonForBackup(accountUserId);
    for (final entity in _entitiesFromBackupMaps(localRaw)) {
      byKey[_entityKey(entity)] = entity;
    }
    for (final entity in _entitiesFromBackupMaps(parsed.entities)) {
      final key = _entityKey(entity);
      final existing = byKey[key];
      if (existing == null || !existing.updatedAt.isAfter(entity.updatedAt)) {
        byKey[key] = entity;
      }
    }
    return byKey.values.toList(growable: false);
  }

  List<OfflineEntity> _entitiesFromBackupMaps(
    List<Map<String, dynamic>> maps,
  ) {
    final out = <OfflineEntity>[];
    for (final raw in maps) {
      if (isLegacyWorkoutPlanTemplateEntity(raw)) continue;
      final body = Map<String, dynamic>.from(raw)..remove('userId');
      if (!body.containsKey('type') || !body.containsKey('payload')) {
        continue;
      }
      if (!isKnownOfflineEntityTypeName(body['type']?.toString())) {
        continue;
      }
      out.add(OfflineEntity.fromJson(body));
    }
    return out;
  }

  String _entityKey(OfflineEntity entity) => '${entity.type.name}::${entity.id}';

  Future<void> _applyReplaceProfileAndPreferences(
    ParsedUserBackup parsed,
    String accountUserId,
  ) async {
    final profile = parsed.profileJson == null
        ? const LocalUserProfileData()
        : LocalUserProfileData.fromJson(parsed.profileJson!);
    await LocalCoachProfileRepository.instance.saveProfile(
      accountUserId,
      profile,
    );
    await _applyPreferences(parsed);
  }

  Future<void> _applyMergeProfileAndPreferences(
    ParsedUserBackup parsed,
    String accountUserId,
  ) async {
    if (parsed.profileJson != null) {
      final profile = LocalUserProfileData.fromJson(parsed.profileJson!);
      await LocalCoachProfileRepository.instance.saveProfile(
        accountUserId,
        profile,
      );
    }
    await _applyPreferences(parsed);
  }

  Future<void> _applyPreferences(ParsedUserBackup parsed) async {
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

  void _ensureRemoteRestoreAllowed() {
    final onlineCheck = _isOnline;
    if (onlineCheck != null && !onlineCheck()) {
      throw CoachEntitiesOnlineRequiredException(
        CoachEntitiesOnlineRequiredReason.offline,
      );
    }
  }
}
