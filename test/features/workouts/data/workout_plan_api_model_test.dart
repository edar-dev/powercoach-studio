import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';

WorkoutPlanApiModel _model(
  dynamic planData, {
  Map<String, dynamic> topLevel = const {},
}) {
  return WorkoutPlanApiModel.fromJson({
    'id': 'p1',
    'customerId': 'c1',
    'userId': 'u1',
    'name': 'Plan',
    'planData': planData,
    'createdAt': '2026-01-01T00:00:00.000',
    'updatedAt': '2026-01-02T00:00:00.000',
    'rowVersion': 1,
    ...topLevel,
  });
}

void main() {
  group('WorkoutPlanApiModel typed accessors', () {
    test('routine parses weeks from planData and schedule from top-level', () {
      final plan = _model(
        jsonEncode({
          'name': 'Strength',
          'weeks': [],
        }),
        topLevel: {
          'startDate': '2026-03-10T00:00:00.000',
        },
      );

      expect(plan.routine.name, 'Strength');
      expect(plan.routine.weeks, isEmpty);
      expect(plan.startDate, DateTime(2026, 3, 10));
      expect(plan.routine.startDate, DateTime(2026, 3, 10));
    });

    test('legacy schedule inside planData is normalized on read', () {
      final plan = _model(
        jsonEncode({
          'name': 'Legacy',
          'weeks': [],
          'startDate': '2026-03-10T00:00:00.000',
          'currentWeek': 2,
        }),
      );

      expect(plan.startDate, DateTime(2026, 3, 10));
      expect(plan.currentWeek, 2);
      expect(plan.routine.startDate, DateTime(2026, 3, 10));
      expect(plan.routine.currentWeek, 2);
    });

    test('top-level schedule wins over nested planData', () {
      final plan = _model(
        jsonEncode({
          'weeks': [],
          'startDate': '2026-01-01T00:00:00.000',
          'currentWeek': 1,
        }),
        topLevel: {
          'startDate': '2026-04-01T00:00:00.000',
          'currentWeek': 4,
        },
      );

      expect(plan.startDate, DateTime(2026, 4, 1));
      expect(plan.currentWeek, 4);
      expect(plan.routine.startDate, DateTime(2026, 4, 1));
      expect(plan.routine.currentWeek, 4);
    });

    test('archivedAt and completedAt parse top-level lifecycle keys', () {
      final plan = _model(
        jsonEncode({'weeks': []}),
        topLevel: {
          'archivedAt': '2026-05-15T12:00:00.000',
          'completedAt': '2026-06-01T08:30:00.000',
        },
      );

      expect(plan.archivedAt, DateTime(2026, 5, 15, 12));
      expect(plan.completedAt, DateTime(2026, 6, 1, 8, 30));
      expect(plan.isArchived, isTrue);
    });

    test('legacy lifecycle inside planData is normalized on read', () {
      final plan = _model(
        jsonEncode({
          'weeks': [],
          'archivedAt': '2026-05-15T12:00:00.000',
          'completedAt': '2026-06-01T08:30:00.000',
        }),
      );

      expect(plan.archivedAt, DateTime(2026, 5, 15, 12));
      expect(plan.completedAt, DateTime(2026, 6, 1, 8, 30));
      expect(plan.isArchived, isTrue);
    });

    test('top-level lifecycle wins over nested planData', () {
      final plan = _model(
        jsonEncode({
          'weeks': [],
          'archivedAt': '2026-01-01T00:00:00.000',
        }),
        topLevel: {
          'archivedAt': '2026-05-15T12:00:00.000',
        },
      );

      expect(plan.archivedAt, DateTime(2026, 5, 15, 12));
    });

    test('lifecycle getters return null when keys absent', () {
      final plan = _model(jsonEncode({'weeks': []}));

      expect(plan.archivedAt, isNull);
      expect(plan.completedAt, isNull);
      expect(plan.isArchived, isFalse);
    });

    test('planDataMap returns empty map for invalid JSON', () {
      final plan = _model('{not-json');

      expect(plan.planDataMap, isEmpty);
      expect(plan.archivedAt, isNull);
      expect(plan.completedAt, isNull);
      expect(plan.isArchived, isFalse);
    });

    test('routine throws on invalid JSON', () {
      final plan = _model('{not-json');

      expect(() => plan.routine, throwsA(isA<FormatException>()));
    });

    test('fromJson keeps String planData as String', () {
      const raw = '{"weeks":[]}';
      final plan = _model(raw);

      expect(plan.planData, raw);
      expect(plan.planData, isA<String>());
    });

    test('fromJson normalizes Map planData into String', () {
      final plan = _model(<String, dynamic>{
        'weeks': <dynamic>[],
        'name': 'MapPlan',
      });

      expect(plan.planData, isA<String>());
      final decoded = jsonDecode(plan.planData) as Map<String, dynamic>;
      expect(decoded['name'], 'MapPlan');
      expect(plan.routine.name, 'MapPlan');
    });

    test('fromJson maps null/unsupported planData to empty object string', () {
      expect(_model(null).planData, '{}');
      expect(_model(42).planData, '{}');
    });
  });
}
