import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import 'training_planner_chip.dart';
import 'training_planner_sheets.dart';

/// Vertical week list for desktop two-pane workout builder layout.
class TrainingWeekVerticalList extends StatelessWidget {
  const TrainingWeekVerticalList({
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
        Expanded(
          child: ListView.separated(
            itemCount: weeks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final week = weeks[index];
              return TrainingPlannerChip(
                label: week.name,
                selected: index == weekIndex,
                onTap: () => onSelectWeek(index),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
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
    );
  }
}
