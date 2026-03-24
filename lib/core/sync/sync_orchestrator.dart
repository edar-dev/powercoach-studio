import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../di/service_locator.dart';
import '../network/gymblog_api_client.dart';
import '../storage/offline_local_store.dart';
import 'offline_models.dart';
import 'sync_status_controller.dart';

enum ConflictResolutionChoice { keepLocal, keepRemote }

/// Max HTTP retries before marking an operation as dead-letter.
const int kMaxSyncRetries = 8;

class SyncOrchestrator with WidgetsBindingObserver {
  SyncOrchestrator._();

  static final SyncOrchestrator instance = SyncOrchestrator._();

  final OfflineLocalStore _store = OfflineLocalStore.instance;
  final GymBlogApiClient _api = getIt<GymBlogApiClient>();
  final SyncStatusController status = SyncStatusController();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  StreamSubscription<AuthState>? _authSub;
  bool _isSyncing = false;
  Timer? _debounce;
  Timer? _resumeDebounce;
  bool _observerRegistered = false;

  String? _currentUserId() {
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  Future<void> initialize() async {
    await refreshStatus();
    _connectivitySub ??= Connectivity().onConnectivityChanged.listen((result) {
      final isOnline = result.any((e) => e != ConnectivityResult.none);
      if (isOnline) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 750), syncNow);
      }
    });
    _authSub ??= Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn ||
          data.event == AuthChangeEvent.tokenRefreshed) {
        unawaited(syncNow());
      }
    });
    if (!_observerRegistered) {
      WidgetsBinding.instance.addObserver(this);
      _observerRegistered = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resumeDebounce?.cancel();
      _resumeDebounce = Timer(const Duration(milliseconds: 500), () {
        unawaited(syncNow());
      });
    }
  }

  Future<void> refreshStatus() async {
    final ops = await _store.readPendingOperations();
    final pending = ops
        .where((e) =>
            e.status == PendingOperationStatus.pending ||
            e.status == PendingOperationStatus.syncing)
        .length;
    final failed = ops
        .where((e) =>
            e.status == PendingOperationStatus.failed ||
            e.status == PendingOperationStatus.deadLetter ||
            e.status == PendingOperationStatus.blockedAuth)
        .length;
    final conflicts =
        ops.where((e) => e.status == PendingOperationStatus.conflict).toList();
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
    final uid = _currentUserId();
    if (uid == null || uid.isEmpty) return;
    _isSyncing = true;
    await refreshStatus();
    try {
      final ops = await _store.readPendingOperations();
      final sorted = List<PendingOperation>.from(ops)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      for (final op in sorted) {
        if (op.status == PendingOperationStatus.completed ||
            op.status == PendingOperationStatus.conflict ||
            op.status == PendingOperationStatus.deadLetter) {
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
      final remote = op.conflictRemotePayload ?? op.payload;
      await _store.upsertEntity(
        OfflineEntity(
          id: op.entityId,
          type: op.entityType,
          scopeId: op.scopeId,
          payload: Map<String, dynamic>.from(remote),
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
      clearConflictRemote: true,
      clearError: true,
    );
    await _store.upsertPendingOperation(retry);
    await refreshStatus();
    await syncNow();
  }

  void _syncBreadcrumb(String message, Map<String, dynamic> data) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: 'sync',
        data: data,
      ),
    );
  }

  Future<void> _syncOperation(PendingOperation op) async {
    final uid = _currentUserId();
    if (uid == null || uid.isEmpty) return;

    if (op.status == PendingOperationStatus.blockedAuth) {
      op = op.copyWith(
        status: PendingOperationStatus.pending,
        updatedAt: DateTime.now(),
        clearError: true,
      );
      await _store.upsertPendingOperation(op);
    }

    final syncing = op.copyWith(
      status: PendingOperationStatus.syncing,
      updatedAt: DateTime.now(),
    );
    await _store.upsertPendingOperation(syncing);
    await refreshStatus();

    try {
      if (op.operationType == OfflineOperationType.delete) {
        try {
          await _api.delete(op.path);
        } on GymBlogApiException catch (e) {
          if (e.statusCode != 404) rethrow;
        }
        await _store.removePendingOperation(op.id);
        _syncBreadcrumb('sync_delete_ok', {
          'op_uuid': op.id,
          'entity_type': op.entityType.name,
        });
        GymBlogApiClient.clearCache();
        return;
      }

      Map<String, dynamic> response;
      try {
        response = op.operationType == OfflineOperationType.create
            ? await _api.post(op.path, op.payload)
            : await _api.put(op.path, op.payload);
      } on GymBlogApiException catch (e) {
        if (e.statusCode == 401) {
          await _store.upsertPendingOperation(
            op.copyWith(
              status: PendingOperationStatus.blockedAuth,
              updatedAt: DateTime.now(),
              errorMessage: e.message,
            ),
          );
          _syncBreadcrumb('sync_blocked_auth', {'op_uuid': op.id});
          return;
        }
        if (e.statusCode == 409) {
          Map<String, dynamic>? current;
          final raw = e.responseBody;
          if (raw != null && raw['current'] is Map) {
            current = Map<String, dynamic>.from(raw['current'] as Map);
          }
          await _store.upsertPendingOperation(
            op.copyWith(
              status: PendingOperationStatus.conflict,
              updatedAt: DateTime.now(),
              conflictRemotePayload: current ?? {'message': e.message},
              errorMessage: 'conflict',
            ),
          );
          _syncBreadcrumb('sync_conflict_http', {'op_uuid': op.id});
          return;
        }
        rethrow;
      }

      final serverUpdatedAt =
          DateTime.tryParse(response['updatedAt']?.toString() ?? '');
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
        _syncBreadcrumb('sync_conflict_version', {'op_uuid': op.id});
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
      _syncBreadcrumb('sync_ok', {
        'op_uuid': op.id,
        'entity_type': op.entityType.name,
        'retry_count': op.retryCount,
      });
      GymBlogApiClient.clearCache();
    } on GymBlogApiException catch (e) {
      await _failOrDeadLetter(op, e.message);
    } catch (e) {
      await _failOrDeadLetter(op, e.toString());
    } finally {
      await refreshStatus();
    }
  }

  Future<void> _failOrDeadLetter(PendingOperation op, String message) async {
    final nextRetry = op.retryCount + 1;
    final isDead = nextRetry >= kMaxSyncRetries;
    await _store.upsertPendingOperation(
      op.copyWith(
        retryCount: nextRetry,
        status: isDead
            ? PendingOperationStatus.deadLetter
            : PendingOperationStatus.failed,
        updatedAt: DateTime.now(),
        errorMessage: message,
      ),
    );
    _syncBreadcrumb(isDead ? 'sync_dead_letter' : 'sync_failed', {
      'op_uuid': op.id,
      'retry_count': nextRetry,
    });
    if (!isDead) {
      await Future<void>.delayed(
        Duration(milliseconds: min(6000, 400 * nextRetry)),
      );
    }
  }

  /// Resets failed and dead-letter ops to pending and triggers a sync (e.g. from Settings).
  Future<void> resetFailedAndDeadLetterToPending() async {
    final ops = await _store.readPendingOperations();
    for (final op in ops) {
      if (op.status == PendingOperationStatus.failed ||
          op.status == PendingOperationStatus.deadLetter) {
        await _store.upsertPendingOperation(
          op.copyWith(
            status: PendingOperationStatus.pending,
            retryCount: 0,
            updatedAt: DateTime.now(),
            clearError: true,
          ),
        );
      }
    }
    await refreshStatus();
    await syncNow();
  }

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    _connectivitySub = null;
    await _authSub?.cancel();
    _authSub = null;
    _debounce?.cancel();
    _resumeDebounce?.cancel();
    if (_observerRegistered) {
      WidgetsBinding.instance.removeObserver(this);
      _observerRegistered = false;
    }
  }
}
