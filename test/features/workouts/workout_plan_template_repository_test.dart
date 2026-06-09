import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/constants/workout_plan_template_scope.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/features/customers/data/customer_repository.dart';
import 'package:powercoach_studio/features/customers/data/models/customer.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PathProviderPlatform.instance =
        FakePathProviderPlatform(prefix: 'powercoach_tpl_test_');
  });

  setUp(() async {
    await OfflineLocalStore.instance.clear();
  });

  test('templates use sentinel scope; getAll excludes; duplicateToCustomer copies', () async {
    final customerRepo = CustomerRepository();
    final planRepo = WorkoutPlanRepository();
    final now = DateTime.now();
    final customer = await customerRepo.create(
      Customer(
        id: '',
        userId: '__legacy__',
        name: 'Client A',
        createdAt: now,
        updatedAt: now,
      ),
    );
    final routineJson = jsonEncode(WorkoutRoutine.empty().toJson());
    await planRepo.create(
      customerId: customer.id,
      name: 'Live plan',
      planDataJson: routineJson,
    );
    final tpl = await planRepo.createTemplate(
      name: 'Upper template',
      planDataJson: routineJson,
    );
    expect(tpl.customerId, kWorkoutPlanTemplateScopeId);

    final all = await planRepo.getAll();
    expect(all, hasLength(1));
    expect(all.single.name, 'Live plan');

    final templates = await planRepo.listTemplates();
    expect(templates, hasLength(1));
    expect(templates.single.id, tpl.id);

    final dup = await planRepo.duplicateToCustomer(
      sourcePlanId: tpl.id,
      customerId: customer.id,
      name: 'From template',
    );
    expect(dup.customerId, customer.id);
    expect(dup.id, isNot(tpl.id));
    expect(dup.name, 'From template');

    final clientPlans = await planRepo.getByCustomerId(customer.id);
    expect(clientPlans.length, 2);
  });

  test('duplicateToCustomer rejects template scope as target', () async {
    final planRepo = WorkoutPlanRepository();
    final tpl = await planRepo.createTemplate(
      name: 'T',
      planDataJson: jsonEncode(WorkoutRoutine.empty().toJson()),
    );
    expect(
      () => planRepo.duplicateToCustomer(
        sourcePlanId: tpl.id,
        customerId: kWorkoutPlanTemplateScopeId,
      ),
      throwsArgumentError,
    );
  });
}
