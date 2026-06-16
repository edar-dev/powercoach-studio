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

    test('uses scheduled weekday when present', () {
      final date = planSessionDate(
        startDate: DateTime(2026, 5, 1), // Friday
        weekIndex: 0,
        dayIndex: 0,
        scheduledWeekday: DateTime.monday,
      );
      expect(date, DateTime(2026, 5, 4));
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

    test('supports flexible weekday scheduling and keeps legacy behavior', () {
      final routine = WorkoutRoutine.empty().copyWith(
        startDate: DateTime(2026, 5, 1), // Friday
        weeks: [
          const Week(
            id: 'w1',
            name: 'Week 1',
            days: [
              Day(id: 'd1', name: 'Legacy day', exercises: []),
              Day(
                id: 'd2',
                name: 'Thursday day',
                exercises: [],
                scheduledWeekday: DateTime.thursday,
              ),
            ],
          ),
        ],
      );
      final events = CalendarEventLoader.eventsForPlans(
        plans: [_plan(jsonEncode(routine.toJson()))],
        customerNamesById: const {'c1': 'Anna'},
        rangeStart: DateTime(2026, 5, 1),
        rangeEndExclusive: DateTime(2026, 5, 16),
        unknownClientLabel: '?',
        untitledProgramLabel: 'Untitled',
      );

      expect(events, hasLength(2));
      expect(events.first.sessionLabel, 'Legacy day');
      expect(
        events.first.day,
        DateTime(2026, 5, 1),
      ); // v1 fallback (dayIndex 0)
      expect(events.last.sessionLabel, 'Thursday day');
      expect(events.last.day, DateTime(2026, 5, 7)); // aligned weekday
    });

    test('moves one occurrence to a specific date', () {
      final routine = WorkoutRoutine.empty().copyWith(
        startDate: DateTime(2026, 5, 1),
        weeks: WorkoutRoutine.defaultWeeks(),
        sessionOverrides: {
          '0-0-2026-05-01': SessionOverride.moved(DateTime(2026, 5, 3)),
        },
      );
      final events = CalendarEventLoader.eventsForPlans(
        plans: [_plan(jsonEncode(routine.toJson()))],
        customerNamesById: const {'c1': 'Anna'},
        rangeStart: DateTime(2026, 5, 1),
        rangeEndExclusive: DateTime(2026, 5, 10),
        unknownClientLabel: '?',
        untitledProgramLabel: 'Untitled',
      );
      expect(events, hasLength(1));
      expect(events.first.day, DateTime(2026, 5, 3));
      expect(events.first.originalDay, DateTime(2026, 5, 1));
    });

    test('skips one occurrence when override is skipped', () {
      final routine = WorkoutRoutine.empty().copyWith(
        startDate: DateTime(2026, 5, 1),
        weeks: WorkoutRoutine.defaultWeeks(),
        sessionOverrides: {'0-0-2026-05-01': const SessionOverride.skipped()},
      );
      final events = CalendarEventLoader.eventsForPlans(
        plans: [_plan(jsonEncode(routine.toJson()))],
        customerNamesById: const {'c1': 'Anna'},
        rangeStart: DateTime(2026, 5, 1),
        rangeEndExclusive: DateTime(2026, 5, 10),
        unknownClientLabel: '?',
        untitledProgramLabel: 'Untitled',
      );
      expect(events, isEmpty);
    });
  });
}
