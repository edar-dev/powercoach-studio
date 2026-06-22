import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_routine_plan_encoder.dart';

void main() {
  group('encodeWorkoutRoutinePlanData', () {
    test('preserves lifecycle markers from existing plan data', () {
      final routine = WorkoutRoutine.empty().copyWith(name: 'Updated');
      final existing = jsonEncode({
        ...WorkoutRoutine.empty().toJson(),
        'archivedAt': '2026-06-01T00:00:00.000',
        'completedAt': '2026-06-02T00:00:00.000',
      });

      final encoded =
          jsonDecode(
                encodeWorkoutRoutinePlanData(
                  routine,
                  existingPlanData: existing,
                ),
              )
              as Map<String, dynamic>;

      expect(encoded['name'], 'Updated');
      expect(encoded['archivedAt'], '2026-06-01T00:00:00.000');
      expect(encoded['completedAt'], '2026-06-02T00:00:00.000');
    });

    test('ignores malformed existing plan data', () {
      final routine = WorkoutRoutine.empty().copyWith(name: 'Safe');

      final encoded =
          jsonDecode(
                encodeWorkoutRoutinePlanData(
                  routine,
                  existingPlanData: '{bad-json',
                ),
              )
              as Map<String, dynamic>;

      expect(encoded['name'], 'Safe');
      expect(encoded.containsKey('archivedAt'), isFalse);
      expect(encoded.containsKey('completedAt'), isFalse);
    });

    test('does not invent lifecycle markers when absent', () {
      final routine = WorkoutRoutine.empty();

      final encoded =
          jsonDecode(
                encodeWorkoutRoutinePlanData(
                  routine,
                  existingPlanData: jsonEncode(routine.toJson()),
                ),
              )
              as Map<String, dynamic>;

      expect(encoded.containsKey('archivedAt'), isFalse);
      expect(encoded.containsKey('completedAt'), isFalse);
    });
  });
}
