import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/collapsed_prescription_summary.dart';

void main() {
  test('structured sets×reps with load uses multiplication sign', () {
    expect(
      collapsedPrescriptionSummary(const [
        ExerciseSet(sets: '3', reps: '5', rpe: '@9'),
      ]),
      '3×5 @9',
    );
  });

  test('joins multiple blocks with middle dot', () {
    expect(
      collapsedPrescriptionSummary(const [
        ExerciseSet(sets: '3', reps: '5', rpe: '@9'),
        ExerciseSet(sets: '2', reps: '8', rpe: '60kg'),
      ]),
      '3×5 @9 · 2×8 60kg',
    );
  });

  test('normalizes ASCII x between digits in free-form line', () {
    expect(
      collapsedPrescriptionSummary(const [
        ExerciseSet(line: '3x5 @8'),
      ]),
      '3×5 @8',
    );
  });

  test('bare numeric-only single part is empty', () {
    expect(
      collapsedPrescriptionSummary(const [
        ExerciseSet(sets: '1'),
      ]),
      '',
    );
  });
}
