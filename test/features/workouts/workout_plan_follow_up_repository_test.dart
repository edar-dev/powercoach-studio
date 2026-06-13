import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
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
        FakePathProviderPlatform(prefix: 'powercoach_followup_test_');
  });

  setUp(() async {
    await OfflineLocalStore.instance.clear();
  });

  test('createFollowUpFromPlan clones plan, bumps week and resets maps', () async {
    final customerRepo = CustomerRepository();
    final repo = WorkoutPlanRepository();
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

    final sourceRoutine = WorkoutRoutine(
      name: 'Block 1',
      mobilitySections: WorkoutRoutine.empty().mobilitySections,
      mobilityItems: const [],
      weeks: const [
        Week(id: 'w1', name: 'Week 1', days: []),
        Week(id: 'w2', name: 'Week 2', days: []),
      ],
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 2, 1),
      currentWeek: 2,
      sessionCompletionByKey: const {'0-0': true},
      sessionSkippedByKey: const {'1-0': true},
    );

    final sourcePlan = await repo.create(
      customerId: customer.id,
      name: 'Plan A',
      planDataJson: jsonEncode(sourceRoutine.toJson()),
      initialWeekNumber: 5,
      phase: 'Strength',
      tags: 'Upper',
      notes: 'Keep tempo strict',
    );

    final followUpPlan = await repo.createFollowUpFromPlan(
      sourcePlanId: sourcePlan.id,
      name: 'Plan A Follow-up',
      newStartDate: DateTime(2026, 3, 3),
    );
    final followUpRoutine = planDataToRoutine(followUpPlan.planData);

    expect(followUpPlan.id, isNot(sourcePlan.id));
    expect(followUpPlan.customerId, sourcePlan.customerId);
    expect(followUpPlan.name, 'Plan A Follow-up');
    expect(followUpPlan.initialWeekNumber, 7);
    expect(followUpPlan.phase, 'Strength');
    expect(followUpPlan.tags, 'Upper');
    expect(followUpPlan.notes, 'Keep tempo strict');
    expect(followUpRoutine.startDate, DateTime(2026, 3, 3));
    expect(followUpRoutine.endDate, isNull);
    expect(followUpRoutine.currentWeek, 1);
    expect(followUpRoutine.sessionCompletionByKey, isEmpty);
    expect(followUpRoutine.sessionSkippedByKey, isEmpty);
    expect(followUpRoutine.weeks.length, 2);
  });
}
