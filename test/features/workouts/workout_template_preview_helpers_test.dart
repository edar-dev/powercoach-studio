import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_template_preview_helpers.dart';

void main() {
  group('parseTemplatePreviewWeeks', () {
    test('returns capped preview structure from plan data', () {
      final planData = jsonEncode({
        'weeks': [
          {
            'name': 'Week 1',
            'days': [
              {
                'name': 'Day A',
                'exercises': [
                  {'name': 'Squat'},
                  {'name': 'Bench'},
                  {'name': 'Row'},
                  {'name': 'Curl'},
                ],
              },
            ],
          },
        ],
      });

      final weeks = parseTemplatePreviewWeeks(
        planData,
        maxExercisesPerDay: 2,
      );

      expect(weeks, hasLength(1));
      expect(weeks.single.name, 'Week 1');
      expect(weeks.single.days.single.exercises, ['Squat', 'Bench']);
      expect(weeks.single.days.single.remainingExercises, 2);
    });
  });
}
