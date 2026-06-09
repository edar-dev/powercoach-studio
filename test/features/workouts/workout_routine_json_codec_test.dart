import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_routine_json_codec.dart';

void main() {
  test('round-trip envelope preserves routine fields', () {
    final routine = WorkoutRoutine.empty().copyWith(name: 'Test Plan');
    final jsonText = encodeWorkoutRoutineJson(routine);
    final restored = decodeWorkoutRoutineJson(jsonText);

    expect(restored.name, 'Test Plan');
    expect(restored.weeks.length, routine.weeks.length);
  });

  test('decodes raw planData object without envelope', () {
    final routine = WorkoutRoutine.empty().copyWith(name: 'Legacy');
    final jsonText = jsonEncode(routine.toJson());
    final restored = decodeWorkoutRoutineJson(jsonText);

    expect(restored.name, 'Legacy');
  });

  test('rejects unsupported schema version', () {
    final payload = {
      'schemaVersion': 99,
      'format': workoutRoutineJsonFormat,
      'routine': WorkoutRoutine.empty().toJson(),
    };
    expect(
      () => decodeWorkoutRoutineJson(jsonEncode(payload)),
      throwsFormatException,
    );
  });
}
