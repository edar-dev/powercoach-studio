import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/core/sync/offline_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';

/// Round-trip: write → close → reopen on the same native SQLite path.
///
/// Web uses the same Drift schema via wasm/worker; this test covers the native
/// file-backed path only (no wasm / web Drift worker).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StableFakePathProvider pathProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    pathProvider = StableFakePathProvider(prefix: 'powercoach_round_trip_');
    PathProviderPlatform.instance = pathProvider;
    await OfflineLocalStore.instance.debugCloseForTest();
  });

  tearDown(() async {
    await OfflineLocalStore.instance.debugCloseForTest();
  });

  Map<String, dynamic> customerEntity({
    required String id,
    required String name,
    required String userId,
  }) {
    return <String, dynamic>{
      'id': id,
      'type': OfflineEntityType.customer.name,
      'scopeId': id,
      'payload': <String, dynamic>{
        'id': id,
        'name': name,
        'userId': userId,
      },
      'updatedAt': DateTime.utc(2026, 3, 15).toIso8601String(),
      'deleted': false,
      'localOnly': false,
    };
  }

  test('entities survive close/reopen and stay scoped by userId', () async {
    const userA = 'user-a-round-trip';
    const userB = 'user-b-round-trip';
    final store = OfflineLocalStore.instance;

    await store.upsertEntityForUser(
      userA,
      customerEntity(id: 'cust-a', name: 'Alice', userId: userA),
    );
    await store.upsertEntityForUser(
      userB,
      customerEntity(id: 'cust-b', name: 'Bob', userId: userB),
    );

    final beforeA = await store.listEntitiesJsonForBackup(userA);
    expect(beforeA, hasLength(1));
    expect(beforeA.single['id'], 'cust-a');
    expect(
      beforeA.map((e) => e['id']),
      isNot(contains('cust-b')),
    );

    final beforeB = await store.listEntitiesJsonForBackup(userB);
    expect(beforeB, hasLength(1));
    expect(beforeB.single['id'], 'cust-b');

    await store.debugCloseForTest();

    // Same singleton reopens Drift on the stable path provider paths.
    final afterA = await store.listEntitiesJsonForBackup(userA);
    expect(afterA, hasLength(1));
    expect(afterA.single['id'], 'cust-a');
    expect(afterA.single['userId'], userA);

    final afterB = await store.listEntitiesJsonForBackup(userB);
    expect(afterB, hasLength(1));
    expect(afterB.single['id'], 'cust-b');
    expect(
      afterB.map((e) => e['id']),
      isNot(contains('cust-a')),
    );
  });
}
