import 'package:flutter/material.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import 'training_session_toolbar.dart';

/// Session-sheet training layout: sticky week/day toolbar + day content.
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
    required this.onUpdateScheduledWeekday,
    this.onLogSession,
    this.onCloneDayToTarget,
    this.planId,
    this.editorMode = false,
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
  final void Function(int weekIndex, int dayIndex, int weekday)
      onUpdateScheduledWeekday;
  final VoidCallback? onLogSession;
  final void Function(int weekIndex, int dayIndex)? onCloneDayToTarget;
  final String? planId;
  final bool editorMode;
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
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.72),
                ),
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
    final dayIndex =
        days.isEmpty ? 0 : selectedDayIndex.clamp(0, days.length - 1);
    final day = days.isEmpty ? null : days[dayIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TrainingSessionToolbar(
          theme: theme,
          colorScheme: cs,
          l10n: l10n,
          weeks: weeks,
          weekIndex: weekIndex,
          dayIndex: dayIndex,
          onSelectWeek: onSelectWeek,
          onSelectDay: onSelectDay,
          onNewWeek: onNewWeek,
          onCloneWeek: onCloneWeek,
          onDeleteWeek: onDeleteWeek,
          onEditWeek: onEditWeek,
          onAddDay: onAddDay,
          onEditDay: onEditDay,
          onDeleteDay: onDeleteDay,
          onUpdateScheduledWeekday: onUpdateScheduledWeekday,
          onCloneDayToTarget: onCloneDayToTarget,
        ),
        Expanded(
          child: _SessionSheetBody(
            theme: theme,
            cs: cs,
            l10n: l10n,
            weekIndex: weekIndex,
            dayIndex: dayIndex,
            day: day,
            dayCount: days.length,
            onAddDay: onAddDay,
            onLogSession: onLogSession,
            planId: planId,
            editorMode: editorMode,
            exerciseListBuilder: exerciseListBuilder,
          ),
        ),
      ],
    );
  }
}

class _SessionSheetBody extends StatelessWidget {
  const _SessionSheetBody({
    required this.theme,
    required this.cs,
    required this.l10n,
    required this.weekIndex,
    required this.dayIndex,
    required this.day,
    required this.dayCount,
    required this.onAddDay,
    required this.onLogSession,
    required this.planId,
    required this.editorMode,
    required this.exerciseListBuilder,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final AppLocalizations l10n;
  final int weekIndex;
  final int dayIndex;
  final Day? day;
  final int dayCount;
  final void Function(int) onAddDay;
  final VoidCallback? onLogSession;
  final String? planId;
  final bool editorMode;
  final Widget Function(BuildContext context, int weekIndex, int dayIndex, Day day)
      exerciseListBuilder;

  @override
  Widget build(BuildContext context) {
    if (day == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.workoutBuilderNoDaysInWeek,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w500,
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
      );
    }

    final showSessionActions = editorMode;
    final secondaryStyle = theme.textTheme.bodyMedium?.copyWith(
      color: cs.onSurface.withValues(alpha: 0.8),
      fontWeight: FontWeight.w500,
    );

    final sessionMenuItems = <PopupMenuEntry<String>>[
      if (showSessionActions && onLogSession != null)
        PopupMenuItem(
          value: 'log',
          child: Text(l10n.workoutBuilderLogSession),
        ),
      if (showSessionActions && planId != null && planId!.isNotEmpty)
        PopupMenuItem(
          value: 'history',
          child: Text(l10n.workoutBuilderDayHistory),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (dayCount > 1) ...[
                      Text(
                        day!.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      l10n.workoutBuilderExerciseCount(day!.exercises.length),
                      style: secondaryStyle,
                    ),
                  ],
                ),
              ),
              if (sessionMenuItems.isNotEmpty)
                PopupMenuButton<String>(
                  tooltip: l10n.workoutBuilderSessionActionsTooltip,
                  onSelected: (value) {
                    if (value == 'log') {
                      onLogSession?.call();
                    } else if (value == 'history') {
                      navigateTo(
                        context,
                        workoutDiaryPath(
                          planId: planId,
                          sessionKey: WorkoutRoutine.sessionKey(
                            weekIndex,
                            dayIndex,
                          ),
                        ),
                      );
                    }
                  },
                  itemBuilder: (_) => sessionMenuItems,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_available_outlined,
                              size: 18,
                              color: cs.onSurface.withValues(alpha: 0.72),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.workoutBuilderSessionMenuLabel,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.72),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: exerciseListBuilder(
            context,
            weekIndex,
            dayIndex,
            day!,
          ),
        ),
      ],
    );
  }
}
