import '../storage/offline_local_store.dart';
import 'offline_models.dart';

typedef PendingOpUpserter = Future<void> Function(PendingOperation op);
typedef PendingOpRemover = Future<void> Function(String opId);
typedef EntityUpserter = Future<void> Function(OfflineEntity entity);
typedef EntityDeleter =
    Future<void> Function(OfflineEntityType type, String entityId);

/// Applies keep-local / accept-remote / retry / discard for pending sync ops.
///
/// Updates local outbox and entity cache only. Remote replay requires
/// [SyncOrchestrator] when online sync is re-enabled.
class PendingOperationResolver {
  PendingOperationResolver({
    OfflineLocalStore? store,
    PendingOpUpserter? upsertPending,
    PendingOpRemover? removePending,
    EntityUpserter? upsertEntity,
    EntityDeleter? markDeleted,
  }) : _upsertPending =
           upsertPending ??
           ((op) => (store ?? OfflineLocalStore.instance).upsertPendingOperation(op)),
       _removePending =
           removePending ??
           ((opId) =>
               (store ?? OfflineLocalStore.instance).removePendingOperation(opId)),
       _upsertEntity =
           upsertEntity ??
           ((entity) => (store ?? OfflineLocalStore.instance).upsertEntity(entity)),
       _markDeleted =
           markDeleted ??
           ((type, entityId) =>
               (store ?? OfflineLocalStore.instance).markDeleted(type, entityId));

  final PendingOpUpserter _upsertPending;
  final PendingOpRemover _removePending;
  final EntityUpserter _upsertEntity;
  final EntityDeleter _markDeleted;

  Future<void> keepLocal(PendingOperation op) async {
    final updated = op.copyWith(
      status: PendingOperationStatus.pending,
      updatedAt: DateTime.now(),
      clearConflictRemote: true,
      clearError: true,
    );
    await _upsertPending(updated);
  }

  Future<void> acceptRemote(PendingOperation op) async {
    final remote = op.conflictRemotePayload;
    if (remote == null || remote.isEmpty) {
      throw StateError('Missing remote payload for operation ${op.id}');
    }

    if (op.operationType == OfflineOperationType.delete) {
      await _markDeleted(op.entityType, op.entityId);
      await _removePending(op.id);
      return;
    }

    final payload = _extractRemoteEntityPayload(remote);
    final entityId = payload['id']?.toString() ?? op.entityId;
    await _upsertEntity(
      OfflineEntity(
        id: entityId,
        type: op.entityType,
        scopeId: op.scopeId,
        payload: payload,
        updatedAt: DateTime.now(),
        deleted: false,
        localOnly: false,
      ),
    );
    await _removePending(op.id);
  }

  Future<void> retry(PendingOperation op) async {
    final updated = op.copyWith(
      status: PendingOperationStatus.pending,
      updatedAt: DateTime.now(),
      retryCount: op.retryCount + 1,
      clearError: true,
      clearConflictRemote: op.status != PendingOperationStatus.conflict,
    );
    await _upsertPending(updated);
  }

  Future<void> retryAllFailed(List<PendingOperation> operations) async {
    for (final op in operations) {
      if (op.status == PendingOperationStatus.failed) {
        await retry(op);
      }
    }
  }

  Future<void> discard(PendingOperation op) async {
    await _removePending(op.id);
  }

  Map<String, dynamic> _extractRemoteEntityPayload(
    Map<String, dynamic> remote,
  ) {
    final nestedPayload = remote['payload'];
    if (nestedPayload is Map) {
      return nestedPayload.cast<String, dynamic>();
    }
    final nestedEntity = remote['entity'];
    if (nestedEntity is Map) {
      return nestedEntity.cast<String, dynamic>();
    }
    return Map<String, dynamic>.from(remote);
  }
}
