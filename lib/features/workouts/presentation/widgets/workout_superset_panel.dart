import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';
import 'workout_dashed_button.dart';

class WorkoutSupersetPanel extends StatelessWidget {
  const WorkoutSupersetPanel({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.children,
    required this.onAddExercise,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final List<Widget> children;
  final VoidCallback onAddExercise;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        border: Border(left: BorderSide(color: StitchM3Theme.accent, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, size: 18, color: StitchM3Theme.accent),
              const SizedBox(width: 8),
              Text(
                l10n.workoutBuilderSuperSetHeading,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: StitchM3Theme.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
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
    );
  }
}
