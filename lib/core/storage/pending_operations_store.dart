import 'dart:convert';

import 'package:drift/drift.dart';

import '../sync/offline_models.dart';
import 'app_database.dart';

/// CRUD for the Drift [PendingOperations] outbox table.
///
/// Legacy sync UI is removed; rows remain for backup/restore and future replay.
class PendingOperationsStore {
  PendingOperationsStore({
    required Future<AppDatabase> Function() ensureDb,
    required String Function() currentUserId,
  })  : _ensureDb = ensureDb,
        _currentUserId = currentUserId;

  final Future<AppDatabase> Function() _ensureDb;
  final String Function() _currentUserId;

  Future<List<PendingOperation>> readAll() async {
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

  Future<void> upsert(PendingOperation op) async {
    final db = await _ensureDb();
    await db.into(db.pendingOperations).insertOnConflictUpdate(
          PendingOperationsCompanion.insert(
            opUuid: op.id,
            userId: op.userId.isNotEmpty
                ? op.userId
                : _currentUserId().ifEmptyUse('__legacy__'),
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

  Future<void> remove(String opId) async {
    final db = await _ensureDb();
    await (db.delete(db.pendingOperations)..where((t) => t.opUuid.equals(opId)))
        .go();
  }

  Future<void> replaceTempIds({
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

  Future<void> deleteAllForUser(String userId, {AppDatabase? db}) async {
    if (userId.isEmpty) return;
    final database = db ?? await _ensureDb();
    await (database.delete(database.pendingOperations)
          ..where((t) => t.userId.equals(userId)))
        .go();
  }

  Future<void> deleteAll() async {
    final db = await _ensureDb();
    await db.delete(db.pendingOperations).go();
  }

  Future<List<Map<String, dynamic>>> listJsonForBackup(String userId) async {
    if (userId.isEmpty) return [];
    final db = await _ensureDb();
    final rows = await (db.select(db.pendingOperations)
          ..where((t) => t.userId.equals(userId)))
        .get();
    return rows.map((r) => _rowToPending(r).toJson()).toList();
  }

  Future<void> restoreBatch({
    required String userId,
    required List<Map<String, dynamic>> pendingOperations,
    AppDatabase? db,
  }) async {
    if (userId.isEmpty) return;
    final database = db ?? await _ensureDb();
    for (final raw in pendingOperations) {
      final op = PendingOperation.fromJson(raw);
      await database.into(database.pendingOperations).insert(
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
  }

  Future<void> insertLegacyBatch({
    required AppDatabase db,
    required List<PendingOperation> operations,
    required String defaultUserId,
  }) async {
    if (operations.isEmpty) return;
    await db.batch((b) {
      for (final op in operations) {
        final opUid = op.userId.isNotEmpty ? op.userId : defaultUserId;
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
      payload: (jsonDecode(row.payloadJson) as Map).cast<String, dynamic>(),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      baseUpdatedAt: row.baseUpdatedAt,
      retryCount: row.retryCount,
      status: _statusFromInt(row.status),
      conflictRemotePayload: row.conflictRemoteJson == null
          ? null
          : (jsonDecode(row.conflictRemoteJson!) as Map).cast<String, dynamic>(),
      errorMessage: row.errorMessage,
    );
  }

  int _statusToInt(PendingOperationStatus s) => s.index;

  PendingOperationStatus _statusFromInt(int i) {
    if (i < 0 || i >= PendingOperationStatus.values.length) {
      return PendingOperationStatus.pending;
    }
    return PendingOperationStatus.values[i];
  }
}

extension on String {
  String ifEmptyUse(String fallback) => isEmpty ? fallback : this;
}
