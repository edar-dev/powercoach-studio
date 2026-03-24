import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../network/gymblog_api_client.dart';
import '../storage/offline_local_store.dart';
import 'offline_models.dart';
import 'sync_status_controller.dart';

enum ConflictResolutionChoice { keepLocal, keepRemote }

class SyncOrchestrator {
  SyncOrchestrator._();

  static final SyncOrchestrator instance = SyncOrchestrator._();

  final OfflineLocalStore _store = OfflineLocalStore.instance;
  final GymBlogApiClient _api = GymBlogApiClient();
  final SyncStatusController status = SyncStatusController();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _isSyncing = false;
  Timer? _debounce;

  Future<void> initialize() async {
    await refreshStatus();
    _connectivitySub ??= Connectivity().onConnectivityChanged.listen((result) {
      final isOnline = result.any((e) => e != ConnectivityResult.none);
      if (isOnline) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 750), syncNow);
      }
    });
  }

  Future<void> refreshStatus() async {
    final ops = await _store.readPendingOperations();
    final pending = ops.where((e) => e.status == PendingOperationStatus.pending || e.status == PendingOperationStatus.syncing).length;
    final failed = ops.where((e) => e.status == PendingOperationStatus.failed).length;
    final conflicts = ops.where((e) => e.status == PendingOperationStatus.conflict).toList();
    status.update(
      isSyncing: _isSyncing,
      pendingCount: pending,
      failedCount: failed,
      conflicts: conflicts,
    );
  }

  Future<void> enqueue(PendingOperation op) async {
    await _store.upsertPendingOperation(op);
    await refreshStatus();
    unawaited(syncNow());
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;
    await refreshStatus();
    try {
      final ops = await _store.readPendingOperations();
      for (final op in ops) {
        if (op.status == PendingOperationStatus.completed ||
            op.status == PendingOperationStatus.conflict) {
          continue;
        }
        await _syncOperation(op);
      }
    } finally {
      _isSyncing = false;
      await refreshStatus();
    }
  }

  Future<void> resolveConflict(
    PendingOperation op,
    ConflictResolutionChoice choice,
  ) async {
    if (choice == ConflictResolutionChoice.keepRemote) {
      await _store.removePendingOperation(op.id);
      await _store.upsertEntity(
        OfflineEntity(
          id: op.entityId,
          type: op.entityType,
          scopeId: op.scopeId,
          payload: op.conflictRemotePayload ?? op.payload,
          updatedAt: DateTime.now(),
          deleted: false,
          localOnly: false,
        ),
      );
      await refreshStatus();
      return;
    }

    final retry = op.copyWith(
      status: PendingOperationStatus.pending,
      updatedAt: DateTime.now(),
      conflictRemotePayload: null,
      errorMessage: null,
    );
    await _store.upsertPendingOperation(retry);
    await refreshStatus();
    await syncNow();
  }

  Future<void> _syncOperation(PendingOperation op) async {
    final syncing = op.copyWith(
      status: PendingOperationStatus.syncing,
      updatedAt: DateTime.now(),
    );
    await _store.upsertPendingOperation(syncing);
    await refreshStatus();

    try {
      if (op.operationType == OfflineOperationType.delete) {
        await _api.delete(op.path);
        await _store.removePendingOperation(op.id);
        return;
      }

      final response = op.operationType == OfflineOperationType.create
          ? await _api.post(op.path, op.payload)
          : await _api.put(op.path, op.payload);

      final serverUpdatedAt = DateTime.tryParse(response['updatedAt']?.toString() ?? '');
      final hasConflict = op.baseUpdatedAt != null &&
          serverUpdatedAt != null &&
          serverUpdatedAt.isAfter(op.baseUpdatedAt!) &&
          op.operationType == OfflineOperationType.update;
      if (hasConflict) {
        await _store.upsertPendingOperation(
          op.copyWith(
            status: PendingOperationStatus.conflict,
            updatedAt: DateTime.now(),
            conflictRemotePayload: response,
            errorMessage: 'Remote version changed',
          ),
        );
        return;
      }

      final serverId = response['id']?.toString();
      if (op.operationType == OfflineOperationType.create &&
          serverId != null &&
          serverId.isNotEmpty &&
          serverId != op.entityId) {
        await _store.replaceTempEntityId(
          type: op.entityType,
          tempId: op.entityId,
          serverId: serverId,
        );
        await _store.replaceTempIdsInPendingOps(
          type: op.entityType,
          tempId: op.entityId,
          serverId: serverId,
        );
      }

      await _store.upsertEntity(
        OfflineEntity(
          id: (serverId != null && serverId.isNotEmpty) ? serverId : op.entityId,
          type: op.entityType,
          scopeId: op.scopeId,
          payload: response,
          updatedAt: DateTime.now(),
          deleted: false,
          localOnly: false,
        ),
      );
      await _store.removePendingOperation(op.id);
    } on GymBlogApiException catch (e) {
      final nextRetry = op.retryCount + 1;
      final failed = op.copyWith(
        retryCount: nextRetry,
        status: PendingOperationStatus.failed,
        updatedAt: DateTime.now(),
        errorMessage: e.message,
      );
      await _store.upsertPendingOperation(failed);
      await Future<void>.delayed(Duration(milliseconds: min(6000, 400 * nextRetry)));
    } catch (e) {
      await _store.upsertPendingOperation(
        op.copyWith(
          retryCount: op.retryCount + 1,
          status: PendingOperationStatus.failed,
          updatedAt: DateTime.now(),
          errorMessage: e.toString(),
        ),
      );
    } finally {
      await refreshStatus();
    }
  }

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    _connectivitySub = null;
    _debounce?.cancel();
  }
}
