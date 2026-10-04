import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/core/sync/offline_models.dart';
import 'package:powercoach_studio/core/sync/offline_repository_support.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_plan_list_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';

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
      final offline = OfflineRepositorySupport();
      final repo = WorkoutPlanRepository(offline: offline);
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
      expect(updated.planDataMap.containsKey('archivedAt'), isTrue);
      expect(updated.planDataMap.containsKey('completedAt'), isTrue);

      final stored = await offline.readLocalEntityById(
        OfflineEntityType.workoutPlan,
        created.id,
      );
      expect(stored?['planData'], isA<Map>());
      expect(
        (stored!['planData'] as Map)['archivedAt'],
        isNotNull,
      );
    });

    test('create stores planData as Map in payload', () async {
      final offline = OfflineRepositorySupport();
      final repo = WorkoutPlanRepository(offline: offline);
      final created = await repo.create(
        customerId: 'customer-1',
        name: 'Map Plan',
        routine: WorkoutRoutine.empty().copyWith(name: 'Map Plan'),
      );

      final stored = await offline.readLocalEntityById(
        OfflineEntityType.workoutPlan,
        created.id,
      );
      expect(stored?['planData'], isA<Map>());
      expect((stored!['planData'] as Map)['name'], 'Map Plan');

      final reloaded = await repo.getById(created.id);
      expect(reloaded, isNotNull);
      expect(reloaded!.routine.name, 'Map Plan');
      expect(reloaded.planData, isA<String>());
    });

    test('legacy String planData is readable and rewrite to Map on update',
        () async {
      final offline = OfflineRepositorySupport();
      final repo = WorkoutPlanRepository(offline: offline);
      final now = DateTime.now().toIso8601String();
      const planId = 'legacy-string-plan';
      await offline.saveLocalEntity(
        type: OfflineEntityType.workoutPlan,
        id: planId,
        scopeId: 'customer-1',
        payload: <String, dynamic>{
          'id': planId,
          'customerId': 'customer-1',
          'userId': '',
          'name': 'Legacy',
          'planData':
              '{"name":"Legacy","weeks":[],"archivedAt":"2026-01-15T00:00:00.000"}',
          'useCustomPdfHeader': false,
          'initialWeekNumber': 1,
          'createdAt': now,
          'updatedAt': now,
          'rowVersion': 1,
        },
        localOnly: false,
      );

      final loaded = await repo.getById(planId);
      expect(loaded, isNotNull);
      expect(loaded!.routine.name, 'Legacy');
      expect(isArchivedPlan(loaded), isTrue);

      final before = await offline.readLocalEntityById(
        OfflineEntityType.workoutPlan,
        planId,
      );
      expect(before?['planData'], isA<String>());

      final updated = await repo.update(
        planId: planId,
        routine: WorkoutRoutine.empty().copyWith(name: 'Rewritten'),
      );
      expect(updated.routine.name, 'Rewritten');
      expect(isArchivedPlan(updated), isTrue);

      final after = await offline.readLocalEntityById(
        OfflineEntityType.workoutPlan,
        planId,
      );
      expect(after?['planData'], isA<Map>());
      expect((after!['planData'] as Map)['name'], 'Rewritten');
      expect((after['planData'] as Map)['archivedAt'], isNotNull);
    });
  });
}
