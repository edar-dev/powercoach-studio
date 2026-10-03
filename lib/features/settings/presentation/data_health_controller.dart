import 'dart:convert';

import '../../../core/data_quality/data_quality.dart';
import '../../../core/settings/settings_prefs_keys.dart';
import '../../../core/storage/offline_local_store.dart';
import '../../../core/sync/offline_models.dart';
import '../../exercise_library/data/pinned_exercises_store.dart';
import '../../exercise_library/data/recent_exercises_store.dart';

/// Loads live local data, runs [DataQualityScanner], and applies the only
/// safe in-app repair: clear orphan pin/recent exercise ids.
class DataHealthController {
  DataHealthController({
    OfflineLocalStore? localStore,
    PinnedExercisesStore? pinnedStore,
    RecentExercisesStore? recentStore,
    DataQualityScanner scanner = const DataQualityScanner(),
  })  : _localStore = localStore ?? OfflineLocalStore.instance,
        _pinnedStore = pinnedStore ?? PinnedExercisesStore.instance,
        _recentStore = recentStore ?? RecentExercisesStore.instance,
        _scanner = scanner;

  final OfflineLocalStore _localStore;
  final PinnedExercisesStore _pinnedStore;
  final RecentExercisesStore _recentStore;
  final DataQualityScanner _scanner;

  Future<DataQualityReport> scan(String userId) async {
    final rawEntities = await _localStore.listEntitiesJsonForBackup(userId);
    final entities = <OfflineEntity>[];
    for (final raw in rawEntities) {
      final entity = _tryParseEntity(raw);
      if (entity != null) entities.add(entity);
    }
    final preferences = await _loadPinRecentPreferences();
    return _scanner.scanEntities(entities, preferences: preferences);
  }

  /// Returns count of unique orphan ids removed from pin+recent stores.
  Future<int> clearPreferencesOrphans(DataQualityReport report) async {
    final ids = preferenceOrphanTargetIds(report);
    if (ids.isEmpty) return 0;
    await _pinnedStore.removeIds(ids);
    await _recentStore.removeIds(ids);
    return ids.length;
  }

  /// Unique orphan customExercise ids referenced from preferences findings.
  static Set<String> preferenceOrphanTargetIds(DataQualityReport report) {
    final ids = <String>{};
    for (final finding in report.findings) {
      if (finding.ruleId != DataQualityRuleIds.orphanReference) continue;
      final details = finding.details;
      if (details == null) continue;
      if (details['source'] != 'preferences') continue;
      final targetId = details['targetId']?.toString();
      if (targetId == null || targetId.isEmpty) continue;
      ids.add(targetId);
    }
    return ids;
  }

  static bool hasPreferenceOrphans(DataQualityReport report) =>
      preferenceOrphanTargetIds(report).isNotEmpty;

  Future<Map<String, dynamic>> _loadPinRecentPreferences() async {
    final map = <String, dynamic>{};
    final pinned = await _pinnedStore.getPinnedIds();
    if (pinned.isNotEmpty) {
      map[SettingsPrefsKeys.pinnedExerciseIdsJson] =
          jsonEncode(pinned.toList());
    }
    final recent = await _recentStore.getRecentIds();
    if (recent.isNotEmpty) {
      map[SettingsPrefsKeys.recentExerciseIdsJson] = jsonEncode(recent);
    }
    return map;
  }

  static OfflineEntity? _tryParseEntity(Map<String, dynamic> raw) {
    final body = Map<String, dynamic>.from(raw)..remove('userId');
    if (!isKnownOfflineEntityTypeName(body['type']?.toString())) {
      return null;
    }
    try {
      return OfflineEntity.fromJson(body);
    } catch (_) {
      return null;
    }
  }
}
