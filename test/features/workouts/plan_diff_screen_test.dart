import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/screens/plan_diff_screen.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';

/// Pumps until [finder] resolves or [timeout] elapses.
///
/// [PlanDiffScreen] loads data from Drift's background-isolate executor,
/// which performs real (non-fake-clock) async I/O. While that load is
/// pending, the loading spinner's indeterminate animation means
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
      prefix: 'powercoach_plan_diff_',
    );
  });

  setUp(() async {
    await OfflineLocalStore.instance.clear();
  });

  Future<GoRouter> pumpPlanDiff(
    WidgetTester tester,
    String location,
    Finder settledFinder,
  ) async {
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/plans/diff',
          builder: (context, state) => const PlanDiffScreen(),
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
    await pumpUntilFound(tester, settledFinder);
    await tester.pump();
    return router;
  }

  WorkoutRoutine routineWithDay(Day day) => WorkoutRoutine.empty().copyWith(
    weeks: [Week(id: 'w1', name: 'Week 1', days: [day])],
  );

  testWidgets('shows a picker when planIdB is missing, then renders the diff', (
    tester,
  ) async {
    final planRepo = WorkoutPlanRepository();
    late WorkoutPlanApiModel planA;
    await tester.runAsync(() async {
      planA = await planRepo.create(
        customerId: 'cust-1',
        name: 'Plan A',
        planDataJson: jsonEncode(
          routineWithDay(
            const Day(
              id: 'd1',
              name: 'Day A',
              exercises: [
                Exercise(id: 'e1', name: 'Squat', sets: '3', reps: '5', rpe: ''),
              ],
            ),
          ).toJson(),
        ),
      );
      await planRepo.create(
        customerId: 'cust-1',
        name: 'Plan B',
        planDataJson: jsonEncode(
          routineWithDay(
            const Day(
              id: 'd1',
              name: 'Day A',
              exercises: [
                Exercise(id: 'e1', name: 'Squat', sets: '3', reps: '5', rpe: ''),
                Exercise(id: 'e2', name: 'Bench', sets: '3', reps: '8', rpe: ''),
              ],
            ),
          ).toJson(),
        ),
      );
    });

    await pumpPlanDiff(
      tester,
      planDiffPath(customerId: 'cust-1', planIdA: planA.id),
      find.text('Choose a plan to compare'),
    );

    expect(find.text('Choose a plan to compare'), findsOneWidget);
    expect(find.text('Plan B'), findsOneWidget);

    await tester.tap(find.text('Plan B'));
    await tester.pump();

    expect(find.text('1 exercises added'), findsOneWidget);
    expect(find.text('Bench'), findsOneWidget);
  });

  testWidgets('renders diff directly when planIdB is provided', (
    tester,
  ) async {
    final planRepo = WorkoutPlanRepository();
    late WorkoutPlanApiModel planA;
    late WorkoutPlanApiModel planB;
    await tester.runAsync(() async {
      planA = await planRepo.create(
        customerId: 'cust-2',
        name: 'Plan A',
        planDataJson: jsonEncode(
          routineWithDay(
            const Day(
              id: 'd1',
              name: 'Day A',
              exercises: [],
              coachingNote: 'Old note',
            ),
          ).toJson(),
        ),
      );
      planB = await planRepo.create(
        customerId: 'cust-2',
        name: 'Plan B',
        planDataJson: jsonEncode(
          routineWithDay(
            const Day(
              id: 'd1',
              name: 'Day A',
              exercises: [],
              coachingNote: 'New note',
            ),
          ).toJson(),
        ),
      );
    });

    await pumpPlanDiff(
      tester,
      planDiffPath(customerId: 'cust-2', planIdA: planA.id, planIdB: planB.id),
      find.text('Coaching note'),
    );

    expect(find.text('Coaching note'), findsOneWidget);
    expect(find.textContaining('Old note'), findsOneWidget);
    expect(find.textContaining('New note'), findsOneWidget);
  });
}
