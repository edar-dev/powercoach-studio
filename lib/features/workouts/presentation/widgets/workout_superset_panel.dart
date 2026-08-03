import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'workout_dashed_button.dart';

/// Flat superset group for the session sheet.
class WorkoutSupersetPanel extends StatelessWidget {
  const WorkoutSupersetPanel({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.children,
    required this.onAddExercise,
    required this.expanded,
    required this.onExpandedChanged,
    this.prescriptionSummary,
    this.onOpenEditor,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final List<Widget> children;
  final VoidCallback onAddExercise;
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
  final String? prescriptionSummary;
  final VoidCallback? onOpenEditor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: StitchM3Theme.accent, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => onExpandedChanged(!expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 4, 14),
              child: Row(
                children: [
                  Icon(Icons.link, size: 18, color: StitchM3Theme.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.workoutBuilderSuperSetHeading,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: StitchM3Theme.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (prescriptionSummary != null &&
                            prescriptionSummary!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            prescriptionSummary!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  if (onOpenEditor != null)
                    TextButton(
                      onPressed: onOpenEditor,
                      child: Text(l10n.builderSupersetManage),
                    ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
