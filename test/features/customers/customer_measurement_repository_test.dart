import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/features/customers/data/customer_measurement_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PathProviderPlatform.instance =
        FakePathProviderPlatform(prefix: 'powercoach_measurement_repo_test_');
  });

  setUp(() async {
    await OfflineLocalStore.instance.clear();
  });

  test('create and list measurements for customer', () async {
    final repo = CustomerMeasurementRepository();
    const customerId = 'customer-42';

    final created = await repo.create(customerId, <String, dynamic>{
      'measurementDate': '2026-05-10',
      'squat1RM': 100.0,
    });

    expect(created.customerId, customerId);
    expect(created.squat1RM, 100.0);

    final all = await repo.getByCustomerId(customerId);
    expect(all, hasLength(1));
    expect(all.single.id, created.id);
  });

  test('update and delete measurement', () async {
    final repo = CustomerMeasurementRepository();
    const customerId = 'customer-99';

    final created = await repo.create(customerId, <String, dynamic>{
      'measurementDate': '2026-06-01',
      'benchPress1RM': 80.0,
    });

    final updated = await repo.update(
      customerId,
      created.id,
      <String, dynamic>{'benchPress1RM': 79.5},
    );
    expect(updated.benchPress1RM, 79.5);

    await repo.delete(customerId, created.id);
    expect(await repo.getByCustomerId(customerId), isEmpty);
  });
}
