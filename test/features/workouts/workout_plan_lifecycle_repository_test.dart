import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_plan_list_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';
import 'package:powercoach_studio/core/sync/offline_repository_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PathProviderPlatform.instance =
        FakePathProviderPlatform(prefix: 'powercoach_lifecycle_');
  });

  setUp(() async {
    await OfflineLocalStore.instance.clear();
  });

  group('WorkoutPlanRepository lifecycle', () {
    test('archive and unarchive round-trip', () async {
      final repo = WorkoutPlanRepository(offline: OfflineRepositorySupport());
      final created = await repo.create(
        customerId: 'customer-1',
        name: 'Plan A',
        routine: WorkoutRoutine.empty(),
      );
      expect(isArchivedPlan(created), isFalse);

      final archived = await repo.archivePlan(created.id);
      expect(isArchivedPlan(archived), isTrue);

      final unarchived = await repo.unarchivePlan(created.id);
      expect(isArchivedPlan(unarchived), isFalse);
    });

    test('markPlanCompleted persists completedAt', () async {
      final repo = WorkoutPlanRepository(offline: OfflineRepositorySupport());
      final created = await repo.create(
        customerId: 'customer-1',
        name: 'Plan B',
        routine: WorkoutRoutine.empty(),
      );

      final completed = await repo.markPlanCompleted(created.id);
      expect(completedAtForPlan(completed), isNotNull);
      expect(isArchivedPlan(completed), isFalse);

      final reloaded = await repo.getById(created.id);
      expect(reloaded, isNotNull);
      expect(completedAtForPlan(reloaded!), isNotNull);
    });

    test('update with routine preserves archivedAt and completedAt', () async {
      final repo = WorkoutPlanRepository(offline: OfflineRepositorySupport());
      final created = await repo.create(
        customerId: 'customer-1',
        name: 'Plan C',
        routine: WorkoutRoutine.empty().copyWith(name: 'Plan C'),
      );
      await repo.archivePlan(created.id);
      await repo.markPlanCompleted(
        created.id,
        completedAt: DateTime(2026, 2, 1),
      );

      final updated = await repo.update(
        planId: created.id,
        name: 'Plan C Updated',
        routine: WorkoutRoutine.empty().copyWith(
          name: 'Plan C Updated',
          currentWeek: 3,
        ),
      );

      expect(updated.name, 'Plan C Updated');
      expect(updated.routine.currentWeek, 3);
      expect(isArchivedPlan(updated), isTrue);
      expect(completedAtForPlan(updated), isNotNull);
      final map = jsonDecode(updated.planData) as Map<String, dynamic>;
      expect(map.containsKey('archivedAt'), isTrue);
      expect(map.containsKey('completedAt'), isTrue);
    });
  });
}
