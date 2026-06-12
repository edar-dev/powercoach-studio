import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/pdf/pdf_exercise_name.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';

void main() {
  test('resolveExerciseDisplayNameForPdf prefers shortName', () {
    const exercise = Exercise(
      id: 'e1',
      name: 'Seated Cable Row - V Grip (Cable)',
      sets: '1',
      reps: '4x8',
      rpe: '',
      shortName: 'Cable Row (V)',
    );

    expect(resolveExerciseDisplayNameForPdf(exercise), 'Cable Row (V)');
  });

  test('abbreviateExerciseNameForPdf strips equipment suffix', () {
    expect(
      abbreviateExerciseNameForPdf('Bench Press (Barbell)'),
      'Bench Press',
    );
    expect(
      abbreviateExerciseNameForPdf('Seated Cable Row - V Grip (Cable)'),
      'Cable Row (V)',
    );
    expect(
      abbreviateExerciseNameForPdf('Seated Overhead Press (Dumbbell)'),
      'OHP DB',
    );
    expect(
      abbreviateExerciseNameForPdf('Chest Press (Machine)'),
      'Chest Press',
    );
  });
}
