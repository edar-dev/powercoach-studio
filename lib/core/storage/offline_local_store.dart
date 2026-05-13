import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../sync/offline_models.dart';
import 'app_database.dart';

/// Persistent offline cache and outbox backed by SQLite (Drift).
class OfflineLocalStore {
  OfflineLocalStore._();

  static final OfflineLocalStore instance = OfflineLocalStore._();

  static const _legacyEntitiesKey = 'offline_entities_v1';
  static const _legacyPendingKey = 'offline_pending_ops_v1';
  static const _migrationPrefsKey = 'offline_drift_sqlite_migrated_v1';

  AppDatabase? _db;
  bool _migrationChecked = false;

  String _currentUserId() {
    try {
      return Supabase.instance.client.auth.currentUser?.id ?? '';
    } catch (_) {
      return '';
    }
  }

  String _userIdForEntity(OfflineEntity e) {
    final fromPayload = e.payload['userId']?.toString();
    if (fromPayload != null && fromPayload.isNotEmpty) return fromPayload;
    final uid = _currentUserId();
    return uid.isNotEmpty ? uid : '__legacy__';
  }

  Future<AppDatabase> _ensureDb() async {
    _db ??= AppDatabase();
    if (!_migrationChecked) {
      await _migrateFromSharedPreferencesIfNeeded(_db!);
      _migrationChecked = true;
    }
    return _db!;
  }

  Future<void> _migrateFromSharedPreferencesIfNeeded(AppDatabase db) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationPrefsKey) == true) return;

    final uid = _currentUserId().isNotEmpty ? _currentUserId() : '__legacy__';

    final entitiesRaw = prefs.getString(_legacyEntitiesKey);
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

    final pendingRaw = prefs.getString(_legacyPendingKey);
    if (pendingRaw != null && pendingRaw.isNotEmpty) {
      final list = jsonDecode(pendingRaw) as List<dynamic>;
      await db.batch((b) {
        for (final item in list) {
          if (item is! Map) continue;
          final op = PendingOperation.fromJson(item.cast<String, dynamic>());
          final opUid = op.userId.isNotEmpty ? op.userId : uid;
          b.insert(
            db.pendingOperations,
            PendingOperationsCompanion.insert(
              opUuid: op.id,
              userId: opUid,
              entityType: op.entityType.index,
              entityId: op.entityId,
              scopeId: op.scopeId,
              operationType: op.operationType.index,
              path: op.path,
              payloadJson: jsonEncode(op.payload),
              createdAt: op.createdAt,
              updatedAt: op.updatedAt,
              baseUpdatedAt: Value(op.baseUpdatedAt),
              retryCount: Value(op.retryCount),
              status: _statusToInt(op.status),
              conflictRemoteJson: Value(
                op.conflictRemotePayload == null
                    ? null
                    : jsonEncode(op.conflictRemotePayload),
              ),
              errorMessage: Value(op.errorMessage),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    }

    await prefs.setBool(_migrationPrefsKey, true);
    await prefs.remove(_legacyEntitiesKey);
    await prefs.remove(_legacyPendingKey);
  }

  int _statusToInt(PendingOperationStatus s) => s.index;

  PendingOperationStatus _statusFromInt(int i) {
    if (i < 0 || i >= PendingOperationStatus.values.length) {
      return PendingOperationStatus.pending;
    }
    return PendingOperationStatus.values[i];
  }

  Future<List<OfflineEntity>> readEntities(
    OfflineEntityType type, {
    String? scopeId,
    int? limit,
  }) async {
    final db = await _ensureDb();
    final uid = _currentUserId();
    final q = db.select(db.localEntities)
      ..where((t) {
        var w = t.type.equals(type.index);
        if (uid.isNotEmpty) {
          w = w & (t.userId.equals(uid) | t.userId.equals('__legacy__'));
        } else {
          w = w & (t.userId.equals('__legacy__') | t.userId.equals('__noauth__'));
        }
        if (scopeId != null) {
          w = w & t.scopeId.equals(scopeId);
        }
        return w;
      })
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    if (limit != null && limit > 0) {
      q.limit(limit);
    }
    final rows = await q.get();
    return rows.map(_rowToEntity).toList();
  }

  OfflineEntity _rowToEntity(LocalEntity row) {
    return OfflineEntity(
      id: row.id,
      type: OfflineEntityType.values[row.type.clamp(0, OfflineEntityType.values.length - 1)],
      scopeId: row.scopeId,
      payload: (jsonDecode(row.payloadJson) as Map).cast<String, dynamic>(),
      updatedAt: row.updatedAt,
      deleted: row.deleted,
      localOnly: row.localOnly,
    );
  }

  Future<OfflineEntity?> readEntityById(
    OfflineEntityType type,
    String entityId,
  ) async {
    final db = await _ensureDb();
    final uid = _currentUserId();
    final q = db.select(db.localEntities)
      ..where((t) {
        var w = t.type.equals(type.index) & t.id.equals(entityId);
        if (uid.isNotEmpty) {
          w = w & (t.userId.equals(uid) | t.userId.equals('__legacy__'));
        } else {
          w = w & (t.userId.equals('__legacy__') | t.userId.equals('__noauth__'));
        }
        return w;
      })
      ..limit(1);
    final rows = await q.get();
    if (rows.isEmpty) return null;
    return _rowToEntity(rows.first);
  }

  Future<void> upsertEntity(OfflineEntity entity) async {
    final db = await _ensureDb();
    final rowUid = _userIdForEntity(entity);
    await db.into(db.localEntities).insertOnConflictUpdate(
          LocalEntitiesCompanion.insert(
            userId: rowUid,
            type: entity.type.index,
            id: entity.id,
            scopeId: entity.scopeId,
            payloadJson: jsonEncode(entity.payload),
            updatedAt: entity.updatedAt,
            deleted: Value(entity.deleted),
            localOnly: Value(entity.localOnly),
          ),
        );
  }

  Future<void> markDeleted(OfflineEntityType type, String entityId) async {
    final current = await readEntityById(type, entityId);
    if (current == null) return;
    await upsertEntity(
      OfflineEntity(
        id: current.id,
        type: current.type,
        scopeId: current.scopeId,
        payload: current.payload,
        updatedAt: DateTime.now(),
        deleted: true,
        localOnly: current.localOnly,
      ),
    );
  }

  Future<void> replaceTempEntityId({
    required OfflineEntityType type,
    required String tempId,
    required String serverId,
  }) async {
    final db = await _ensureDb();
    final uid = _currentUserId();
    await db.transaction(() async {
      final old = await (db.select(db.localEntities)..where((t) {
            var w = t.type.equals(type.index) & t.id.equals(tempId);
            if (uid.isNotEmpty) {
              w = w & (t.userId.equals(uid) | t.userId.equals('__legacy__'));
            } else {
              w = w &
                  (t.userId.equals('__legacy__') | t.userId.equals('__noauth__'));
            }
            return w;
          }))
          .getSingleOrNull();
      if (old == null) return;
      await (db.delete(db.localEntities)
            ..where(
              (t) =>
                  t.userId.equals(old.userId) &
                  t.type.equals(type.index) &
                  t.id.equals(tempId),
            ))
          .go();
      final payload =
          (jsonDecode(old.payloadJson) as Map).cast<String, dynamic>();
      payload['id'] = serverId;
      await db.into(db.localEntities).insert(
            LocalEntitiesCompanion.insert(
              userId: old.userId,
              type: type.index,
              id: serverId,
              scopeId: old.scopeId,
              payloadJson: jsonEncode(payload),
              updatedAt: DateTime.now(),
              deleted: Value(old.deleted),
              localOnly: const Value(false),
            ),
          );
    });
  }

  PendingOperation _rowToPending(PendingOpRow row) {
    return PendingOperation(
      id: row.opUuid,
      userId: row.userId,
      entityType: OfflineEntityType.values[
          row.entityType.clamp(0, OfflineEntityType.values.length - 1)],
      entityId: row.entityId,
      scopeId: row.scopeId,
      operationType: OfflineOperationType.values[
          row.operationType.clamp(0, OfflineOperationType.values.length - 1)],
      path: row.path,
      payload:
          (jsonDecode(row.payloadJson) as Map).cast<String, dynamic>(),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      baseUpdatedAt: row.baseUpdatedAt,
      retryCount: row.retryCount,
      status: _statusFromInt(row.status),
      conflictRemotePayload: row.conflictRemoteJson == null
          ? null
          : (jsonDecode(row.conflictRemoteJson!) as Map)
              .cast<String, dynamic>(),
      errorMessage: row.errorMessage,
    );
  }

  Future<List<PendingOperation>> readPendingOperations() async {
    final db = await _ensureDb();
    final uid = _currentUserId();
    final rows = await (db.select(db.pendingOperations)..where((t) {
          if (uid.isNotEmpty) {
            return t.userId.equals(uid) | t.userId.equals('__legacy__');
          }
          return t.userId.equals('__legacy__') | t.userId.equals('__noauth__');
        })..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.map(_rowToPending).toList();
  }

  Future<void> upsertPendingOperation(PendingOperation op) async {
    final db = await _ensureDb();
    await db.into(db.pendingOperations).insertOnConflictUpdate(
          PendingOperationsCompanion.insert(
            opUuid: op.id,
            userId: op.userId.isNotEmpty ? op.userId : _currentUserId().ifEmptyUse('__legacy__'),
            entityType: op.entityType.index,
            entityId: op.entityId,
            scopeId: op.scopeId,
            operationType: op.operationType.index,
            path: op.path,
            payloadJson: jsonEncode(op.payload),
            createdAt: op.createdAt,
            updatedAt: op.updatedAt,
            baseUpdatedAt: Value(op.baseUpdatedAt),
            retryCount: Value(op.retryCount),
            status: _statusToInt(op.status),
            conflictRemoteJson: Value(
              op.conflictRemotePayload == null
                  ? null
                  : jsonEncode(op.conflictRemotePayload),
            ),
            errorMessage: Value(op.errorMessage),
          ),
        );
  }

  Future<void> removePendingOperation(String opId) async {
    final db = await _ensureDb();
    await (db.delete(db.pendingOperations)..where((t) => t.opUuid.equals(opId)))
        .go();
  }

  Future<void> replaceTempIdsInPendingOps({
    required OfflineEntityType type,
    required String tempId,
    required String serverId,
  }) async {
    final db = await _ensureDb();
    final uid = _currentUserId();
    final ops = await (db.select(db.pendingOperations)..where((t) {
          var w = t.entityType.equals(type.index);
          if (uid.isNotEmpty) {
            w = w & (t.userId.equals(uid) | t.userId.equals('__legacy__'));
          } else {
            w = w & (t.userId.equals('__legacy__') | t.userId.equals('__noauth__'));
          }
          return w;
        }))
        .get();
    for (final row in ops) {
      if (row.entityId != tempId && !row.path.contains(tempId)) continue;
      final nextPath = row.path.replaceAll(tempId, serverId);
      var payload =
          (jsonDecode(row.payloadJson) as Map).cast<String, dynamic>();
      if (payload['id']?.toString() == tempId) {
        payload = Map<String, dynamic>.from(payload)..['id'] = serverId;
      }
      await (db.delete(db.pendingOperations)
            ..where((t) => t.opUuid.equals(row.opUuid)))
          .go();
      await db.into(db.pendingOperations).insert(
            PendingOperationsCompanion.insert(
              opUuid: row.opUuid,
              userId: row.userId,
              entityType: row.entityType,
              entityId: serverId,
              scopeId: row.scopeId,
              operationType: row.operationType,
              path: nextPath,
              payloadJson: jsonEncode(payload),
              createdAt: row.createdAt,
              updatedAt: DateTime.now(),
              baseUpdatedAt: Value(row.baseUpdatedAt),
              retryCount: Value(row.retryCount),
              status: row.status,
              conflictRemoteJson: Value(row.conflictRemoteJson),
              errorMessage: Value(row.errorMessage),
            ),
          );
    }
  }

  /// Remove all local offline data (all users). Prefer [wipeForUser] on logout.
  Future<void> clear() async {
    final db = await _ensureDb();
    await db.delete(db.localEntities).go();
    await db.delete(db.pendingOperations).go();
    await db.delete(db.syncMetaEntries).go();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_migrationPrefsKey);
  }

  Future<void> _deleteUserOfflineData(AppDatabase db, String userId) async {
    if (userId.isEmpty) return;
    await (db.delete(db.localEntities)..where((t) => t.userId.equals(userId)))
        .go();
    await (db.delete(db.pendingOperations)
          ..where((t) => t.userId.equals(userId)))
        .go();
    await (db.delete(db.syncMetaEntries)
          ..where((t) => t.userId.equals(userId)))
        .go();
  }

  Future<void> wipeForUser(String userId) async {
    final db = await _ensureDb();
    await _deleteUserOfflineData(db, userId);
  }

  /// Backup-ready maps: `userId` plus fields aligned with [OfflineEntity.toJson].
  Future<List<Map<String, dynamic>>> listEntitiesJsonForBackup(
    String userId,
  ) async {
    if (userId.isEmpty) return [];
    final db = await _ensureDb();
    final rows = await (db.select(db.localEntities)
          ..where((t) => t.userId.equals(userId)))
        .get();
    return rows
        .map((r) => <String, dynamic>{..._rowToEntity(r).toJson(), 'userId': r.userId})
        .toList();
  }

  Future<List<Map<String, dynamic>>> listPendingJsonForBackup(
    String userId,
  ) async {
    if (userId.isEmpty) return [];
    final db = await _ensureDb();
    final rows = await (db.select(db.pendingOperations)
          ..where((t) => t.userId.equals(userId)))
        .get();
    return rows.map((r) => _rowToPending(r).toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> listSyncMetaJsonForBackup(
    String userId,
  ) async {
    if (userId.isEmpty) return [];
    final db = await _ensureDb();
    final rows = await (db.select(db.syncMetaEntries)
          ..where((t) => t.userId.equals(userId)))
        .get();
    return rows
        .map(
          (r) => <String, dynamic>{
            'metaKey': r.metaKey,
            'metaValue': r.metaValue,
          },
        )
        .toList();
  }

  /// Replaces all Drift offline rows for [userId] (entities, pending ops, sync meta).
  Future<void> replaceUserOfflineFromBackup({
    required String userId,
    required List<Map<String, dynamic>> entities,
    required List<Map<String, dynamic>> pendingOperations,
    required List<Map<String, dynamic>> syncMeta,
  }) async {
    if (userId.isEmpty) return;
    final db = await _ensureDb();
    await db.transaction(() async {
      await _deleteUserOfflineData(db, userId);
      for (final raw in entities) {
        final body = Map<String, dynamic>.from(raw)..remove('userId');
        final e = OfflineEntity.fromJson(body);
        await db.into(db.localEntities).insert(
              LocalEntitiesCompanion.insert(
                userId: userId,
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
      for (final raw in pendingOperations) {
        final op = PendingOperation.fromJson(raw);
        await db.into(db.pendingOperations).insert(
              PendingOperationsCompanion.insert(
                opUuid: op.id,
                userId: userId,
                entityType: op.entityType.index,
                entityId: op.entityId,
                scopeId: op.scopeId,
                operationType: op.operationType.index,
                path: op.path,
                payloadJson: jsonEncode(op.payload),
                createdAt: op.createdAt,
                updatedAt: op.updatedAt,
                baseUpdatedAt: Value(op.baseUpdatedAt),
                retryCount: Value(op.retryCount),
                status: _statusToInt(op.status),
                conflictRemoteJson: Value(
                  op.conflictRemotePayload == null
                      ? null
                      : jsonEncode(op.conflictRemotePayload),
                ),
                errorMessage: Value(op.errorMessage),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final raw in syncMeta) {
        final key = raw['metaKey']?.toString() ?? '';
        if (key.isEmpty) continue;
        final value = raw['metaValue']?.toString() ?? '';
        await db.into(db.syncMetaEntries).insertOnConflictUpdate(
              SyncMetaEntriesCompanion.insert(
                userId: userId,
                metaKey: key,
                metaValue: value,
              ),
            );
      }
    });
  }

  Future<void> setSyncMeta(String key, String value) async {
    final uid = _currentUserId();
    if (uid.isEmpty) return;
    final db = await _ensureDb();
    await db.into(db.syncMetaEntries).insertOnConflictUpdate(
          SyncMetaEntriesCompanion.insert(
            userId: uid,
            metaKey: key,
            metaValue: value,
          ),
        );
  }

  Future<String?> getSyncMeta(String key) async {
    final uid = _currentUserId();
    if (uid.isEmpty) return null;
    final db = await _ensureDb();
    final row = await (db.select(db.syncMetaEntries)
          ..where((t) => t.userId.equals(uid) & t.metaKey.equals(key))
          ..limit(1))
        .getSingleOrNull();
    return row?.metaValue;
  }
}

extension on String {
  String ifEmptyUse(String fallback) => isEmpty ? fallback : this;
}
