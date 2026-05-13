import '../storage/offline_local_store.dart';
import 'offline_models.dart';

class OfflineRepositorySupport {
  OfflineRepositorySupport({OfflineLocalStore? store})
      : _store = store ?? OfflineLocalStore.instance;

  final OfflineLocalStore _store;

  Future<void> saveLocalEntity({
    required OfflineEntityType type,
    required String id,
    required String scopeId,
    required Map<String, dynamic> payload,
    bool deleted = false,
    bool localOnly = false,
  }) {
    return _store.upsertEntity(
      OfflineEntity(
        id: id,
        type: type,
        scopeId: scopeId,
        payload: payload,
        updatedAt: DateTime.now(),
        deleted: deleted,
        localOnly: localOnly,
      ),
    );
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

  String newTempId(String prefix) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return 'local_${prefix}_$now';
  }

  Future<void> markDeleted(OfflineEntityType type, String entityId) =>
      _store.markDeleted(type, entityId);
}
