import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/features/customers/data/customer_repository.dart';
import 'package:powercoach_studio/features/customers/data/models/customer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PathProviderPlatform.instance =
        FakePathProviderPlatform(prefix: 'powercoach_customer_repo_test_');
  });

  setUp(() async {
    await OfflineLocalStore.instance.clear();
  });

  test('create assigns local id and persists', () async {
    final repo = CustomerRepository();
    final now = DateTime(2026, 1, 15);

    final created = await repo.create(
      Customer(
        id: '',
        userId: '__legacy__',
        name: 'Luca Bianchi',
        email: 'luca@test.local',
        createdAt: now,
        updatedAt: now,
      ),
    );

    expect(created.id, startsWith('local_customer_'));
    expect(created.name, 'Luca Bianchi');

    final loaded = await repo.getById(created.id);
    expect(loaded, isNotNull);
    expect(loaded!.email, 'luca@test.local');
  });

  test('getAll returns all stored customers', () async {
    final repo = CustomerRepository();
    final now = DateTime(2026, 2, 1);

    await repo.create(
      Customer(
        id: '',
        userId: '__legacy__',
        name: 'One',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await repo.create(
      Customer(
        id: '',
        userId: '__legacy__',
        name: 'Two',
        createdAt: now,
        updatedAt: now,
      ),
    );

    final all = await repo.getAll();
    expect(all, hasLength(2));
    expect(all.map((c) => c.name), containsAll(['One', 'Two']));
  });

  test('update replaces stored fields', () async {
    final repo = CustomerRepository();
    final now = DateTime(2026, 3, 1);

    final created = await repo.create(
      Customer(
        id: '',
        userId: '__legacy__',
        name: 'Before',
        createdAt: now,
        updatedAt: now,
      ),
    );

    await repo.update(
      Customer(
        id: created.id,
        userId: created.userId,
        name: 'After',
        createdAt: created.createdAt,
        updatedAt: now.add(const Duration(hours: 1)),
        rowVersion: created.rowVersion,
      ),
    );

    final loaded = await repo.getById(created.id);
    expect(loaded?.name, 'After');
  });

  test('delete removes customer from store', () async {
    final repo = CustomerRepository();
    final now = DateTime(2026, 4, 1);

    final created = await repo.create(
      Customer(
        id: '',
        userId: '__legacy__',
        name: 'To delete',
        createdAt: now,
        updatedAt: now,
      ),
    );

    await repo.delete(created.id);

    expect(await repo.getById(created.id), isNull);
    expect((await repo.getAll()).where((c) => c.id == created.id), isEmpty);
  });
}
