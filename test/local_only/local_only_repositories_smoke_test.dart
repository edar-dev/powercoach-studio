import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/features/customers/data/customer_exercise_record_repository.dart';
import 'package:powercoach_studio/features/customers/data/customer_measurement_repository.dart';
import 'package:powercoach_studio/features/customers/data/customer_repository.dart';
import 'package:powercoach_studio/features/customers/data/models/customer.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PathProviderPlatform.instance = _FakePathProviderPlatform();
  });

  setUp(() async {
    await OfflineLocalStore.instance.clear();
  });

  test('customer local CRUD smoke', () async {
    final repo = CustomerRepository();
    final now = DateTime.now();

    final created = await repo.create(
      Customer(
        id: '',
        userId: '__legacy__',
        name: 'Mario Rossi',
        email: 'mario@test.local',
        phone: '123456789',
        createdAt: now,
        updatedAt: now,
      ),
    );
    expect(created.id, startsWith('local_customer_'));

    final all = await repo.getAll();
    expect(all.any((c) => c.id == created.id), isTrue);

    final updated = await repo.update(
      Customer(
        id: created.id,
        userId: created.userId,
        name: 'Mario Rossi Updated',
        email: created.email,
        phone: created.phone,
        createdAt: created.createdAt,
        updatedAt: DateTime.now(),
        rowVersion: created.rowVersion,
      ),
    );
    expect(updated.name, 'Mario Rossi Updated');

    final loaded = await repo.getById(created.id);
    expect(loaded, isNotNull);
    expect(loaded!.name, 'Mario Rossi Updated');

    await repo.delete(created.id);
    final afterDelete = await repo.getAll();
    expect(afterDelete.any((c) => c.id == created.id), isFalse);
  });

  test('workout plan local CRUD smoke', () async {
    final repo = WorkoutPlanRepository();
    final routineJson = jsonEncode(WorkoutRoutine.empty().toJson());

    final created = await repo.create(
      customerId: 'customer-1',
      name: 'Plan A',
      planDataJson: routineJson,
      initialWeekNumber: 1,
    );
    expect(created.id, startsWith('local_workout_'));

    final byCustomer = await repo.getByCustomerId('customer-1');
    expect(byCustomer.any((p) => p.id == created.id), isTrue);

    final updated = await repo.update(
      planId: created.id,
      name: 'Plan A Updated',
      initialWeekNumber: 2,
    );
    expect(updated.name, 'Plan A Updated');
    expect(updated.initialWeekNumber, 2);

    final byId = await repo.getById(created.id);
    expect(byId, isNotNull);
    expect(byId!.name, 'Plan A Updated');

    await repo.delete(created.id);
    final afterDelete = await repo.getByCustomerId('customer-1');
    expect(afterDelete.any((p) => p.id == created.id), isFalse);
  });

  test('exercise library + records/measurements local smoke', () async {
    final exerciseRepo = CustomExerciseRepository();
    final recordsRepo = CustomerExerciseRecordRepository();
    final measurementsRepo = CustomerMeasurementRepository();

    final root = await exerciseRepo.create(<String, dynamic>{
      'name': 'Squat',
      'isMobility': false,
      'sortOrder': 0,
    });
    expect(root['id'], isNotNull);

    final tree = await exerciseRepo.getTree(mobility: false);
    expect(tree.isNotEmpty, isTrue);

    final customerId = 'customer-1';
    final measurement = await measurementsRepo.create(customerId, <String, dynamic>{
      'measurementDate': '2026-04-18',
      'squat1RM': 120.0,
    });
    expect(measurement.customerId, customerId);

    final allMeasurements = await measurementsRepo.getByCustomerId(customerId);
    expect(allMeasurements.any((m) => m.id == measurement.id), isTrue);

    final updatedMeasurement = await measurementsRepo.update(
      customerId,
      measurement.id,
      <String, dynamic>{'squat1RM': 130.0},
    );
    expect(updatedMeasurement.squat1RM, 130.0);

    final record = await recordsRepo.create(customerId, <String, dynamic>{
      'customExerciseId': root['id'],
      'exerciseName': 'Squat',
      'value': 100.0,
      'unit': 'kg',
      'recordedAt': '2026-04-18',
    });
    expect(record.customerId, customerId);

    final allRecords = await recordsRepo.getByCustomerId(customerId);
    expect(allRecords.any((r) => r.id == record.id), isTrue);

    final updatedRecord = await recordsRepo.update(
      customerId,
      record.id,
      <String, dynamic>{'value': 105.0},
    );
    expect(updatedRecord.value, 105.0);

    await recordsRepo.delete(customerId, record.id);
    await measurementsRepo.delete(customerId, measurement.id);

    final recordsAfterDelete = await recordsRepo.getByCustomerId(customerId);
    final measurementsAfterDelete = await measurementsRepo.getByCustomerId(customerId);
    expect(recordsAfterDelete.any((r) => r.id == record.id), isFalse);
    expect(measurementsAfterDelete.any((m) => m.id == measurement.id), isFalse);
  });
}

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    final dir = Directory.systemTemp.createTempSync('powercoach_test_docs_');
    return dir.path;
  }
}
