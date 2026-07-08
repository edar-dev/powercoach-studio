import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_date_picker_helpers.dart';

void main() {
  group('workout builder date helpers', () {
    test('applyRoutineStartDate sets start date only', () {
      final routine = WorkoutRoutine.empty();
      final updated = applyRoutineStartDate(
        routine,
        DateTime(2026, 3, 15),
      );
      expect(updated.startDate, DateTime(2026, 3, 15));
      expect(updated.endDate, isNull);
    });

    test('applyRoutineEndDate sets end date only', () {
      final routine = WorkoutRoutine.empty().copyWith(
        startDate: DateTime(2026, 3, 1),
      );
      final updated = applyRoutineEndDate(routine, DateTime(2026, 6, 1));
      expect(updated.endDate, DateTime(2026, 6, 1));
      expect(updated.startDate, DateTime(2026, 3, 1));
    });
  });
}
