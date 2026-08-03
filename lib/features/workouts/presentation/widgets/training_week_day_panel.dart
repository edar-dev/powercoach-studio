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
            onAddDay: onAddDay,
            onAddExercise: onAddExercise,
            onLogSession: onLogSession,
            planId: planId,
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
    required this.onAddDay,
    required this.onAddExercise,
    required this.onLogSession,
    required this.planId,
    required this.exerciseListBuilder,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final AppLocalizations l10n;
  final int weekIndex;
  final int dayIndex;
  final Day? day;
  final void Function(int) onAddDay;
  final void Function(int weekIndex, int dayIndex)? onAddExercise;
  final VoidCallback? onLogSession;
  final String? planId;
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
      );
    }

    final hasExercises = day!.exercises.isNotEmpty;

    return Stack(
      children: [
        Column(
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
                        Text(
                          day!.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.workoutBuilderExerciseCount(day!.exercises.length),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onLogSession != null)
                    TextButton.icon(
                      onPressed: onLogSession,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(l10n.workoutBuilderLogSession),
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
        ),
        if (onAddExercise != null && hasExercises)
          Positioned(
            right: 16,
            bottom: 16,
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
    );
  }
}
