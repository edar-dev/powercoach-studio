import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/plan_schedule_strip.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  WorkoutPlanApiModel buildPlan() {
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
    return WorkoutPlanApiModel(
      id: 'p1',
      customerId: 'c1',
      userId: 'u1',
      name: 'Plan A',
      planData: jsonEncode(routine.toJson()),
      createdAt: now,
      updatedAt: now,
    );
  }

  testWidgets('tapping and long-pressing chip triggers callbacks', (
    tester,
  ) async {
    PlanCalendarEvent? tapped;
    PlanCalendarEvent? longPressed;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PlanScheduleStrip(
            plan: buildPlan(),
            localeName: 'en',
            onSessionTap: (event) => tapped = event,
            onSessionLongPress: (event) async => longPressed = event,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    final chip = find.byType(InputChip).first;
    expect(chip, findsOneWidget);

    await tester.tap(chip);
    await tester.pump();
    expect(tapped, isNotNull);
    expect(tapped!.weekIndex, 0);
    expect(tapped!.dayIndex, 0);

    await tester.longPress(chip);
    await tester.pump();
    expect(longPressed, isNotNull);
    expect(longPressed!.status, PlanSessionStatus.planned);
  });
}
