import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/customers/data/models/customer.dart';
import 'package:powercoach_studio/features/dashboard/domain/dashboard_snapshot.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/screens/gym_mode_screen.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

Customer _customer({required String id, required String name}) {
  final t = DateTime(2020, 1, 1);
  return Customer(
    id: id,
    userId: 'coach-1',
    name: name,
    createdAt: t,
    updatedAt: t,
  );
}

WorkoutPlanApiModel _planStartingToday(DateTime today) {
  final routine = WorkoutRoutine.empty().copyWith(
    startDate: today,
    weeks: WorkoutRoutine.defaultWeeks(),
  );
  final t = DateTime(2020, 1, 1);
  return WorkoutPlanApiModel(
    id: 'p1',
    customerId: 'c1',
    userId: 'coach-1',
    name: 'Strength block',
    planData: jsonEncode(routine.toJson()),
    createdAt: t,
    updatedAt: today,
  );
}

Future<void> _pump(WidgetTester tester, Widget home) => tester.pumpWidget(
  MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: home,
  ),
);

void main() {
  group('GymModeScreen', () {
    testWidgets('shows empty state when nothing is scheduled today', (
      tester,
    ) async {
      await _pump(
        tester,
        GymModeScreen(
          loadSnapshot: (unknown) async => DashboardSnapshot(
            clientCount: 0,
            activePrograms: 0,
            weeklyUpdates: 0,
            todayItems: const [],
            stalePlans: const [],
            customersWithoutPlan: const [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gym mode'), findsOneWidget);
      expect(
        find.text('No sessions scheduled for today.'),
        findsOneWidget,
      );
    });

    testWidgets('lists today items with client and program', (tester) async {
      final now = DateTime(2026, 6, 15, 9);
      final snap = buildDashboardSnapshot(
        customers: [_customer(id: 'c1', name: 'Anna Bianchi')],
        plans: [_planStartingToday(DateTime(2026, 6, 15))],
        now: now,
        unknownClientLabel: '?',
        untitledWorkoutLabel: 'Untitled',
      );
      expect(snap.todayItems, hasLength(1));

      await _pump(
        tester,
        GymModeScreen(loadSnapshot: (unknown) async => snap),
      );
      await tester.pumpAndSettle();

      expect(find.text('Anna Bianchi'), findsOneWidget);
      expect(find.textContaining('Strength block'), findsOneWidget);
    });
  });
}
