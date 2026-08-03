import 'package:flutter/material.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/breakpoints.dart';
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

    final sheet = Column(
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

    if (!Breakpoints.isDesktop(context)) {
      return sheet;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.maxWidth > 840 ? 840.0 : constraints.maxWidth;
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width,
            height: constraints.maxHeight,
            child: sheet,
          ),
        );
      },
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              if (showSessionActions && onLogSession != null)
                IconButton(
                  tooltip: l10n.workoutBuilderLogSession,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: onLogSession,
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: StitchM3Theme.accent,
                  ),
                ),
              if (showSessionActions && planId != null && planId!.isNotEmpty)
                IconButton(
                  tooltip: l10n.workoutBuilderDayHistory,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  padding: EdgeInsets.zero,
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
                  icon: Icon(
                    Icons.history,
                    color: cs.onSurface.withValues(alpha: 0.8),
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
