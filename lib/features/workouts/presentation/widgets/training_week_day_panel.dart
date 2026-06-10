import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../../../widgets/app_sheet.dart';
import '../../data/workout_routine_model.dart';

/// Horizontal week/day planner used by the workout builder training tab.
class TrainingWeekDayPanel extends StatelessWidget {
  const TrainingWeekDayPanel({
    super.key,
    required this.theme,
    required this.cs,
    required this.weeks,
    required this.selectedWeekIndex,
    required this.selectedDayIndex,
    required this.onSelectWeek,
    required this.onSelectDay,
    required this.onNewWeek,
    required this.onCloneWeek,
    required this.onDeleteWeek,
    required this.onEditWeek,
    required this.onAddDay,
    required this.onEditDay,
    required this.onDeleteDay,
    this.onAddExercise,
    required this.exerciseListBuilder,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final List<Week> weeks;
  final int selectedWeekIndex;
  final int selectedDayIndex;
  final void Function(int) onSelectWeek;
  final void Function(int) onSelectDay;
  final VoidCallback onNewWeek;
  final void Function(int) onCloneWeek;
  final void Function(int) onDeleteWeek;
  final void Function(int weekIndex) onEditWeek;
  final void Function(int) onAddDay;
  final void Function(int weekIndex, int dayIndex) onEditDay;
  final void Function(int, int) onDeleteDay;
  final void Function(int weekIndex, int dayIndex)? onAddExercise;
  final Widget Function(BuildContext context, int weekIndex, int dayIndex, Day day)
  exerciseListBuilder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (weeks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_view_week, size: 48, color: cs.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                l10n.workoutBuilderNoWeeksYet,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onNewWeek,
                icon: const Icon(Icons.add),
                label: Text(l10n.workoutBuilderNewWeek),
              ),
            ],
          ),
        ),
      );
    }

    final weekIndex = selectedWeekIndex.clamp(0, weeks.length - 1);
    final week = weeks[weekIndex];
    final days = week.days;
    final dayIndex = days.isEmpty
        ? 0
        : selectedDayIndex.clamp(0, days.length - 1);
    final day = days.isEmpty ? null : days[dayIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(text: l10n.workoutBuilderWeeksLabel, theme: theme, cs: cs),
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
                      _PlannerChip(
                        label: weeks[i].name,
                        selected: i == weekIndex,
                        onTap: () => onSelectWeek(i),
                      ),
                    ],
                    const SizedBox(width: 8),
                    _PlannerAddChip(
                      label: l10n.workoutBuilderNewWeek,
                      onTap: () => _showAddWeekMenuSheet(
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
              tooltip: l10n.workoutBuilderMoreActions,
              icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant),
              onPressed: () => _showPlannerMenuSheet(
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
        if (days.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionLabel(text: l10n.workoutBuilderDaysLabel, theme: theme, cs: cs),
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
                        _SwipeableDayChip(
                          dayId: days[i].id,
                          label: days[i].name,
                          selected: i == dayIndex,
                          dismissible: days.length > 1,
                          onTap: () => onSelectDay(i),
                          onDismiss: () => onDeleteDay(weekIndex, i),
                          confirmDismiss: () => _confirmDeleteDay(
                            context,
                            l10n,
                            days[i].name,
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      _PlannerAddChip(
                        label: l10n.workoutBuilderAddDayChip,
                        onTap: () => onAddDay(weekIndex),
                      ),
                    ],
                  ),
                ),
              ),
              if (days.length > 1) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.workoutBuilderSwipeDayHint,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (day != null)
                IconButton(
                  tooltip: l10n.workoutBuilderMoreActions,
                  icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant),
                  onPressed: () => _showPlannerMenuSheet(
                    context,
                    actions: [
                      (
                        icon: Icons.edit_outlined,
                        label: l10n.workoutBuilderRenameDayTitle,
                        onTap: () => onEditDay(weekIndex, dayIndex),
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
        ],
        const SizedBox(height: 12),
        if (day != null) ...[
          Text(
            l10n.workoutBuilderExerciseCount(day.exercises.length),
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Positioned.fill(
                  child: exerciseListBuilder(context, weekIndex, dayIndex, day),
                ),
                if (onAddExercise != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4, bottom: 8),
                    child: FloatingActionButton.extended(
                      heroTag: 'workout_builder_add_exercise',
                      onPressed: () => onAddExercise!(weekIndex, dayIndex),
                      backgroundColor: StitchM3Theme.accent,
                      foregroundColor: Colors.white,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.workoutBuilderAddExercise),
                    ),
                  ),
              ],
            ),
          ),
        ] else ...[
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.workoutBuilderNoDaysInWeek,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => onAddDay(weekIndex),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.workoutBuilderAddDayChip),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.theme, required this.cs});

  final String text;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: cs.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

Future<bool> _confirmDeleteDay(
  BuildContext context,
  AppLocalizations l10n,
  String dayName,
) {
  return showAppConfirmDialog(
    context: context,
    title: l10n.workoutBuilderDeleteDayTitle,
    message: '${l10n.workoutBuilderDeleteDayMessage}\n\n$dayName',
    confirmLabel: l10n.customerDelete,
    cancelLabel: l10n.customerCancel,
    destructive: true,
  );
}

void showTrainingPlannerMenuSheet(
  BuildContext context, {
  required List<({IconData icon, String label, VoidCallback onTap, bool destructive})>
  actions,
}) => _showPlannerMenuSheet(context, actions: actions);

void _showAddWeekMenuSheet(
  BuildContext context,
  AppLocalizations l10n,
  int weekIndex, {
  required VoidCallback onNewWeek,
  required void Function(int) onCloneWeek,
}) {
  _showPlannerMenuSheet(
    context,
    actions: [
      (
        icon: Icons.add,
        label: l10n.workoutBuilderNewWeek,
        onTap: onNewWeek,
        destructive: false,
      ),
      (
        icon: Icons.copy,
        label: l10n.workoutBuilderDuplicateWeek,
        onTap: () => onCloneWeek(weekIndex),
        destructive: false,
      ),
    ],
  );
}

void _showPlannerMenuSheet(
  BuildContext context, {
  required List<({IconData icon, String label, VoidCallback onTap, bool destructive})>
  actions,
}) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: actions
            .map(
              (a) => ListTile(
                leading: Icon(
                  a.icon,
                  color: a.destructive ? StitchM3Theme.danger : null,
                ),
                title: Text(
                  a.label,
                  style: a.destructive
                      ? const TextStyle(color: StitchM3Theme.danger)
                      : null,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  a.onTap();
                },
              ),
            )
            .toList(),
      ),
    ),
  );
}

class _PlannerChip extends StatelessWidget {
  const _PlannerChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: selected ? Colors.white : cs.onSurface,
      ),
      selectedColor: StitchM3Theme.accent,
      backgroundColor: cs.surfaceContainerHighest,
      side: BorderSide(
        color: selected ? StitchM3Theme.accent : cs.outline.withValues(alpha: 0.4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _SwipeableDayChip extends StatelessWidget {
  const _SwipeableDayChip({
    required this.dayId,
    required this.label,
    required this.selected,
    required this.dismissible,
    required this.onTap,
    required this.onDismiss,
    required this.confirmDismiss,
  });

  final String dayId;
  final String label;
  final bool selected;
  final bool dismissible;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final Future<bool> Function() confirmDismiss;

  @override
  Widget build(BuildContext context) {
    final chip = _PlannerChip(label: label, selected: selected, onTap: onTap);
    if (!dismissible) return chip;

    return Dismissible(
      key: ValueKey('day_$dayId'),
      direction: DismissDirection.up,
      confirmDismiss: (_) => confirmDismiss(),
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: StitchM3Theme.danger.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(Icons.delete_outline, color: StitchM3Theme.danger, size: 20),
      ),
      child: chip,
    );
  }
}

class _PlannerAddChip extends StatelessWidget {
  const _PlannerAddChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ActionChip(
      avatar: Icon(Icons.add, size: 16, color: StitchM3Theme.accent),
      label: Text(
        label,
        style: TextStyle(
          color: StitchM3Theme.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: onTap,
      backgroundColor: cs.surfaceContainerHighest,
      side: BorderSide(color: StitchM3Theme.accent.withValues(alpha: 0.4)),
    );
  }
}
