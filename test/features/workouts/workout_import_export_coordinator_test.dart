import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_import_export_coordinator.dart';

void main() {
  group('parseWorkoutRoutineImport', () {
    test('returns empty failure for blank content', () {
      final result = parseWorkoutRoutineImport('   ');

      expect(result.isSuccess, isFalse);
      expect(result.failureReason, WorkoutImportFailureReason.empty);
    });

    test('returns invalid failure for malformed content', () {
      final result = parseWorkoutRoutineImport('{bad-json');

      expect(result.isSuccess, isFalse);
      expect(result.failureReason, WorkoutImportFailureReason.invalidFormat);
    });

    test('returns routine for raw routine JSON', () {
      final routine = WorkoutRoutine.empty().copyWith(name: 'Imported');

      final result = parseWorkoutRoutineImport(jsonEncode(routine.toJson()));

      expect(result.isSuccess, isTrue);
      expect(result.routine?.name, 'Imported');
    });
  });
}
