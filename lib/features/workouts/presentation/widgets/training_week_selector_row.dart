import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import 'training_planner_chip.dart';
import 'training_planner_sheets.dart';

/// Horizontal week chip row with add and overflow menu.
class TrainingWeekSelectorRow extends StatelessWidget {
  const TrainingWeekSelectorRow({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.l10n,
    required this.weeks,
    required this.weekIndex,
    required this.onSelectWeek,
    required this.onNewWeek,
    required this.onCloneWeek,
    required this.onDeleteWeek,
    required this.onEditWeek,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final List<Week> weeks;
  final int weekIndex;
  final void Function(int) onSelectWeek;
  final VoidCallback onNewWeek;
  final void Function(int) onCloneWeek;
  final void Function(int) onDeleteWeek;
  final void Function(int weekIndex) onEditWeek;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TrainingSectionLabel(
          text: l10n.workoutBuilderWeeksLabel,
          theme: theme,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < weeks.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      TrainingPlannerChip(
                        label: weeks[i].name,
                        selected: i == weekIndex,
                        onTap: () => onSelectWeek(i),
                      ),
                    ],
                    const SizedBox(width: 8),
                    TrainingPlannerAddChip(
                      label: l10n.workoutBuilderNewWeek,
                      onTap: () => showTrainingAddWeekMenuSheet(
                        context,
                        l10n,
                        weekIndex,
                        onNewWeek: onNewWeek,
                        onCloneWeek: onCloneWeek,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.workoutBuilderWeekMenuTooltip,
              icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
              onPressed: () => showTrainingPlannerMenuSheet(
                context,
                actions: [
                  (
                    icon: Icons.edit_outlined,
                    label: l10n.workoutBuilderRenameWeekMenu,
                    onTap: () => onEditWeek(weekIndex),
                    destructive: false,
                  ),
                  (
                    icon: Icons.delete_outline,
                    label: l10n.workoutBuilderDeleteWeekMenu,
                    onTap: () => onDeleteWeek(weekIndex),
                    destructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
