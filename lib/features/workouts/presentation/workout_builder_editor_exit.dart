import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/routing/app_paths.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

enum WorkoutEditorExitAction { save, discard, cancel }

Future<WorkoutEditorExitAction?> showWorkoutEditorUnsavedDialog(
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context);
  return showDialog<WorkoutEditorExitAction>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.workoutEditorUnsavedTitle),
      content: Text(l10n.workoutEditorUnsavedMessage),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(WorkoutEditorExitAction.cancel),
          child: Text(l10n.workoutEditorCancel),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(WorkoutEditorExitAction.discard),
          child: Text(l10n.workoutEditorDiscard),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(WorkoutEditorExitAction.save),
          child: Text(l10n.workoutEditorSaveAndExit),
        ),
      ],
    ),
  );
}

void navigateBackFromWorkoutBuilder({
  required BuildContext context,
  required bool editorMode,
  String? customerId,
}) {
  if (editorMode && customerId != null && customerId.isNotEmpty) {
    navigateBack(context, fallback: customerWorkoutsPath(customerId));
    return;
  }
  // Standalone builder lives at /workouts/builder with parent /workouts — popping
  // would bounce between the two URLs. Exit to the coach hub instead.
  navigateTo(context, AppPaths.dashboard);
}

/// Home from any builder mode: always Today (`/dashboard`).
void navigateHomeFromWorkoutBuilder(BuildContext context) {
  navigateTo(context, AppPaths.dashboard);
}
