import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/exercise_library/presentation/exercise_picker_sheet.dart';

void main() {
  test('showExercisePickerSheet is exported from exercise_picker_sheet', () {
    expect(showExercisePickerSheet, isA<Function>());
  });

  test('AddExerciseDialogContent is re-exported', () {
    expect(AddExerciseDialogContent, isA<Type>());
  });
}
