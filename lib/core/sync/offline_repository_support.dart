import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../analytics/product_analytics.dart';
import '../platform/web_online_status.dart';
import '../remote/coach_entities_exceptions.dart';
import '../remote/coach_entities_remote.dart';
import '../storage/offline_local_store.dart';
import 'offline_models.dart';

class OfflineRepositorySupport {
  OfflineRepositorySupport({
    OfflineLocalStore? store,
    CoachEntitiesRemote? remote,
    bool Function()? isOnline,
    String? Function()? resolveUserId,
  })  : _store = store ?? OfflineLocalStore.instance,
        _remote = remote,
        _isOnline = isOnline ?? (remote != null ? isNavigatorOnline : null),
        _resolveUserId = resolveUserId;

  final OfflineLocalStore _store;
  final CoachEntitiesRemote? _remote;
  final bool Function()? _isOnline;
  final String? Function()? _resolveUserId;
  static const _uuid = Uuid();

  /// Whether writes go remote-first (production) or local-only (unit tests).
  bool get usesRemote => _remote != null;

  Future<void> saveLocalEntity({
    required OfflineEntityType type,
    required String id,
    required String scopeId,
    required Map<String, dynamic> payload,
    bool deleted = false,
    bool localOnly = false,
  }) async {
    final entity = OfflineEntity(
      id: id,
      type: type,
      scopeId: scopeId,
      payload: payload,
      updatedAt: DateTime.now().toUtc(),
      deleted: deleted,
      localOnly: localOnly,
    );

    final remote = _remote;
    if (remote != null) {
      _ensureRemoteWriteAllowed();
      await remote.upsert(entity);
    }

    await _store.upsertEntity(entity);
  }

  Future<List<Map<String, dynamic>>> readLocalEntities(
    OfflineEntityType type, {
    String? scopeId,
    int? limit,
  }) async {
    final entities = await _store.readEntities(
      type,
      scopeId: scopeId,
      limit: limit,
    );
    return entities.where((e) => !e.deleted).map((e) => e.payload).toList();
  }

  Future<Map<String, dynamic>?> readLocalEntityById(
    OfflineEntityType type,
    String id,
  ) async {
    final entity = await _store.readEntityById(type, id);
    if (entity == null || entity.deleted) return null;
    return entity.payload;
  }

  Future<void> enqueue({
    required OfflineEntityType entityType,
    required String entityId,
    required String scopeId,
    required OfflineOperationType opType,
    required String path,
    required Map<String, dynamic> payload,
    DateTime? baseUpdatedAt,
  }) async {
    // Local-only mode: keep writes in local entities and skip remote outbox.
  }

  /// Unique local id. Must stay unique under bulk creates in the same ms
  /// (e.g. default exercise catalog import of 200+ rows).
  String newTempId(String prefix) {
    return 'local_${prefix}_${_uuid.v4()}';
  }

  Future<void> markDeleted(OfflineEntityType type, String entityId) async {
    final current = await _store.readEntityById(type, entityId);
    final remote = _remote;
    if (remote != null) {
      _ensureRemoteWriteAllowed();
      if (current != null) {
        await remote.softDelete(
          type: type,
          id: entityId,
          scopeId: current.scopeId,
          payload: current.payload,
        );
      } else {
        // Entity missing locally — still attempt remote soft-delete.
        await remote.softDelete(
          type: type,
          id: entityId,
          scopeId: '',
          payload: const <String, dynamic>{},
        );
      }
    }
    await _store.markDeleted(type, entityId);
  }

  /// Pulls all coach entities for the signed-in user and replaces the Drift
  /// cache per [OfflineEntityType] (including soft-deleted rows).
  Future<void> pullAndReplaceCache({DateTime? since}) async {
    final remote = _remote;
    if (remote == null) return;

    final userId = _requireUserId();
    final pulled = await remote.pullSince(since: since);
    final byType = <OfflineEntityType, List<OfflineEntity>>{
      for (final type in OfflineEntityType.values) type: <OfflineEntity>[],
    };
    for (final entity in pulled) {
      byType[entity.type]?.add(entity);
    }
    for (final type in OfflineEntityType.values) {
      await _store.replaceEntitiesForType(
        userId: userId,
        type: type,
        entities: byType[type] ?? const <OfflineEntity>[],
      );
    }
  }

  void _ensureRemoteWriteAllowed() {
    try {
      _requireUserId();
    } on CoachEntitiesOnlineRequiredException catch (e) {
      ProductAnalytics.offlineSaveBlocked(
        reason: ProductAnalytics.reasonFromError(e),
      );
      rethrow;
    }
    final onlineCheck = _isOnline;
    if (onlineCheck != null && !onlineCheck()) {
      ProductAnalytics.offlineSaveBlocked(reason: 'offline');
      throw CoachEntitiesOnlineRequiredException(
        CoachEntitiesOnlineRequiredReason.offline,
      );
    }
  }

  String _requireUserId() {
    final id = _currentUserId();
    if (id == null || id.isEmpty) {
      throw CoachEntitiesOnlineRequiredException(
        CoachEntitiesOnlineRequiredReason.notAuthenticated,
      );
    }
    return id;
  }

  String? _currentUserId() {
    final injected = _resolveUserId;
    if (injected != null) return injected();
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }
}
