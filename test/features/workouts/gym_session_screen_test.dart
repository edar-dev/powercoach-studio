import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/features/customers/data/customer_repository.dart';
import 'package:powercoach_studio/features/customers/data/models/customer.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution_service.dart';
import 'package:powercoach_studio/features/workouts/presentation/screens/gym_session_screen.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';

/// Pumps until [finder] resolves or [timeout] elapses.
///
/// The screens under test load data from Drift's background-isolate
/// executor, which performs real (non-fake-clock) async I/O. While that
/// load is pending, the loading spinner's indeterminate animation means
/// `pumpAndSettle()` never settles — so this polls with real delays
/// (via `runAsync`) instead.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(end)) {
      throw TestFailure('pumpUntilFound: timed out waiting for $finder');
    }
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PathProviderPlatform.instance = FakePathProviderPlatform(
      prefix: 'powercoach_gym_session_',
    );
  });

  setUp(() async {
    await OfflineLocalStore.instance.clear();
  });

  testWidgets(
    'GymSessionScreen saves a completed session via PlanSessionStatusService',
    (tester) async {
      final customerRepo = CustomerRepository();
      final planRepo = WorkoutPlanRepository();
      final now = DateTime(2026, 6, 15);

      // Drift's background-isolate executor performs real (non-fake-clock)
      // async I/O — run all DB-touching steps via `runAsync` so the real
      // event loop can actually complete them instead of hanging under the
      // widget test's FakeAsync zone.
      late Customer customer;
      late WorkoutPlanApiModel plan;
      await tester.runAsync(() async {
        customer = await customerRepo.create(
          Customer(
            id: '',
            userId: '__legacy__',
            name: 'Marco Rossi',
            email: null,
            phone: null,
            createdAt: now,
            updatedAt: now,
          ),
        );

        final routine = WorkoutRoutine.empty().copyWith(
          startDate: now,
          weeks: [
            Week(
              id: 'w1',
              name: 'Week 1',
              days: [
                const Day(
                  id: 'd1',
                  name: 'Day A',
                  coachingNote: 'Focus on bracing before the squat.',
                  exercises: [
                    Exercise(
                      id: 'e1',
                      name: 'Squat',
                      sets: '3',
                      reps: '5',
                      rpe: '100kg',
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        plan = await planRepo.create(
          customerId: customer.id,
          name: 'Strength block',
          planDataJson: jsonEncode(routine.toJson()),
        );
      });

      final router = GoRouter(
        initialLocation: gymSessionPath(
          customerId: customer.id,
          planId: plan.id,
          weekIndex: 0,
          dayIndex: 0,
          date: now,
        ),
        routes: [
          GoRoute(
            path: '/gym/session',
            builder: (context, state) => const GymSessionScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await pumpUntilFound(tester, find.text('Marco Rossi'));
      await tester.pump();

      expect(find.text('Marco Rossi'), findsOneWidget);
      expect(
        find.text('Focus on bracing before the squat.'),
        findsOneWidget,
      );
      expect(find.text('Squat'), findsOneWidget);

      await tester.ensureVisible(find.text('Save & complete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save & complete'));
      await tester.pump();
      await pumpUntilFound(tester, find.text('Session saved'));

      final executionService = SessionExecutionService(repository: planRepo);
      SessionExecution? saved;
      await tester.runAsync(() async {
        saved = await executionService.get(
          planId: plan.id,
          sessionKey: WorkoutRoutine.sessionKey(0, 0),
        );
      });
      expect(saved, isNotNull);
      expect(saved!.status, PlanSessionStatus.completed);
      expect(saved!.exercises.single.exerciseId, 'e1');
    },
  );
}
