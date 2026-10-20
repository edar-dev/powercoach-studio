import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/core/sync/offline_repository_support.dart';
import 'package:powercoach_studio/features/customers/data/customer_maximal_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PathProviderPlatform.instance =
        FakePathProviderPlatform(prefix: 'powercoach_maximal_repo_test_');
  });

  setUp(() async {
    await OfflineLocalStore.instance.clear();
  });

  test('create and list massimali for customer', () async {
    final repo = CustomerMaximalRepository(offline: OfflineRepositorySupport());
    const customerId = 'customer-42';

    final created = await repo.create(customerId, <String, dynamic>{
      'label': 'Military press',
      'weightKg': 60.0,
    });

    expect(created.customerId, customerId);
    expect(created.label, 'Military press');
    expect(created.weightKg, 60.0);
    expect(created.linkedExerciseKey, isNull);

    final all = await repo.getByCustomerId(customerId);
    expect(all, hasLength(1));
    expect(all.single.id, created.id);
  });

  test('update and delete maximal; scoped by customerId', () async {
    final repo = CustomerMaximalRepository(offline: OfflineRepositorySupport());
    const customerA = 'customer-a';
    const customerB = 'customer-b';

    final created = await repo.create(customerA, <String, dynamic>{
      'label': 'Incline bench',
      'weightKg': 80.0,
      'linkedExerciseKey': 'bench-incline',
    });
    await repo.create(customerB, <String, dynamic>{
      'label': 'Other',
      'weightKg': 40.0,
    });

    final updated = await repo.update(
      customerA,
      created.id,
      <String, dynamic>{'weightKg': 82.5, 'label': 'Incline bench'},
    );
    expect(updated.weightKg, 82.5);
    expect(updated.linkedExerciseKey, 'bench-incline');

    expect(await repo.getByCustomerId(customerA), hasLength(1));
    expect(await repo.getByCustomerId(customerB), hasLength(1));

    await repo.delete(customerA, created.id);
    expect(await repo.getByCustomerId(customerA), isEmpty);
    expect(await repo.getByCustomerId(customerB), hasLength(1));
  });
}
