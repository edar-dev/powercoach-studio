import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sync/offline_models.dart';
import 'app_database.dart';

/// One-shot migration from legacy SharedPreferences offline cache to Drift SQLite.
class OfflineMigration {
  static const legacyEntitiesKey = 'offline_entities_v1';
  static const legacyPendingKey = 'offline_pending_ops_v1';
  static const migrationPrefsKey = 'offline_drift_sqlite_migrated_v1';

  Future<void> migrateFromSharedPreferencesIfNeeded({
    required AppDatabase db,
    required String defaultUserId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(migrationPrefsKey) == true) return;

    final uid =
        defaultUserId.isNotEmpty ? defaultUserId : '__legacy__';

    final entitiesRaw = prefs.getString(legacyEntitiesKey);
    if (entitiesRaw != null && entitiesRaw.isNotEmpty) {
      final list = jsonDecode(entitiesRaw) as List<dynamic>;
      await db.batch((b) {
        for (final item in list) {
          if (item is! Map) continue;
          final e = OfflineEntity.fromJson(item.cast<String, dynamic>());
          final rowUid = e.payload['userId']?.toString();
          final effectiveUid =
              (rowUid != null && rowUid.isNotEmpty) ? rowUid : uid;
          b.insert(
            db.localEntities,
            LocalEntitiesCompanion.insert(
              userId: effectiveUid,
              type: e.type.index,
              id: e.id,
              scopeId: e.scopeId,
              payloadJson: jsonEncode(e.payload),
              updatedAt: e.updatedAt,
              deleted: Value(e.deleted),
              localOnly: Value(e.localOnly),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    }

    // Legacy pending-ops outbox is no longer persisted (local-first, no remote
    // replay); drop the stale SharedPreferences key without importing rows.

    await prefs.setBool(migrationPrefsKey, true);
    await prefs.remove(legacyEntitiesKey);
    await prefs.remove(legacyPendingKey);
  }

  Future<void> clearMigrationFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(migrationPrefsKey);
  }
}
