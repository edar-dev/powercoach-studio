import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/core/sync/offline_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PathProviderPlatform.instance =
        FakePathProviderPlatform(prefix: 'powercoach_pending_ops_test_');
  });

  setUp(() async {
    await OfflineLocalStore.instance.clear();
  });

  PendingOperation sampleOp({
    String id = 'op-1',
    String userId = '__legacy__',
    PendingOperationStatus status = PendingOperationStatus.pending,
    String? errorMessage,
  }) {
    final now = DateTime(2026, 4, 1, 12);
    return PendingOperation(
      id: id,
      userId: userId,
      entityType: OfflineEntityType.customer,
      entityId: 'customer-1',
      scopeId: '__legacy__',
      operationType: OfflineOperationType.update,
      path: '/customers/customer-1',
      payload: const {'id': 'customer-1', 'name': 'Mario'},
      createdAt: now,
      updatedAt: now,
      status: status,
      errorMessage: errorMessage,
    );
  }

  test('upsert and read pending operations', () async {
    final store = OfflineLocalStore.instance;
    await store.upsertPendingOperation(sampleOp());

    final all = await store.readPendingOperations();
    expect(all, hasLength(1));
    expect(all.single.id, 'op-1');
    expect(all.single.status, PendingOperationStatus.pending);
  });

  test('upsert replaces existing operation by id', () async {
    final store = OfflineLocalStore.instance;
    await store.upsertPendingOperation(sampleOp());
    await store.upsertPendingOperation(
      sampleOp(
        status: PendingOperationStatus.failed,
        errorMessage: 'network',
      ),
    );

    final all = await store.readPendingOperations();
    expect(all, hasLength(1));
    expect(all.single.status, PendingOperationStatus.failed);
    expect(all.single.errorMessage, 'network');
  });

  test('removePendingOperation deletes row', () async {
    final store = OfflineLocalStore.instance;
    await store.upsertPendingOperation(sampleOp());
    await store.removePendingOperation('op-1');

    expect(await store.readPendingOperations(), isEmpty);
  });

  test('listPendingJsonForBackup scopes by user id', () async {
    final store = OfflineLocalStore.instance;
    await store.upsertPendingOperation(sampleOp());
    await store.upsertPendingOperation(sampleOp(id: 'op-2', userId: 'coach-b'));

    final legacyBackup = await store.listPendingJsonForBackup('__legacy__');
    expect(legacyBackup, hasLength(1));
    expect(legacyBackup.single['id'], 'op-1');
  });
}
