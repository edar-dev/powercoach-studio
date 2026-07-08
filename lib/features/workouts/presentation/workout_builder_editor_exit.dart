import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/constants/workout_plan_template_scope.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
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
  if (editorMode &&
      customerId != null &&
      customerId.isNotEmpty &&
      customerId != kWorkoutPlanTemplateScopeId) {
    navigateBack(context, fallback: customerWorkoutsPath(customerId));
    return;
  }
  if (editorMode && customerId == kWorkoutPlanTemplateScopeId) {
    navigateBack(context, fallback: '/workouts/templates');
    return;
  }
  // Standalone builder lives at /workouts/builder with parent /workouts — popping
  // would bounce between the two URLs. Exit to the coach hub instead.
  context.go('/dashboard');
}
