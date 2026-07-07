import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_plan_query_helpers.dart';

void main() {
  group('dateOnly / dateOnlyIso', () {
    test('strips time component', () {
      final d = DateTime(2024, 6, 15, 14, 30, 45);
      expect(dateOnly(d), DateTime(2024, 6, 15));
      expect(dateOnlyIso(d), '2024-06-15T00:00:00.000');
    });
  });

  group('workoutPlanSortKey', () {
    test('uses startDate from planData when present', () {
      final plan = WorkoutPlanApiModel.fromJson({
        'id': 'p1',
        'customerId': 'c1',
        'userId': 'u1',
        'name': 'Plan',
        'planData': '{"startDate":"2024-03-10T08:00:00.000Z","weeks":[]}',
        'createdAt': '2020-01-01T00:00:00.000',
        'updatedAt': '2025-01-01T00:00:00.000',
        'rowVersion': 1,
      });
      expect(workoutPlanSortKey(plan), DateTime(2024, 3, 10));
    });

    test('falls back to updatedAt when planData has no startDate', () {
      final plan = WorkoutPlanApiModel.fromJson({
        'id': 'p1',
        'customerId': 'c1',
        'userId': 'u1',
        'name': 'Plan',
        'planData': '{"weeks":[]}',
        'createdAt': '2020-01-01T00:00:00.000',
        'updatedAt': '2025-06-20T00:00:00.000',
        'rowVersion': 1,
      });
      expect(workoutPlanSortKey(plan), DateTime(2025, 6, 20));
    });
  });

  group('sortWorkoutPlansByStartDateDesc', () {
    test('orders newest startDate first', () {
      WorkoutPlanApiModel plan(String id, String startDate) =>
          WorkoutPlanApiModel.fromJson({
            'id': id,
            'customerId': 'c1',
            'userId': 'u1',
            'name': id,
            'planData': '{"startDate":"$startDate","weeks":[]}',
            'createdAt': '2020-01-01T00:00:00.000',
            'updatedAt': '2020-01-01T00:00:00.000',
            'rowVersion': 1,
          });

      final plans = [
        plan('old', '2024-01-01T00:00:00.000'),
        plan('new', '2024-06-01T00:00:00.000'),
        plan('mid', '2024-03-01T00:00:00.000'),
      ];
      sortWorkoutPlansByStartDateDesc(plans);
      expect(plans.map((p) => p.id).toList(), ['new', 'mid', 'old']);
    });
  });

  group('cloneWorkoutPlanDataJson', () {
    test('removes archivedAt and completedAt', () {
      const raw =
          '{"weeks":[],"archivedAt":"2024-01-01","completedAt":"2024-02-01"}';
      final cloned = cloneWorkoutPlanDataJson(raw);
      expect(cloned.contains('archivedAt'), isFalse);
      expect(cloned.contains('completedAt'), isFalse);
      expect(cloned.contains('"weeks"'), isTrue);
    });

    test('throws on invalid JSON', () {
      expect(
        () => cloneWorkoutPlanDataJson('not-json'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('planDataToRoutine', () {
    test('parses minimal routine JSON', () {
      const json = '{"weeks":[],"startDate":"2024-01-01T00:00:00.000"}';
      final routine = planDataToRoutine(json);
      expect(routine.weeks, isEmpty);
      expect(routine.startDate, DateTime(2024, 1, 1));
    });
  });

  group('sortSessionExecutionsNewestFirst', () {
    test('orders by completedAt then sessionDate descending', () {
      SessionExecution exec(String key, DateTime date) => SessionExecution(
            sessionKey: key,
            weekIndex: 0,
            dayIndex: 0,
            sessionDate: date,
            status: PlanSessionStatus.completed,
            completedAt: date,
            exercises: const [],
          );

      final sorted = sortSessionExecutionsNewestFirst([
        exec('a', DateTime(2024, 1, 1)),
        exec('b', DateTime(2024, 6, 1)),
        exec('c', DateTime(2024, 3, 1)),
      ]);
      expect(sorted.map((e) => e.sessionKey).toList(), ['b', 'c', 'a']);
    });
  });
}
