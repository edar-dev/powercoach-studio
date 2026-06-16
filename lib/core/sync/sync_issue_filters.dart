import 'offline_models.dart';

/// Operations that need coach attention on the sync issues screen.
bool pendingOperationNeedsAttention(PendingOperationStatus status) {
  switch (status) {
    case PendingOperationStatus.failed:
    case PendingOperationStatus.conflict:
    case PendingOperationStatus.deadLetter:
    case PendingOperationStatus.blockedAuth:
      return true;
    case PendingOperationStatus.pending:
    case PendingOperationStatus.syncing:
    case PendingOperationStatus.completed:
      return false;
  }
}

/// Queued operations still waiting to sync.
bool pendingOperationIsQueued(PendingOperationStatus status) {
  return status == PendingOperationStatus.pending ||
      status == PendingOperationStatus.syncing;
}

List<PendingOperation> filterAttentionPendingOperations(
  List<PendingOperation> operations,
) {
  return operations
      .where((op) => pendingOperationNeedsAttention(op.status))
      .toList();
}

List<PendingOperation> filterFailedPendingOperations(
  List<PendingOperation> operations,
) {
  return operations
      .where((op) => op.status == PendingOperationStatus.failed)
      .toList();
}

int countQueuedPendingOperations(List<PendingOperation> operations) {
  return operations.where((op) => pendingOperationIsQueued(op.status)).length;
}

int countAttentionPendingOperations(List<PendingOperation> operations) {
  return filterAttentionPendingOperations(operations).length;
}
