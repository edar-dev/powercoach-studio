import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../sync/offline_models.dart';
import 'app_database.dart';
import 'offline_migration.dart';
import 'pending_operations_store.dart';

/// Persistent offline cache and outbox backed by SQLite (Drift).
class OfflineLocalStore {
  OfflineLocalStore._() {
    _pendingOps = PendingOperationsStore(
      ensureDb: _ensureDb,
      currentUserId: _currentUserId,
    );
    _migration = OfflineMigration(pendingOps: _pendingOps);
  }

  static final OfflineLocalStore instance = OfflineLocalStore._();

  AppDatabase? _db;
  bool _migrationChecked = false;
  late final PendingOperationsStore _pendingOps;
  late final OfflineMigration _migration;

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
      await _migration.migrateFromSharedPreferencesIfNeeded(
        db: _db!,
        defaultUserId:
            _currentUserId().isNotEmpty ? _currentUserId() : '__legacy__',
      );
      _migrationChecked = true;
    }
    return _db!;
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

  /// Inserts or updates an entity row for an explicit [userId] (backup restore).
  Future<void> upsertEntityForUser(
    String userId,
    Map<String, dynamic> rawEntity,
  ) async {
    if (userId.isEmpty) return;
    final body = Map<String, dynamic>.from(rawEntity)..remove('userId');
    final entity = OfflineEntity.fromJson(body);
    final db = await _ensureDb();
    await db.into(db.localEntities).insertOnConflictUpdate(
          LocalEntitiesCompanion.insert(
            userId: userId,
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

  /// Deletes offline entity rows for [userId] limited to [types].
  Future<void> deleteEntitiesForUserByTypes(
    String userId,
    Set<OfflineEntityType> types,
  ) async {
    if (userId.isEmpty || types.isEmpty) return;
    final db = await _ensureDb();
    final indices = types.map((t) => t.index).toList();
    await (db.delete(db.localEntities)..where(
          (t) => t.userId.equals(userId) & t.type.isIn(indices),
        ))
        .go();
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

  Future<List<PendingOperation>> readPendingOperations() =>
      _pendingOps.readAll();

  Future<void> upsertPendingOperation(PendingOperation op) =>
      _pendingOps.upsert(op);

  Future<void> removePendingOperation(String opId) => _pendingOps.remove(opId);

  Future<void> replaceTempIdsInPendingOps({
    required OfflineEntityType type,
    required String tempId,
    required String serverId,
  }) =>
      _pendingOps.replaceTempIds(
        type: type,
        tempId: tempId,
        serverId: serverId,
      );

  /// Remove all local offline data (all users). Prefer [wipeForUser] on logout.
  Future<void> clear() async {
    final db = await _ensureDb();
    await db.delete(db.localEntities).go();
    await _pendingOps.deleteAll();
    await db.delete(db.syncMetaEntries).go();
    await _migration.clearMigrationFlag();
  }

  Future<void> _deleteUserOfflineData(AppDatabase db, String userId) async {
    if (userId.isEmpty) return;
    await (db.delete(db.localEntities)..where((t) => t.userId.equals(userId)))
        .go();
    await _pendingOps.deleteAllForUser(userId, db: db);
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
  ) =>
      _pendingOps.listJsonForBackup(userId);

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
      await _pendingOps.restoreBatch(
        userId: userId,
        pendingOperations: pendingOperations,
        db: db,
      );
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
