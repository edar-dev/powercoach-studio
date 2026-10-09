import 'package:flutter/material.dart';

import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../core/ui/widgets/cloud_save_feedback.dart';
import '../../../../l10n/app_localizations.dart';
import '../workout_editor_controller.dart';

class WorkoutEditorSaveStatusIndicator extends StatelessWidget {
  const WorkoutEditorSaveStatusIndicator({
    super.key,
    required this.saveState,
    required this.l10n,
    required this.colorScheme,
    required this.textTheme,
    required this.editorMode,
    required this.hasLoadedPlan,
    this.onRetry,
  });

  final WorkoutEditorSaveState saveState;
  final AppLocalizations l10n;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool editorMode;
  final bool hasLoadedPlan;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final (icon, label, foreground, background) = switch (saveState) {
      WorkoutEditorSaveState.saving => (
        Icons.sync,
        l10n.workoutEditorAutosaving,
        colorScheme.onPrimaryContainer,
        colorScheme.primaryContainer,
      ),
      WorkoutEditorSaveState.unsaved => (
        Icons.warning_amber_rounded,
        l10n.workoutEditorUnsavedState,
        const Color(0xFFB45309),
        StitchM3Theme.warning.withValues(alpha: 0.22),
      ),
      WorkoutEditorSaveState.failed => (
        Icons.error_outline,
        l10n.workoutEditorSaveFailedState,
        colorScheme.error,
        colorScheme.errorContainer.withValues(alpha: 0.65),
      ),
      WorkoutEditorSaveState.saved => (
        Icons.check_circle_outline,
        l10n.workoutEditorSavedState,
        StitchM3Theme.success,
        StitchM3Theme.success.withValues(alpha: 0.2),
      ),
    };

    final failed = saveState == WorkoutEditorSaveState.failed;
    final tooltip = failed
        ? l10n.workoutEditorAutosaveFailed
        : (editorMode && hasLoadedPlan
              ? l10n.workoutEditorAutosaveHint
              : label);

    return CloudSaveStatusChip(
      icon: icon,
      label: label,
      foreground: foreground,
      background: background,
      textTheme: textTheme,
      tooltip: tooltip,
      onRetry: failed ? onRetry : null,
      retryLabel: failed ? l10n.workoutEditorRetrySave : null,
    );
  }
}
