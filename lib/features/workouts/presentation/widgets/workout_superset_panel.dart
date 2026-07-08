import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'workout_dashed_button.dart';

class WorkoutSupersetPanel extends StatelessWidget {
  const WorkoutSupersetPanel({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.children,
    required this.onAddExercise,
    this.prescriptionSummary,
    this.onOpenEditor,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final List<Widget> children;
  final VoidCallback onAddExercise;
  final String? prescriptionSummary;
  final VoidCallback? onOpenEditor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final header = Row(
      children: [
        Icon(Icons.link, size: 18, color: StitchM3Theme.accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.workoutBuilderSuperSetHeading,
            style: theme.textTheme.labelSmall?.copyWith(
              color: StitchM3Theme.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (onOpenEditor != null)
          TextButton(
            onPressed: onOpenEditor,
            child: Text(l10n.builderSupersetManage),
          ),
      ],
    );

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
      child: InkWell(
        onTap: onOpenEditor,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            border: Border(
              left: BorderSide(color: StitchM3Theme.accent, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              if (prescriptionSummary != null &&
                  prescriptionSummary!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  prescriptionSummary!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              ...children,
              const SizedBox(height: 8),
              WorkoutDashedButton(
                icon: Icons.add,
                label: l10n.workoutBuilderAddExercise,
                onPressed: onAddExercise,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
