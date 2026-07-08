import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import '../../data/workout_routine_model.dart';
import 'exercise_add_sheet_content.dart';

export 'exercise_add_sheet_content.dart';

/// Shows the "Add exercise" dialog: choose from custom exercise library or create new on the fly.
/// When [customerId] is set, records for the selected exercise are loaded and shown.
void showAddExerciseDialog(
  BuildContext context,
  ThemeData theme,
  ColorScheme cs,
  void Function(
    String name,
    String note,
    List<ExerciseSet> setDetails, [
    String? customExerciseId,
  ])
  onSaveWithSets, {
  String? customerId,
}) {
  final l10n = AppLocalizations.of(context);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderAddExerciseTitle,
    fullScreen: true,
    bodyBuilder: (sheetContext) => AddExerciseDialogContent(
      theme: theme,
      cs: cs,
      customerId: customerId,
      onSaveWithSets: onSaveWithSets,
      onCancel: () => Navigator.of(sheetContext).pop(),
    ),
  );
}
