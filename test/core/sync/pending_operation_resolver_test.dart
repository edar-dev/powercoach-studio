import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/sync/offline_models.dart';
import 'package:powercoach_studio/core/sync/pending_operation_resolver.dart';
import 'package:powercoach_studio/core/sync/sync_issue_filters.dart';

void main() {
  group('PendingOperationResolver', () {
    late List<PendingOperation> pendingOps;
    late Map<String, OfflineEntity> entities;
    late PendingOperationResolver resolver;

    PendingOperation op({
      String id = 'op-1',
      PendingOperationStatus status = PendingOperationStatus.conflict,
      OfflineOperationType operationType = OfflineOperationType.update,
      Map<String, dynamic>? conflictRemotePayload,
      Map<String, dynamic> payload = const {'id': 'plan-1', 'name': 'Local'},
    }) {
      final now = DateTime(2026, 1, 1);
      return PendingOperation(
        id: id,
        userId: 'user-1',
        entityType: OfflineEntityType.workoutPlan,
        entityId: 'plan-1',
        scopeId: 'cust-1',
        operationType: operationType,
        path: '/workout-plans/plan-1',
        payload: payload,
        createdAt: now,
        updatedAt: now,
        status: status,
        conflictRemotePayload: conflictRemotePayload,
        errorMessage: status == PendingOperationStatus.failed ? 'boom' : null,
      );
    }

    setUp(() {
      pendingOps = [];
      entities = {};
      resolver = PendingOperationResolver(
        upsertPending: (operation) async {
          pendingOps.removeWhere((item) => item.id == operation.id);
          pendingOps.add(operation);
        },
        removePending: (opId) async {
          pendingOps.removeWhere((item) => item.id == opId);
        },
        upsertEntity: (entity) async {
          entities[entity.id] = entity;
        },
        markDeleted: (type, entityId) async {
          final current = entities[entityId];
          if (current == null) return;
          entities[entityId] = OfflineEntity(
            id: current.id,
            type: current.type,
            scopeId: current.scopeId,
            payload: current.payload,
            updatedAt: DateTime.now(),
            deleted: true,
            localOnly: current.localOnly,
          );
        },
      );
    });

    test('keepLocal resets conflict op to pending', () async {
      pendingOps.add(
        op(
          conflictRemotePayload: const {'id': 'plan-1', 'name': 'Remote'},
        ),
      );

      await resolver.keepLocal(pendingOps.single);

      expect(pendingOps, hasLength(1));
      expect(pendingOps.single.status, PendingOperationStatus.pending);
      expect(pendingOps.single.conflictRemotePayload, isNull);
      expect(pendingOps.single.errorMessage, isNull);
    });

    test('acceptRemote applies remote payload and removes op', () async {
      pendingOps.add(
        op(
          conflictRemotePayload: const {'id': 'plan-1', 'name': 'Remote'},
        ),
      );

      await resolver.acceptRemote(pendingOps.single);

      expect(pendingOps, isEmpty);
      expect(entities['plan-1']?.payload['name'], 'Remote');
      expect(entities['plan-1']?.deleted, isFalse);
    });

    test('discard removes pending operation', () async {
      pendingOps.add(
        op(status: PendingOperationStatus.deadLetter),
      );

      await resolver.discard(pendingOps.single);

      expect(pendingOps, isEmpty);
    });
  });

  group('sync_issue_filters', () {
    test('counts attention and queued operations', () {
      final now = DateTime(2026, 1, 1);
      PendingOperation stub(PendingOperationStatus status) => PendingOperation(
        id: status.name,
        userId: 'u',
        entityType: OfflineEntityType.customer,
        entityId: 'c1',
        scopeId: 's',
        operationType: OfflineOperationType.update,
        path: '/customers/c1',
        payload: const {},
        createdAt: now,
        updatedAt: now,
        status: status,
      );

      final ops = [
        stub(PendingOperationStatus.pending),
        stub(PendingOperationStatus.syncing),
        stub(PendingOperationStatus.failed),
        stub(PendingOperationStatus.conflict),
        stub(PendingOperationStatus.completed),
      ];

      expect(countQueuedPendingOperations(ops), 2);
      expect(countAttentionPendingOperations(ops), 2);
      expect(filterAttentionPendingOperations(ops), hasLength(2));
    });
  });
}
