import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/breakpoints.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/day_scheduled_weekday.dart';
import 'training_day_selector_row.dart';
import 'training_scheduled_weekday_picker.dart';
import 'training_week_selector_row.dart';
import 'training_week_vertical_list.dart';
import 'workout_expandable_card.dart';

/// Horizontal week/day planner used by the workout builder training tab.
class TrainingWeekDayPanel extends StatefulWidget {
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
  State<TrainingWeekDayPanel> createState() => _TrainingWeekDayPanelState();
}

class _TrainingWeekDayPanelState extends State<TrainingWeekDayPanel> {
  late bool _plannerExpanded;

  @override
  void initState() {
    super.initState();
    _plannerExpanded = widget.weeks.length <= 1;
  }

  @override
  void didUpdateWidget(covariant TrainingWeekDayPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When going from empty/single-week to multi-week, collapse to reclaim space.
    if (oldWidget.weeks.length <= 1 && widget.weeks.length > 1) {
      _plannerExpanded = false;
    }
  }

  String _plannerSummary({
    required BuildContext context,
    required Week week,
    required Day? day,
    required int dayIndex,
  }) {
    final parts = <String>[week.name];
    if (day != null) {
      parts.add(day.name);
      final weekday = effectiveScheduledWeekday(day: day, dayIndex: dayIndex);
      // 2024-01-01 was a Monday; DateTime(2024, 1, isoWeekday) maps 1..7 → Mon..Sun.
      final weekdayDate = DateTime(2024, 1, weekday);
      final locale = Localizations.localeOf(context).toString();
      parts.add(DateFormat.EEEE(locale).format(weekdayDate));
    }
    return parts.where((p) => p.trim().isNotEmpty).join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final cs = widget.cs;
    final weeks = widget.weeks;
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
                onPressed: widget.onNewWeek,
                icon: const Icon(Icons.add),
                label: Text(l10n.workoutBuilderNewWeek),
              ),
            ],
          ),
        ),
      );
    }

    final weekIndex = widget.selectedWeekIndex.clamp(0, weeks.length - 1);
    final week = weeks[weekIndex];
    final days = week.days;
    final dayIndex =
        days.isEmpty ? 0 : widget.selectedDayIndex.clamp(0, days.length - 1);
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
              onSelectWeek: widget.onSelectWeek,
              onNewWeek: widget.onNewWeek,
              onCloneWeek: widget.onCloneWeek,
              onDeleteWeek: widget.onDeleteWeek,
              onEditWeek: widget.onEditWeek,
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
              plannerExpanded: _plannerExpanded,
              plannerSummary: _plannerSummary(
                context: context,
                week: week,
                day: day,
                dayIndex: dayIndex,
              ),
              onPlannerExpandedChanged: (value) {
                setState(() => _plannerExpanded = value);
              },
              onSelectDay: widget.onSelectDay,
              onAddDay: widget.onAddDay,
              onEditDay: widget.onEditDay,
              onDeleteDay: widget.onDeleteDay,
              onCloneDayToTarget: widget.onCloneDayToTarget,
              onUpdateScheduledWeekday: widget.onUpdateScheduledWeekday,
              onAddExercise: widget.onAddExercise,
              onLogSession: widget.onLogSession,
              planId: widget.planId,
              exerciseListBuilder: widget.exerciseListBuilder,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: WorkoutExpandableCard(
            expanded: _plannerExpanded,
            onExpandedChanged: (value) {
              setState(() => _plannerExpanded = value);
            },
            summary: _plannerExpanded
                ? null
                : _plannerSummary(
                    context: context,
                    week: week,
                    day: day,
                    dayIndex: dayIndex,
                  ),
            title: Text(
              l10n.workoutBuilderWeeksLabel,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            expandedChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TrainingWeekSelectorRow(
                  theme: theme,
                  colorScheme: cs,
                  l10n: l10n,
                  weeks: weeks,
                  weekIndex: weekIndex,
                  onSelectWeek: widget.onSelectWeek,
                  onNewWeek: widget.onNewWeek,
                  onCloneWeek: widget.onCloneWeek,
                  onDeleteWeek: widget.onDeleteWeek,
                  onEditWeek: widget.onEditWeek,
                ),
                if (days.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  TrainingDaySelectorRow(
                    theme: theme,
                    colorScheme: cs,
                    l10n: l10n,
                    weekIndex: weekIndex,
                    dayIndex: dayIndex,
                    days: days,
                    onSelectDay: widget.onSelectDay,
                    onAddDay: widget.onAddDay,
                    onEditDay: widget.onEditDay,
                    onDeleteDay: widget.onDeleteDay,
                    onCloneDayToTarget: widget.onCloneDayToTarget,
                  ),
                  if (day != null) ...[
                    const SizedBox(height: 10),
                    TrainingScheduledWeekdayPicker(
                      theme: theme,
                      colorScheme: cs,
                      l10n: l10n,
                      day: day,
                      dayIndex: dayIndex,
                      weekIndex: weekIndex,
                      onUpdateScheduledWeekday: widget.onUpdateScheduledWeekday,
                    ),
                  ],
                ],
              ],
            ),
          ),
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
            plannerExpanded: _plannerExpanded,
            plannerSummary: _plannerSummary(
              context: context,
              week: week,
              day: day,
              dayIndex: dayIndex,
            ),
            // Mobile planner lives above; hide duplicate chrome in the pane.
            hidePlannerChrome: true,
            onPlannerExpandedChanged: (value) {
              setState(() => _plannerExpanded = value);
            },
            onSelectDay: widget.onSelectDay,
            onAddDay: widget.onAddDay,
            onEditDay: widget.onEditDay,
            onDeleteDay: widget.onDeleteDay,
            onCloneDayToTarget: widget.onCloneDayToTarget,
            onUpdateScheduledWeekday: widget.onUpdateScheduledWeekday,
            onAddExercise: widget.onAddExercise,
            onLogSession: widget.onLogSession,
            planId: widget.planId,
            exerciseListBuilder: widget.exerciseListBuilder,
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
    required this.plannerExpanded,
    required this.plannerSummary,
    required this.onPlannerExpandedChanged,
    this.hidePlannerChrome = false,
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
  final bool plannerExpanded;
  final String plannerSummary;
  final ValueChanged<bool> onPlannerExpandedChanged;
  final bool hidePlannerChrome;
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
        if (!hidePlannerChrome && !showWeekSelector) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: WorkoutExpandableCard(
              expanded: plannerExpanded,
              onExpandedChanged: onPlannerExpandedChanged,
              summary: plannerExpanded ? null : plannerSummary,
              title: Text(
                l10n.workoutBuilderDaysLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              expandedChild: days.isEmpty
                  ? null
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                          TrainingScheduledWeekdayPicker(
                            theme: theme,
                            colorScheme: cs,
                            l10n: l10n,
                            day: day!,
                            dayIndex: dayIndex,
                            weekIndex: weekIndex,
                            onUpdateScheduledWeekday: onUpdateScheduledWeekday,
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
        if (day != null) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.workoutBuilderExerciseCount(day!.exercises.length),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onLogSession != null)
                IconButton(
                  tooltip: l10n.workoutBuilderLogSession,
                  icon: Icon(Icons.check_circle_outline, color: cs.primary),
                  onPressed: onLogSession,
                ),
              if (planId != null && planId!.isNotEmpty)
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
