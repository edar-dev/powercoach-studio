import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/dashboard/domain/calendar_event_loader.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';

WorkoutPlanApiModel _plan(String planDataJson) {
  final stamp = DateTime(2026, 1, 1);
  return WorkoutPlanApiModel(
    id: 'p1',
    customerId: 'c1',
    userId: 'u1',
    name: 'Strength',
    planData: planDataJson,
    createdAt: stamp,
    updatedAt: stamp,
  );
}

void main() {
  group('planSessionDate', () {
    test('maps week and day offsets from start date', () {
      final date = planSessionDate(
        startDate: DateTime(2026, 5, 1),
        weekIndex: 1,
        dayIndex: 2,
      );
      expect(date, DateTime(2026, 5, 10));
    });
  });

  group('CalendarEventLoader', () {
    test('expands routine days into dated events', () {
      final routine = WorkoutRoutine.empty().copyWith(
        startDate: DateTime(2026, 5, 1),
        weeks: WorkoutRoutine.defaultWeeks(),
      );
      final events = CalendarEventLoader.eventsForPlans(
        plans: [_plan(jsonEncode(routine.toJson()))],
        customerNamesById: const {'c1': 'Anna'},
        rangeStart: DateTime(2026, 5, 1),
        rangeEndExclusive: DateTime(2026, 6, 1),
        unknownClientLabel: '?',
        untitledProgramLabel: 'Untitled',
      );

      expect(events, isNotEmpty);
      expect(events.first.day, DateTime(2026, 5, 1));
      expect(events.first.customerName, 'Anna');
    });

    test('marks completed sessions from payload map', () {
      final routine = WorkoutRoutine.empty().copyWith(
        startDate: DateTime(2026, 5, 1),
        weeks: WorkoutRoutine.defaultWeeks(),
        sessionCompletionByKey: const {'0-0': true},
      );
      final events = CalendarEventLoader.eventsForPlans(
        plans: [_plan(jsonEncode(routine.toJson()))],
        customerNamesById: const {'c1': 'Anna'},
        rangeStart: DateTime(2026, 5, 1),
        rangeEndExclusive: DateTime(2026, 6, 1),
        unknownClientLabel: '?',
        untitledProgramLabel: 'Untitled',
      );

      expect(events.first.status, PlanSessionStatus.completed);
    });
  });
}
