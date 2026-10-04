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
    test('archive and unarchive round-trip at top-level', () async {
      final offline = OfflineRepositorySupport();
      final repo = WorkoutPlanRepository(offline: offline);
      final created = await repo.create(
        customerId: 'customer-1',
        name: 'Plan A',
        routine: WorkoutRoutine.empty(),
      );
      expect(isArchivedPlan(created), isFalse);

      final archived = await repo.archivePlan(created.id);
      expect(isArchivedPlan(archived), isTrue);
      expect(archived.planDataMap.containsKey('archivedAt'), isFalse);

      final stored = await offline.readLocalEntityById(
        OfflineEntityType.workoutPlan,
        created.id,
      );
      expect(stored?['archivedAt'], isNotNull);
      expect((stored?['planData'] as Map?)?.containsKey('archivedAt'), isFalse);

      final unarchived = await repo.unarchivePlan(created.id);
      expect(isArchivedPlan(unarchived), isFalse);
      expect(storedAfterClear(await offline.readLocalEntityById(
        OfflineEntityType.workoutPlan,
        created.id,
      )), isTrue);
    });

    test('markPlanCompleted persists completedAt at top-level', () async {
      final offline = OfflineRepositorySupport();
      final repo = WorkoutPlanRepository(offline: offline);
      final created = await repo.create(
        customerId: 'customer-1',
        name: 'Plan B',
        routine: WorkoutRoutine.empty(),
      );

      final completed = await repo.markPlanCompleted(created.id);
      expect(completedAtForPlan(completed), isNotNull);
      expect(isArchivedPlan(completed), isFalse);
      expect(completed.planDataMap.containsKey('completedAt'), isFalse);

      final reloaded = await repo.getById(created.id);
      expect(reloaded, isNotNull);
      expect(completedAtForPlan(reloaded!), isNotNull);

      final stored = await offline.readLocalEntityById(
        OfflineEntityType.workoutPlan,
        created.id,
      );
      expect(stored?['completedAt'], isNotNull);
      expect((stored?['planData'] as Map?)?.containsKey('completedAt'), isFalse);
    });

    test('update with routine preserves top-level lifecycle markers', () async {
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
      expect(updated.currentWeek, 3);
      expect(isArchivedPlan(updated), isTrue);
      expect(completedAtForPlan(updated), isNotNull);
      expect(updated.planDataMap.containsKey('archivedAt'), isFalse);
      expect(updated.planDataMap.containsKey('completedAt'), isFalse);
      expect(updated.planDataMap.containsKey('currentWeek'), isFalse);

      final stored = await offline.readLocalEntityById(
        OfflineEntityType.workoutPlan,
        created.id,
      );
      expect(stored?['planData'], isA<Map>());
      expect(stored?['archivedAt'], isNotNull);
      expect(stored?['completedAt'], isNotNull);
      expect(stored?['currentWeek'], 3);
      expect((stored!['planData'] as Map)['archivedAt'], isNull);
    });

    test('create stores schedule markers at top-level', () async {
      final offline = OfflineRepositorySupport();
      final repo = WorkoutPlanRepository(offline: offline);
      final created = await repo.create(
        customerId: 'customer-1',
        name: 'Map Plan',
        routine: WorkoutRoutine.empty().copyWith(
          name: 'Map Plan',
          startDate: DateTime(2026, 3, 1),
          currentWeek: 1,
        ),
      );

      final stored = await offline.readLocalEntityById(
        OfflineEntityType.workoutPlan,
        created.id,
      );
      expect(stored?['planData'], isA<Map>());
      expect((stored!['planData'] as Map)['name'], 'Map Plan');
      expect(stored['startDate'], isNotNull);
      expect(stored['currentWeek'], 1);
      expect((stored['planData'] as Map).containsKey('startDate'), isFalse);

      final reloaded = await repo.getById(created.id);
      expect(reloaded, isNotNull);
      expect(reloaded!.routine.name, 'Map Plan');
      expect(reloaded.startDate, DateTime(2026, 3, 1));
      expect(reloaded.routine.startDate, DateTime(2026, 3, 1));
    });

    test('session rewrite promotes legacy nested markers to top-level',
        () async {
      final offline = OfflineRepositorySupport();
      final repo = WorkoutPlanRepository(offline: offline);
      final now = DateTime.now().toIso8601String();
      const planId = 'legacy-session-plan';
      await offline.saveLocalEntity(
        type: OfflineEntityType.workoutPlan,
        id: planId,
        scopeId: 'customer-1',
        payload: <String, dynamic>{
          'id': planId,
          'customerId': 'customer-1',
          'userId': '',
          'name': 'Legacy Session',
          'planData': <String, dynamic>{
            'name': 'Legacy Session',
            'weeks': <dynamic>[],
            'archivedAt': '2026-01-15T00:00:00.000',
            'startDate': '2026-01-01T00:00:00.000',
            'currentWeek': 2,
          },
          'useCustomPdfHeader': false,
          'initialWeekNumber': 1,
          'createdAt': now,
          'updatedAt': now,
          'rowVersion': 1,
        },
        localOnly: false,
      );

      final updated = await repo.setSessionCompleted(
        planId: planId,
        weekIndex: 0,
        dayIndex: 0,
        completed: true,
      );
      expect(isArchivedPlan(updated), isTrue);
      expect(updated.startDate, DateTime(2026, 1, 1));
      expect(updated.currentWeek, 2);
      expect(updated.planDataMap.containsKey('archivedAt'), isFalse);
      expect(updated.planDataMap.containsKey('startDate'), isFalse);

      final stored = await offline.readLocalEntityById(
        OfflineEntityType.workoutPlan,
        planId,
      );
      expect(stored?['archivedAt'], isNotNull);
      expect(stored?['startDate'], isNotNull);
      expect(stored?['currentWeek'], 2);
      expect((stored?['planData'] as Map?)?.containsKey('archivedAt'), isFalse);
    });

    test('legacy String planData markers readable and promoted on update',
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
              '{"name":"Legacy","weeks":[],"archivedAt":"2026-01-15T00:00:00.000","startDate":"2026-01-01T00:00:00.000"}',
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
      expect(loaded.startDate, DateTime(2026, 1, 1));

      final before = await offline.readLocalEntityById(
        OfflineEntityType.workoutPlan,
        planId,
      );
      expect(before?['planData'], isA<String>());

      final updated = await repo.update(
        planId: planId,
        routine: WorkoutRoutine.empty().copyWith(
          name: 'Rewritten',
          startDate: DateTime(2026, 1, 1),
        ),
      );
      expect(updated.routine.name, 'Rewritten');
      expect(isArchivedPlan(updated), isTrue);

      final after = await offline.readLocalEntityById(
        OfflineEntityType.workoutPlan,
        planId,
      );
      expect(after?['planData'], isA<Map>());
      expect((after!['planData'] as Map)['name'], 'Rewritten');
      expect((after['planData'] as Map).containsKey('archivedAt'), isFalse);
      expect(after['archivedAt'], isNotNull);
      expect(after['startDate'], isNotNull);
    });
  });
}

bool storedAfterClear(Map<String, dynamic>? stored) {
  return stored != null && !stored.containsKey('archivedAt');
}
