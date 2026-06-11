import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/pdf/pdf_exercise_name.dart';

void main() {
  test('abbreviateExerciseNameForPdf strips equipment suffix', () {
    expect(
      abbreviateExerciseNameForPdf('Bench Press (Barbell)'),
      'Bench Press',
    );
    expect(
      abbreviateExerciseNameForPdf('Seated Cable Row - V Grip (Cable)'),
      'Seated Cable Row - V Grip',
    );
    expect(
      abbreviateExerciseNameForPdf('Chest Press (Machine)'),
      'Chest Press',
    );
  });
}
