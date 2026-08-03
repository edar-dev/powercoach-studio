import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'workout_dashed_button.dart';
import 'workout_expandable_card.dart';

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

    return WorkoutExpandableCard(
      expanded: expanded,
      onExpandedChanged: onExpandedChanged,
      accentBorder: true,
      summary: prescriptionSummary,
      title: Row(
        children: [
          Icon(Icons.link, size: 18, color: StitchM3Theme.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.workoutBuilderSuperSetHeading,
              style: theme.textTheme.titleSmall?.copyWith(
                color: StitchM3Theme.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      trailing: onOpenEditor != null
          ? TextButton(
              onPressed: onOpenEditor,
              child: Text(l10n.builderSupersetManage),
            )
          : null,
      expandedChild: Column(
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
    );
  }
}
