import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../sync/offline_models.dart';

class OfflineLocalStore {
  OfflineLocalStore._();

  static final OfflineLocalStore instance = OfflineLocalStore._();

  static const _entitiesKey = 'offline_entities_v1';
  static const _pendingOpsKey = 'offline_pending_ops_v1';

  Future<List<OfflineEntity>> readEntities(OfflineEntityType type, {String? scopeId}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_entitiesKey);
    if (raw == null || raw.isEmpty) return <OfflineEntity>[];
    final list = (jsonDecode(raw) as List)
        .whereType<Map>()
        .map((e) => OfflineEntity.fromJson(e.cast<String, dynamic>()))
        .where((e) => e.type == type && (scopeId == null || e.scopeId == scopeId))
        .toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<OfflineEntity?> readEntityById(
    OfflineEntityType type,
    String entityId,
  ) async {
    final all = await _readAllEntities();
    try {
      return all.firstWhere((e) => e.type == type && e.id == entityId);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsertEntity(OfflineEntity entity) async {
    final all = await _readAllEntities();
    final next = all.where((e) => !(e.type == entity.type && e.id == entity.id)).toList()
      ..add(entity);
    await _writeAllEntities(next);
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
    final all = await _readAllEntities();
    final updated = all.map((e) {
      if (e.type == type && e.id == tempId) {
        return OfflineEntity(
          id: serverId,
          type: e.type,
          scopeId: e.scopeId,
          payload: <String, dynamic>{...e.payload, 'id': serverId},
          updatedAt: DateTime.now(),
          deleted: e.deleted,
          localOnly: false,
        );
      }
      return e;
    }).toList();
    await _writeAllEntities(updated);
  }

  Future<List<PendingOperation>> readPendingOperations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingOpsKey);
    if (raw == null || raw.isEmpty) return <PendingOperation>[];
    final list = (jsonDecode(raw) as List)
        .whereType<Map>()
        .map((e) => PendingOperation.fromJson(e.cast<String, dynamic>()))
        .toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  Future<void> upsertPendingOperation(PendingOperation op) async {
    final all = await readPendingOperations();
    final next = all.where((e) => e.id != op.id).toList()..add(op);
    await _writePendingOperations(next);
  }

  Future<void> removePendingOperation(String opId) async {
    final all = await readPendingOperations();
    final next = all.where((e) => e.id != opId).toList();
    await _writePendingOperations(next);
  }

  Future<void> replaceTempIdsInPendingOps({
    required OfflineEntityType type,
    required String tempId,
    required String serverId,
  }) async {
    final all = await readPendingOperations();
    final next = all.map((op) {
      if (op.entityType != type) return op;
      if (op.entityId != tempId && !op.path.contains(tempId)) return op;
      final nextPath = op.path.replaceAll(tempId, serverId);
      final payload = <String, dynamic>{...op.payload};
      if (payload['id']?.toString() == tempId) {
        payload['id'] = serverId;
      }
      return PendingOperation(
        id: op.id,
        entityType: op.entityType,
        entityId: serverId,
        scopeId: op.scopeId,
        operationType: op.operationType,
        path: nextPath,
        payload: payload,
        createdAt: op.createdAt,
        updatedAt: DateTime.now(),
        baseUpdatedAt: op.baseUpdatedAt,
        retryCount: op.retryCount,
        status: op.status,
        conflictRemotePayload: op.conflictRemotePayload,
        errorMessage: op.errorMessage,
      );
    }).toList();
    await _writePendingOperations(next);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_entitiesKey);
    await prefs.remove(_pendingOpsKey);
  }

  Future<List<OfflineEntity>> _readAllEntities() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_entitiesKey);
    if (raw == null || raw.isEmpty) return <OfflineEntity>[];
    return (jsonDecode(raw) as List)
        .whereType<Map>()
        .map((e) => OfflineEntity.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<void> _writeAllEntities(List<OfflineEntity> entities) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entities.map((e) => e.toJson()).toList());
    await prefs.setString(_entitiesKey, encoded);
  }

  Future<void> _writePendingOperations(List<PendingOperation> ops) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(ops.map((e) => e.toJson()).toList());
    await prefs.setString(_pendingOpsKey, encoded);
  }
}
