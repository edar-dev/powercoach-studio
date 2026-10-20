import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/core/sync/offline_repository_support.dart';
import 'package:powercoach_studio/features/customers/data/customer_measurement_repository.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_measurement.dart';
import 'package:powercoach_studio/features/workouts/domain/maximal_measurement_write.dart';
import 'package:powercoach_studio/features/workouts/domain/maximal_ref.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CustomerMeasurementRepository repo;

  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PathProviderPlatform.instance = FakePathProviderPlatform(
      prefix: 'powercoach_maximal_measurement_write_test_',
    );
  });

  setUp(() async {
    await OfflineLocalStore.instance.clear();
    // Local-only support (no remote) so unit tests do not require network.
    repo = CustomerMeasurementRepository(offline: OfflineRepositorySupport());
  });

  test('creates measurement when customer has none', () async {
    final saved = await upsertMeasurementLift1Rm(
      repository: repo,
      customerId: 'c1',
      lift: MaximalLift.bench,
      weightKg: 100,
    );
    expect(saved.benchPress1RM, 100);
    expect(saved.squat1RM, isNull);
    final list = await repo.getByCustomerId('c1');
    expect(list, hasLength(1));
  });

  test('updates latest measurement lift field when history exists', () async {
    await repo.create('c1', {
      'measurementDate': CustomerMeasurement.toDateString(DateTime(2024, 1, 1)),
      'benchPress1RM': 80.0,
    });
    final latest = await repo.create('c1', {
      'measurementDate': CustomerMeasurement.toDateString(DateTime(2025, 6, 1)),
      'benchPress1RM': 90.0,
      'squat1RM': 140.0,
    });

    final saved = await upsertMeasurementLift1Rm(
      repository: repo,
      customerId: 'c1',
      lift: MaximalLift.bench,
      weightKg: 105,
    );
    expect(saved.id, latest.id);
    expect(saved.benchPress1RM, 105);
    expect(saved.squat1RM, 140);

    final all = await repo.getByCustomerId('c1');
    expect(all, hasLength(2));
    final older = all.firstWhere((m) => m.id != latest.id);
    expect(older.benchPress1RM, 80);
  });
}
