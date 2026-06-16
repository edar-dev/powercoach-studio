import 'package:flutter/material.dart';

import '../../workouts/data/workout_routine_model.dart';
import '../../workouts/presentation/widgets/exercise_add_sheet.dart';

export '../../workouts/presentation/widgets/exercise_add_sheet.dart'
    show AddExerciseDialogContent;

/// Unified coach exercise picker (fullscreen sheet with pin, recent, search).
void showExercisePickerSheet(
  BuildContext context,
  ThemeData theme,
  ColorScheme colorScheme,
  void Function(
    String name,
    String note,
    List<ExerciseSet> setDetails, [
    String? customExerciseId,
  ])
  onSelected, {
  String? customerId,
}) {
  showAddExerciseDialog(
    context,
    theme,
    colorScheme,
    onSelected,
    customerId: customerId,
  );
}
