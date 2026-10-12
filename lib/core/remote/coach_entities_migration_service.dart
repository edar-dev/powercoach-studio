import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../backup/local_data_probe.dart';
import '../constants/workout_plan_template_scope.dart';
import '../platform/web_online_status.dart';
import '../settings/settings_prefs_keys.dart';
import '../storage/offline_local_store.dart';
import '../sync/offline_models.dart';
import '../sync/offline_repository_support.dart';
import 'coach_entities_exceptions.dart';
import 'coach_entities_remote.dart';

/// One-shot upload of local Drift coach data into `coach_entities`.
///
/// Used when an existing coach has local (or restored) data and the remote
/// table is still empty or only partially uploaded. Idempotent on PK; skips
/// entities already present remotely (`type.name::id`, including soft-deleted).
/// Completion and in-progress flags are stored per user in SharedPreferences.
class CoachEntitiesMigrationService {
  CoachEntitiesMigrationService({
    CoachEntitiesRemote? remote,
    OfflineLocalStore? store,
    LocalDataProbe? localProbe,
    OfflineRepositorySupport? support,
    bool Function()? isOnline,
    String? Function()? resolveUserId,
    Future<SharedPreferences> Function()? prefsLoader,
  }) : this._(
          remote: remote ?? CoachEntitiesRemote(),
          store: store ?? OfflineLocalStore.instance,
          localProbe: localProbe ?? LocalDataProbe.instance,
          support: support,
          isOnline: isOnline ?? isNavigatorOnline,
          resolveUserId: resolveUserId,
          prefsLoader: prefsLoader ?? SharedPreferences.getInstance,
        );

  CoachEntitiesMigrationService._({
    required CoachEntitiesRemote remote,
    required OfflineLocalStore store,
    required LocalDataProbe localProbe,
    OfflineRepositorySupport? support,
    required bool Function() isOnline,
    String? Function()? resolveUserId,
    required Future<SharedPreferences> Function() prefsLoader,
  })  : _remote = remote,
        _store = store,
        _localProbe = localProbe,
        _isOnline = isOnline,
        _prefsLoader = prefsLoader,
        _support = support ??
            OfflineRepositorySupport(
              remote: remote,
              store: store,
              isOnline: isOnline,
              resolveUserId: resolveUserId,
            );

  static final CoachEntitiesMigrationService instance =
      CoachEntitiesMigrationService();

  final CoachEntitiesRemote _remote;
  final OfflineLocalStore _store;
  final LocalDataProbe _localProbe;
  final OfflineRepositorySupport _support;
  final bool Function() _isOnline;
  final Future<SharedPreferences> Function() _prefsLoader;

  /// True when local coach data still needs (or must retry) one-shot upload.
  ///
  /// Includes partial-failure retry: migration started, prefs not complete, and
  /// remote may already contain some rows from earlier chunks.
  Future<bool> needsMigration(String userId) async {
    if (userId.isEmpty) return false;
    if (await isMigrationComplete(userId)) return false;
    final hasLocal = await _localProbe.hasAnyNonDeletedEntities(userId);
    if (!hasLocal) return false;
    final remoteEmpty = await _remote.isRemoteEmpty();
    if (remoteEmpty) return true;
    return isMigrationStarted(userId);
  }

  Future<bool> isMigrationComplete(String userId) async {
    if (userId.isEmpty) return false;
    final prefs = await _prefsLoader();
    return prefs.getBool(
          SettingsPrefsKeys.coachEntitiesMigrationCompleteKey(userId),
        ) ==
        true;
  }

  Future<bool> isMigrationStarted(String userId) async {
    if (userId.isEmpty) return false;
    final prefs = await _prefsLoader();
    return prefs.getBool(
          SettingsPrefsKeys.coachEntitiesMigrationStartedKey(userId),
        ) ==
        true;
  }

  /// Uploads local known entities (including soft-deleted) then refreshes cache.
  ///
  /// Skips entities already present remotely (match on `type.name::id`,
  /// including soft-deleted). No-op when prefs already mark complete and
  /// remote is not empty.
  Future<void> runMigration({
    required String userId,
    void Function(int done, int total)? onProgress,
  }) async {
    if (userId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'required');
    }

    final alreadyComplete = await isMigrationComplete(userId);
    final remoteEmpty = await _remote.isRemoteEmpty();
    if (alreadyComplete && !remoteEmpty) {
      onProgress?.call(0, 0);
      return;
    }

    if (!_isOnline()) {
      throw CoachEntitiesOnlineRequiredException(
        CoachEntitiesOnlineRequiredReason.offline,
      );
    }

    final entities = await _loadEntitiesForUpload(userId);
    final total = entities.length;

    if (total == 0) {
      await markMigrationComplete(userId);
      onProgress?.call(0, 0);
      return;
    }

    final remoteRows = await _remote.list(includeDeleted: true);
    final remoteKeys = <String>{
      for (final e in remoteRows) _entityKey(e),
    };

    final toUpload = entities
        .where((e) => !remoteKeys.contains(_entityKey(e)))
        .toList(growable: false);
    final alreadyRemote = total - toUpload.length;
    // First progress after prepare: done > 0 means this run is a resume.
    onProgress?.call(alreadyRemote, total);

    if (toUpload.isEmpty) {
      await markMigrationComplete(userId);
      await _bestEffortPull();
      return;
    }

    // Mark started before the first upsert so a mid-chunk failure cannot let
    // login/resume pull replace Drift with a partial remote snapshot.
    await markMigrationStarted(userId);

    const chunkSize = CoachEntitiesRemote.upsertChunkSize;
    var uploadedThisRun = 0;
    for (var i = 0; i < toUpload.length; i += chunkSize) {
      final end = (i + chunkSize < toUpload.length)
          ? i + chunkSize
          : toUpload.length;
      final chunk = toUpload.sublist(i, end);
      await _remote.upsertAll(chunk);
      uploadedThisRun = end;
      final done = alreadyRemote + uploadedThisRun;
      await _persistProgress(userId, done);
      onProgress?.call(done, total);
    }

    await markMigrationComplete(userId);
    await _bestEffortPull();
  }

  Future<void> _bestEffortPull() async {
    try {
      await _support.pullAndReplaceCache();
    } catch (e, stack) {
      // Upload already succeeded; cache refresh is best-effort coherence.
      debugPrint(
        'CoachEntitiesMigrationService: pull after upload failed: $e\n$stack',
      );
    }
  }

  static String _entityKey(OfflineEntity entity) =>
      '${entity.type.name}::${entity.id}';

  Future<void> _persistProgress(String userId, int done) async {
    if (userId.isEmpty) return;
    final prefs = await _prefsLoader();
    await prefs.setInt(
      SettingsPrefsKeys.coachEntitiesMigrationProgressKey(userId),
      done,
    );
  }

  @visibleForTesting
  Future<void> markMigrationStarted(String userId) async {
    if (userId.isEmpty) return;
    final prefs = await _prefsLoader();
    await prefs.setBool(
      SettingsPrefsKeys.coachEntitiesMigrationStartedKey(userId),
      true,
    );
  }

  @visibleForTesting
  Future<void> markMigrationComplete(String userId) async {
    if (userId.isEmpty) return;
    final prefs = await _prefsLoader();
    await prefs.setBool(
      SettingsPrefsKeys.coachEntitiesMigrationCompleteKey(userId),
      true,
    );
    await prefs.remove(
      SettingsPrefsKeys.coachEntitiesMigrationStartedKey(userId),
    );
    await prefs.remove(
      SettingsPrefsKeys.coachEntitiesMigrationProgressKey(userId),
    );
  }

  @visibleForTesting
  Future<void> clearMigrationComplete(String userId) async {
    if (userId.isEmpty) return;
    final prefs = await _prefsLoader();
    await prefs.remove(
      SettingsPrefsKeys.coachEntitiesMigrationCompleteKey(userId),
    );
    await prefs.remove(
      SettingsPrefsKeys.coachEntitiesMigrationStartedKey(userId),
    );
    await prefs.remove(
      SettingsPrefsKeys.coachEntitiesMigrationProgressKey(userId),
    );
  }

  Future<List<OfflineEntity>> _loadEntitiesForUpload(String userId) async {
    final raw = await _store.listEntitiesJsonForBackup(userId);
    final out = <OfflineEntity>[];
    for (final map in raw) {
      if (isLegacyWorkoutPlanTemplateEntity(map)) continue;
      final body = Map<String, dynamic>.from(map)..remove('userId');
      if (!isKnownOfflineEntityTypeName(body['type']?.toString())) continue;
      try {
        out.add(OfflineEntity.fromJson(body));
      } catch (e) {
        debugPrint(
          'CoachEntitiesMigrationService: skip malformed entity: $e',
        );
      }
    }
    return out;
  }
}
