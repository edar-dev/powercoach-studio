import 'package:flutter/material.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/breakpoints.dart';
import '../../data/workout_routine_model.dart';
import 'training_day_selector_row.dart';
import 'training_scheduled_weekday_picker.dart';
import 'training_week_selector_row.dart';
import 'training_week_vertical_list.dart';

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
    required this.onUpdateScheduledWeekday,
    this.onAddExercise,
    this.onLogSession,
    this.onCloneDayToTarget,
    this.planId,
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
  final void Function(int weekIndex, int dayIndex)? onAddExercise;
  final VoidCallback? onLogSession;
  final void Function(int weekIndex, int dayIndex)? onCloneDayToTarget;
  final String? planId;
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
                  color: cs.onSurfaceVariant,
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

    if (Breakpoints.isDesktop(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 220,
            child: TrainingWeekVerticalList(
              theme: theme,
              colorScheme: cs,
              l10n: l10n,
              weeks: weeks,
              weekIndex: weekIndex,
              onSelectWeek: onSelectWeek,
              onNewWeek: onNewWeek,
              onCloneWeek: onCloneWeek,
              onDeleteWeek: onDeleteWeek,
              onEditWeek: onEditWeek,
            ),
          ),
          VerticalDivider(width: 1, color: cs.outlineVariant),
          Expanded(
            child: _DayEditorPane(
              theme: theme,
              cs: cs,
              l10n: l10n,
              weeks: weeks,
              weekIndex: weekIndex,
              dayIndex: dayIndex,
              day: day,
              days: days,
              showWeekSelector: false,
              onSelectDay: onSelectDay,
              onAddDay: onAddDay,
              onEditDay: onEditDay,
              onDeleteDay: onDeleteDay,
              onCloneDayToTarget: onCloneDayToTarget,
              onUpdateScheduledWeekday: onUpdateScheduledWeekday,
              onAddExercise: onAddExercise,
              onLogSession: onLogSession,
              planId: planId,
              exerciseListBuilder: exerciseListBuilder,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TrainingWeekSelectorRow(
          theme: theme,
          colorScheme: cs,
          l10n: l10n,
          weeks: weeks,
          weekIndex: weekIndex,
          onSelectWeek: onSelectWeek,
          onNewWeek: onNewWeek,
          onCloneWeek: onCloneWeek,
          onDeleteWeek: onDeleteWeek,
          onEditWeek: onEditWeek,
        ),
        Expanded(
          child: _DayEditorPane(
            theme: theme,
            cs: cs,
            l10n: l10n,
            weeks: weeks,
            weekIndex: weekIndex,
            dayIndex: dayIndex,
            day: day,
            days: days,
            showWeekSelector: true,
            onSelectDay: onSelectDay,
            onAddDay: onAddDay,
            onEditDay: onEditDay,
            onDeleteDay: onDeleteDay,
            onCloneDayToTarget: onCloneDayToTarget,
            onUpdateScheduledWeekday: onUpdateScheduledWeekday,
            onAddExercise: onAddExercise,
            onLogSession: onLogSession,
            planId: planId,
            exerciseListBuilder: exerciseListBuilder,
          ),
        ),
      ],
    );
  }
}

class _DayEditorPane extends StatelessWidget {
  const _DayEditorPane({
    required this.theme,
    required this.cs,
    required this.l10n,
    required this.weeks,
    required this.weekIndex,
    required this.dayIndex,
    required this.day,
    required this.days,
    required this.showWeekSelector,
    required this.onSelectDay,
    required this.onAddDay,
    required this.onEditDay,
    required this.onDeleteDay,
    required this.onCloneDayToTarget,
    required this.onUpdateScheduledWeekday,
    required this.onAddExercise,
    required this.onLogSession,
    required this.planId,
    required this.exerciseListBuilder,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final AppLocalizations l10n;
  final List<Week> weeks;
  final int weekIndex;
  final int dayIndex;
  final Day? day;
  final List<Day> days;
  final bool showWeekSelector;
  final void Function(int) onSelectDay;
  final void Function(int) onAddDay;
  final void Function(int weekIndex, int dayIndex) onEditDay;
  final void Function(int, int) onDeleteDay;
  final void Function(int weekIndex, int dayIndex)? onCloneDayToTarget;
  final void Function(int weekIndex, int dayIndex, int weekday)
      onUpdateScheduledWeekday;
  final void Function(int weekIndex, int dayIndex)? onAddExercise;
  final VoidCallback? onLogSession;
  final String? planId;
  final Widget Function(BuildContext context, int weekIndex, int dayIndex, Day day)
      exerciseListBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showWeekSelector) const SizedBox(height: 16),
        if (days.isNotEmpty) ...[
          TrainingDaySelectorRow(
            theme: theme,
            colorScheme: cs,
            l10n: l10n,
            weekIndex: weekIndex,
            dayIndex: dayIndex,
            days: days,
            onSelectDay: onSelectDay,
            onAddDay: onAddDay,
            onEditDay: onEditDay,
            onDeleteDay: onDeleteDay,
            onCloneDayToTarget: onCloneDayToTarget,
          ),
          if (day != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TrainingScheduledWeekdayPicker(
                    theme: theme,
                    colorScheme: cs,
                    l10n: l10n,
                    day: day!,
                    dayIndex: dayIndex,
                    weekIndex: weekIndex,
                    onUpdateScheduledWeekday: onUpdateScheduledWeekday,
                  ),
                ),
                if (onLogSession != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: l10n.workoutBuilderLogSession,
                    icon: Icon(Icons.check_circle_outline, color: cs.primary),
                    onPressed: onLogSession,
                  ),
                ],
                if (planId != null && planId!.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: () {
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
                    },
                    icon: const Icon(Icons.history, size: 18),
                    label: Text(l10n.workoutBuilderDayHistory),
                  ),
                ],
              ],
            ),
          ],
        ],
        const SizedBox(height: 12),
        if (day != null) ...[
          Text(
            l10n.workoutBuilderExerciseCount(day!.exercises.length),
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RepaintBoundary(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Positioned.fill(
                    child: exerciseListBuilder(
                      context,
                      weekIndex,
                      dayIndex,
                      day!,
                    ),
                  ),
                  if (onAddExercise != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 4, bottom: 12),
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
