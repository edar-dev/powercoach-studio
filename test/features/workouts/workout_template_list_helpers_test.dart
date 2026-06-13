import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_template_list_helpers.dart';

WorkoutPlanApiModel _template({
  required String id,
  required String name,
  String? phase,
  String? tags,
  required List<Map<String, dynamic>> weeks,
  DateTime? updatedAt,
}) {
  final now = DateTime(2026, 6, 15);
  return WorkoutPlanApiModel(
    id: id,
    customerId: '__template__',
    userId: 'u1',
    name: name,
    phase: phase,
    tags: tags,
    planData: jsonEncode({
      'name': name,
      'mobilitySections': [],
      'mobilityItems': [],
      'weeks': weeks,
    }),
    createdAt: now,
    updatedAt: updatedAt ?? now,
  );
}

void main() {
  group('summarizeTemplate', () {
    test('counts weeks days and exercises', () {
      final plan = _template(
        id: 't1',
        name: 'Template A',
        phase: 'Hypertrophy',
        weeks: [
          {
            'id': 'w1',
            'name': 'Week 1',
            'days': [
              {
                'id': 'd1',
                'name': 'Day 1',
                'exercises': [
                  {'id': 'e1', 'name': 'Squat'},
                  {'id': 'e2', 'name': 'Bench'},
                ],
              },
              {
                'id': 'd2',
                'name': 'Day 2',
                'exercises': [
                  {'id': 'e3', 'name': 'Deadlift'},
                ],
              },
            ],
          },
          {
            'id': 'w2',
            'name': 'Week 2',
            'days': [
              {
                'id': 'd3',
                'name': 'Day 3',
                'exercises': [
                  {'id': 'e4', 'name': 'Pull-up'},
                ],
              },
            ],
          },
        ],
      );

      final summary = summarizeTemplate(plan);
      expect(summary.weekCount, 2);
      expect(summary.dayCount, 3);
      expect(summary.exerciseCount, 4);
      expect(summary.phase, 'Hypertrophy');
    });
  });

  group('searchTemplates', () {
    final templates = [
      _template(
        id: '1',
        name: 'Upper Blast',
        phase: 'Hypertrophy',
        tags: 'upper, shoulder',
        weeks: const [],
      ),
      _template(
        id: '2',
        name: 'Lower Power',
        phase: 'Strength',
        tags: 'lower, squat',
        weeks: const [],
      ),
    ];

    test('matches by phase', () {
      final result = searchTemplates(templates, 'hypertrophy');
      expect(result.map((e) => e.id), ['1']);
    });

    test('matches by tags', () {
      final result = searchTemplates(templates, 'squat');
      expect(result.map((e) => e.id), ['2']);
    });
  });
}
