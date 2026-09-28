import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_plan_list_helpers.dart';

WorkoutPlanApiModel _plan({
  required String id,
  required String name,
  String? startDate,
  String? endDate,
  DateTime? updatedAt,
  String? archivedAt,
}) {
  final routine = <String, dynamic>{
    'name': name,
    'mobilitySections': [],
    'mobilityItems': [],
    'weeks': [],
    if (startDate != null) 'startDate': startDate,
    if (endDate != null) 'endDate': endDate,
    if (archivedAt != null) 'archivedAt': archivedAt,
  };
  final now = DateTime(2026, 6, 15);
  return WorkoutPlanApiModel(
    id: id,
    customerId: 'c1',
    userId: 'u1',
    name: name,
    planData: jsonEncode(routine),
    createdAt: now,
    updatedAt: updatedAt ?? now,
  );
}

void main() {
  final today = DateTime(2026, 6, 15);

  group('filterWorkoutPlans', () {
    test('archived filter returns only archived plans', () {
      final plans = [
        _plan(id: '1', name: 'Active', startDate: '2026-06-01'),
        _plan(
          id: '2',
          name: 'Archived',
          archivedAt: '2026-05-15T00:00:00.000',
        ),
      ];
      final filtered = filterWorkoutPlans(plans, WorkoutPlanFilter.archived);
      expect(filtered.map((p) => p.id), ['2']);
    });

    test('all filter excludes archived plans', () {
      final plans = [
        _plan(id: '1', name: 'Active', startDate: '2026-06-01'),
        _plan(
          id: '2',
          name: 'Archived',
          archivedAt: '2026-05-15T00:00:00.000',
        ),
      ];
      final filtered = filterWorkoutPlans(plans, WorkoutPlanFilter.all);
      expect(filtered.map((p) => p.id), ['1']);
    });

    test('isActivePlan helper still classifies date windows', () {
      final active = _plan(
        id: '1',
        name: 'Active',
        startDate: '2026-06-01',
        endDate: '2026-06-30',
      );
      final ended = _plan(
        id: '2',
        name: 'Ended',
        startDate: '2026-05-01',
        endDate: '2026-05-31',
      );
      expect(isActivePlan(active, now: today), isTrue);
      expect(isActivePlan(ended, now: today), isFalse);
      expect(isEndedPlan(ended, now: today), isTrue);
    });
  });

  group('sortWorkoutPlans', () {
    test('startDateDesc puts newest start first', () {
      final plans = [
        _plan(id: '1', name: 'A', startDate: '2026-05-01'),
        _plan(id: '2', name: 'B', startDate: '2026-07-01'),
      ];
      final sorted = sortWorkoutPlans(plans, WorkoutPlanSort.startDateDesc);
      expect(sorted.map((p) => p.id), ['2', '1']);
    });

    test('nameAsc sorts alphabetically', () {
      final plans = [
        _plan(id: '1', name: 'Zeta'),
        _plan(id: '2', name: 'Alpha'),
      ];
      final sorted = sortWorkoutPlans(plans, WorkoutPlanSort.nameAsc);
      expect(sorted.map((p) => p.name), ['Alpha', 'Zeta']);
    });
  });

  group('searchWorkoutPlans', () {
    test('matches name and phase', () {
      final plans = [
        _plan(id: '1', name: 'Hypertrophy block'),
        WorkoutPlanApiModel(
          id: '2',
          customerId: 'c1',
          userId: 'u1',
          name: 'Other',
          phase: 'Strength',
          planData: jsonEncode({
            'name': 'Other',
            'mobilitySections': [],
            'mobilityItems': [],
            'weeks': [],
          }),
          createdAt: today,
          updatedAt: today,
        ),
      ];
      expect(searchWorkoutPlans(plans, 'hyper').map((p) => p.id), ['1']);
      expect(searchWorkoutPlans(plans, 'strength').map((p) => p.id), ['2']);
    });
  });
}
