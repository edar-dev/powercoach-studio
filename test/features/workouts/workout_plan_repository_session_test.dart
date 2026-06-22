import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PathProviderPlatform.instance = FakePathProviderPlatform(
      prefix: 'powercoach_sessions_',
    );
  });

  setUp(() async {
    await OfflineLocalStore.instance.clear();
  });

  group('WorkoutPlanRepository session APIs', () {
    test('set and remove session occurrence override', () async {
      final repo = WorkoutPlanRepository();
      final created = await repo.create(
        customerId: 'customer-1',
        name: 'Plan A',
        planDataJson: jsonEncode(WorkoutRoutine.empty().toJson()),
      );

      final movedTo = DateTime(2026, 6, 20);
      final updated = await repo.setSessionOccurrenceOverride(
        planId: created.id,
        weekIndex: 0,
        dayIndex: 1,
        originalDay: DateTime(2026, 6, 10),
        override: SessionOverride.moved(movedTo),
      );
      final withOverride = jsonDecode(updated.planData) as Map<String, dynamic>;
      final overrides =
          withOverride['sessionOverrides'] as Map<String, dynamic>;
      expect(overrides, hasLength(1));

      final removed = await repo.removeSessionOccurrenceOverride(
        planId: created.id,
        weekIndex: 0,
        dayIndex: 1,
        originalDay: DateTime(2026, 6, 10),
      );
      final withoutOverride =
          jsonDecode(removed.planData) as Map<String, dynamic>;
      expect(withoutOverride.containsKey('sessionOverrides'), isFalse);
    });

    test('upsert, list, get and delete session execution', () async {
      final repo = WorkoutPlanRepository();
      final created = await repo.create(
        customerId: 'customer-1',
        name: 'Plan B',
        planDataJson: jsonEncode(WorkoutRoutine.empty().toJson()),
      );
      final execution = SessionExecution(
        sessionKey: '0-0',
        weekIndex: 0,
        dayIndex: 0,
        sessionDate: DateTime(2026, 6, 10),
        completedAt: DateTime(2026, 6, 10, 18),
        status: PlanSessionStatus.completed,
        notes: 'Done',
      );

      await repo.upsertSessionExecution(
        planId: created.id,
        execution: execution,
      );

      final fetched = await repo.getSessionExecution(
        planId: created.id,
        sessionKey: '0-0',
      );
      expect(fetched?.notes, 'Done');
      expect(fetched?.status, PlanSessionStatus.completed);

      final listed = await repo.listSessionExecutionsForPlan(created.id);
      expect(listed, hasLength(1));
      expect(listed.single.sessionKey, '0-0');

      await repo.deleteSessionExecution(planId: created.id, sessionKey: '0-0');
      expect(
        await repo.getSessionExecution(planId: created.id, sessionKey: '0-0'),
        isNull,
      );
    });
  });
}
