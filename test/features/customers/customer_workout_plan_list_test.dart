import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/customer_workout_plan_filter_bar.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/customer_workout_plan_list_tile.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_plan_list_helpers.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_plan_lifecycle_pill.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  WorkoutPlanApiModel buildPlan({
    String name = 'Plan A',
    String? archivedAt,
  }) {
    final now = DateTime.now();
    final routine = WorkoutRoutine.empty().copyWith(
      startDate: DateTime(now.year, now.month, now.day),
      weeks: const [
        Week(
          id: 'w1',
          name: 'Week 1',
          days: [
            Day(id: 'd1', name: 'Day A', exercises: []),
          ],
        ),
      ],
    );
    final planData = jsonEncode(routine.toJson());
    return WorkoutPlanApiModel.fromJson({
      'id': 'p1',
      'customerId': 'c1',
      'userId': 'u1',
      'name': name,
      'planData': planData,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'archivedAt': ?archivedAt,
    });
  }

  group('WorkoutPlanLifecyclePill', () {
    testWidgets('hides chrome for non-archived plans', (tester) async {
      await tester.pumpWidget(
        wrap(WorkoutPlanLifecyclePill(plan: buildPlan())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Active'), findsNothing);
      expect(find.text('Archived'), findsNothing);
      expect(find.text('Draft'), findsNothing);
    });

    testWidgets('shows archived status only', (tester) async {
      await tester.pumpWidget(
        wrap(
          WorkoutPlanLifecyclePill(
            plan: buildPlan(archivedAt: '2026-05-15T00:00:00.000'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Archived'), findsOneWidget);
    });
  });

  group('CustomerWorkoutPlanFilterBar', () {
    testWidgets('renders All and Archived chips only by default', (
      tester,
    ) async {
      WorkoutPlanFilter? selected;
      await tester.pumpWidget(
        wrap(
          CustomerWorkoutPlanFilterBar(
            selectedFilter: WorkoutPlanFilter.all,
            onSearchQueryChanged: (_) {},
            onFilterChanged: (filter) => selected = filter,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Archived'), findsOneWidget);
      expect(find.text('Active'), findsNothing);
      expect(find.text('Scheduled'), findsNothing);

      await tester.tap(find.text('Archived'));
      await tester.pump();
      expect(selected, WorkoutPlanFilter.archived);
    });
  });

  group('CustomerWorkoutPlanListTile', () {
    testWidgets('shows plan title and overflow menu', (tester) async {
      var menuOpened = false;
      await tester.pumpWidget(
        wrap(
          CustomerWorkoutPlanListTile(
            title: 'Upper A',
            subtitle: 'Updated just now',
            plan: buildPlan(),
            localeName: 'en',
            onTap: () {},
            onDelete: () => menuOpened = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Upper A'), findsOneWidget);
      expect(find.text('Updated just now'), findsOneWidget);
      expect(find.byType(WorkoutPlanLifecyclePill), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete workout'));
      await tester.pump();
      expect(menuOpened, isTrue);
    });
  });
}
