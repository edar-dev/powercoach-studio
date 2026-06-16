import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';
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
  });

  final WorkoutEditorSaveState saveState;
  final AppLocalizations l10n;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool editorMode;
  final bool hasLoadedPlan;

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
      WorkoutEditorSaveState.saved => (
        Icons.check_circle_outline,
        l10n.workoutEditorSavedState,
        StitchM3Theme.success,
        StitchM3Theme.success.withValues(alpha: 0.2),
      ),
    };

    return Tooltip(
      message: editorMode && hasLoadedPlan ? l10n.workoutEditorAutosaveHint : label,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: foreground.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 6),
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
