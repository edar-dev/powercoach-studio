import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_routine_plan_encoder.dart';

void main() {
  group('normalizePlanDataToMap', () {
    test('accepts Map and String JSON object', () {
      expect(
        normalizePlanDataToMap({'weeks': [], 'name': 'A'}),
        {'weeks': [], 'name': 'A'},
      );
      expect(
        normalizePlanDataToMap('{"weeks":[],"name":"B"}'),
        {'weeks': [], 'name': 'B'},
      );
    });

    test('returns null for invalid or unsupported shapes', () {
      expect(normalizePlanDataToMap(null), isNull);
      expect(normalizePlanDataToMap(''), isNull);
      expect(normalizePlanDataToMap('{bad'), isNull);
      expect(normalizePlanDataToMap('[]'), isNull);
      expect(normalizePlanDataToMap(42), isNull);
    });
  });

  group('buildWorkoutRoutinePlanData', () {
    test('preserves lifecycle markers from existing String plan data', () {
      final routine = WorkoutRoutine.empty().copyWith(name: 'Updated');
      final existing = jsonEncode({
        ...WorkoutRoutine.empty().toJson(),
        'archivedAt': '2026-06-01T00:00:00.000',
        'completedAt': '2026-06-02T00:00:00.000',
      });

      final encoded = buildWorkoutRoutinePlanData(
        routine,
        existingPlanData: existing,
      );

      expect(encoded, isA<Map<String, dynamic>>());
      expect(encoded['name'], 'Updated');
      expect(encoded['archivedAt'], '2026-06-01T00:00:00.000');
      expect(encoded['completedAt'], '2026-06-02T00:00:00.000');
    });

    test('preserves lifecycle markers from existing Map plan data', () {
      final routine = WorkoutRoutine.empty().copyWith(name: 'FromMap');
      final existing = <String, dynamic>{
        ...WorkoutRoutine.empty().toJson(),
        'archivedAt': '2026-07-01T00:00:00.000',
        'completedAt': '2026-07-02T00:00:00.000',
      };

      final encoded = buildWorkoutRoutinePlanData(
        routine,
        existingPlanData: existing,
      );

      expect(encoded['name'], 'FromMap');
      expect(encoded['archivedAt'], '2026-07-01T00:00:00.000');
      expect(encoded['completedAt'], '2026-07-02T00:00:00.000');
    });

    test('ignores malformed existing plan data', () {
      final routine = WorkoutRoutine.empty().copyWith(name: 'Safe');

      final encoded = buildWorkoutRoutinePlanData(
        routine,
        existingPlanData: '{bad-json',
      );

      expect(encoded['name'], 'Safe');
      expect(encoded.containsKey('archivedAt'), isFalse);
      expect(encoded.containsKey('completedAt'), isFalse);
    });

    test('does not invent lifecycle markers when absent', () {
      final routine = WorkoutRoutine.empty();

      final encoded = buildWorkoutRoutinePlanData(
        routine,
        existingPlanData: routine.toJson(),
      );

      expect(encoded.containsKey('archivedAt'), isFalse);
      expect(encoded.containsKey('completedAt'), isFalse);
    });
  });

  group('encodeWorkoutRoutinePlanData', () {
    test('is a jsonEncode wrapper around buildWorkoutRoutinePlanData', () {
      final routine = WorkoutRoutine.empty().copyWith(name: 'Wrapped');
      final existing = <String, dynamic>{
        'archivedAt': '2026-08-01T00:00:00.000',
      };

      final asString = encodeWorkoutRoutinePlanData(
        routine,
        existingPlanData: existing,
      );
      final asMap = buildWorkoutRoutinePlanData(
        routine,
        existingPlanData: existing,
      );

      expect(jsonDecode(asString), asMap);
    });
  });
}
