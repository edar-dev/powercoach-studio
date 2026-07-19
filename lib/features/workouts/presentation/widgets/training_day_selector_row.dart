import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import 'training_planner_chip.dart';
import 'training_planner_sheets.dart';

/// Horizontal day chip row with add, swipe-delete, and overflow menu.
class TrainingDaySelectorRow extends StatelessWidget {
  const TrainingDaySelectorRow({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.l10n,
    required this.weekIndex,
    required this.dayIndex,
    required this.days,
    required this.onSelectDay,
    required this.onAddDay,
    required this.onEditDay,
    required this.onDeleteDay,
    this.onCloneDayToTarget,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final int weekIndex;
  final int dayIndex;
  final List<Day> days;
  final void Function(int) onSelectDay;
  final void Function(int) onAddDay;
  final void Function(int weekIndex, int dayIndex) onEditDay;
  final void Function(int, int) onDeleteDay;
  final void Function(int weekIndex, int dayIndex)? onCloneDayToTarget;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TrainingSectionLabel(
          text: l10n.workoutBuilderDaysLabel,
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
                    for (var i = 0; i < days.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      TrainingSwipeableDayChip(
                        dayId: days[i].id,
                        label: days[i].name,
                        selected: i == dayIndex,
                        dismissible: days.length > 1,
                        onTap: () => onSelectDay(i),
                        onDismiss: () => onDeleteDay(weekIndex, i),
                        confirmDismiss: () => confirmTrainingDeleteDay(
                          context,
                          l10n,
                          days[i].name,
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    TrainingPlannerAddChip(
                      label: l10n.workoutBuilderAddDayChip,
                      onTap: () => onAddDay(weekIndex),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.workoutBuilderDayMenuTooltip,
              icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
              onPressed: () => showTrainingPlannerMenuSheet(
                context,
                actions: [
                  (
                    icon: Icons.edit_outlined,
                    label: l10n.workoutBuilderRenameDayTitle,
                    onTap: () => onEditDay(weekIndex, dayIndex),
                    destructive: false,
                  ),
                  if (onCloneDayToTarget != null)
                    (
                      icon: Icons.copy_outlined,
                      label: l10n.workoutBuilderCloneDayToTarget,
                      onTap: () => onCloneDayToTarget!(weekIndex, dayIndex),
                      destructive: false,
                    ),
                  if (days.length > 1)
                    (
                      icon: Icons.delete_outline,
                      label: l10n.workoutBuilderDeleteDayMenu,
                      onTap: () => onDeleteDay(weekIndex, dayIndex),
                      destructive: true,
                    ),
                ],
              ),
            ),
          ],
        ),
        if (days.length > 1) ...[
          const SizedBox(height: 6),
          Text(
            l10n.workoutBuilderSwipeDayHint,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
