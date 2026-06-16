import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/features/customers/data/customer_repository.dart';
import 'package:powercoach_studio/features/customers/data/models/customer.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';
import 'package:powercoach_studio/features/dashboard/domain/session_detail_loader.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PathProviderPlatform.instance =
        FakePathProviderPlatform(prefix: 'powercoach_session_detail_');
  });

  setUp(() async {
    await OfflineLocalStore.instance.clear();
  });

  group('SessionDetailLoader', () {
    test('loads exercise count and customer name from repositories', () async {
      final customerRepo = CustomerRepository();
      final planRepo = WorkoutPlanRepository();
      final now = DateTime(2026, 5, 1);

      final customer = await customerRepo.create(
        Customer(
          id: '',
          userId: '__legacy__',
          name: 'Marco Rossi',
          email: 'marco@test.local',
          phone: null,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final routine = WorkoutRoutine.empty().copyWith(
        startDate: DateTime(2026, 5, 1),
        weeks: [
          const Week(
            id: 'w1',
            name: 'Week 1',
            days: [
              Day(
                id: 'd1',
                name: 'Day A',
                exercises: [
                  Exercise(
                    id: 'e1',
                    name: 'Squat',
                    sets: '3',
                    reps: '8',
                    rpe: '',
                  ),
                  Exercise(
                    id: 'e2',
                    name: 'Bench',
                    sets: '3',
                    reps: '10',
                    rpe: '',
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      final plan = await planRepo.create(
        customerId: customer.id,
        name: 'Strength block',
        planDataJson: jsonEncode(routine.toJson()),
        phase: 'Hypertrophy',
      );

      final loader = SessionDetailLoader(
        workoutPlanRepository: planRepo,
        customerRepository: customerRepo,
      );

      final snapshot = await loader.load(
        customerId: customer.id,
        planId: plan.id,
        weekIndex: 0,
        dayIndex: 0,
        unknownClientLabel: '?',
        untitledProgramLabel: 'Untitled',
      );

      expect(snapshot, isNotNull);
      expect(snapshot!.exerciseCount, 2);
      expect(snapshot.phase, 'Hypertrophy');
      expect(snapshot.event.customerName, 'Marco Rossi');
      expect(snapshot.event.programName, 'Strength block');
      expect(snapshot.event.sessionLabel, 'Day A');
      expect(snapshot.event.status, PlanSessionStatus.planned);
    });

    test('returns null for invalid week or day index', () async {
      final planRepo = WorkoutPlanRepository();
      final plan = await planRepo.create(
        customerId: 'customer-1',
        name: 'Plan',
        planDataJson: jsonEncode(WorkoutRoutine.empty().toJson()),
      );
      final loader = SessionDetailLoader(workoutPlanRepository: planRepo);

      expect(
        await loader.load(
          customerId: 'customer-1',
          planId: plan.id,
          weekIndex: 99,
          dayIndex: 0,
          unknownClientLabel: '?',
          untitledProgramLabel: 'Untitled',
        ),
        isNull,
      );
      expect(
        await loader.load(
          customerId: 'customer-1',
          planId: plan.id,
          weekIndex: 0,
          dayIndex: 99,
          unknownClientLabel: '?',
          untitledProgramLabel: 'Untitled',
        ),
        isNull,
      );
    });

    test('uses moved override date when present', () async {
      final planRepo = WorkoutPlanRepository();
      final routine = WorkoutRoutine.empty().copyWith(
        startDate: DateTime(2026, 5, 1),
        weeks: WorkoutRoutine.defaultWeeks(),
        sessionOverrides: {
          '0-0-2026-05-01': SessionOverride.moved(DateTime(2026, 5, 3)),
        },
      );
      final plan = await planRepo.create(
        customerId: 'customer-1',
        name: 'Plan',
        planDataJson: jsonEncode(routine.toJson()),
      );
      final loader = SessionDetailLoader(workoutPlanRepository: planRepo);

      final snapshot = await loader.load(
        customerId: 'customer-1',
        planId: plan.id,
        weekIndex: 0,
        dayIndex: 0,
        unknownClientLabel: '?',
        untitledProgramLabel: 'Untitled',
      );

      expect(snapshot, isNotNull);
      expect(snapshot!.event.day, DateTime(2026, 5, 3));
    });
  });
}
