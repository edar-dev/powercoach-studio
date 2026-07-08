import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/domain/plan_calendar_event.dart';
import '../../domain/session_execution.dart';

/// Read-only session log body shared by diary detail and legacy preview.
class WorkoutDiaryEntryBody extends StatelessWidget {
  const WorkoutDiaryEntryBody({
    super.key,
    required this.execution,
    required this.l10n,
  });

  final SessionExecution execution;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (execution.notes.trim().isNotEmpty) ...[
          Text(execution.notes),
          const SizedBox(height: 16),
        ],
        if (execution.exercises.isEmpty)
          Text(
            l10n.workoutDiaryNoExercisesLogged,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else ...[
          Text(
            l10n.sessionLogExercisesLabel,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ...execution.exercises.map(
            (exercise) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                exercise.completed
                    ? Icons.check_circle_outline
                    : Icons.radio_button_unchecked,
              ),
              title: Text(exercise.name),
              subtitle: exercise.sets.isEmpty
                  ? null
                  : Text(
                      exercise.sets
                          .map((s) {
                            final parts = <String>[];
                            if (s.reps.isNotEmpty) parts.add(s.reps);
                            if (s.load.isNotEmpty) parts.add(s.load);
                            return parts.join(' · ');
                          })
                          .where((line) => line.isNotEmpty)
                          .join(' · '),
                    ),
            ),
          ),
        ],
      ],
    );
  }
}

String diaryEntryStatusLabel(AppLocalizations l10n, PlanSessionStatus status) {
  return switch (status) {
    PlanSessionStatus.completed => l10n.sessionCompleted,
    PlanSessionStatus.skipped => l10n.sessionSkipped,
    PlanSessionStatus.planned => l10n.sessionPlanned,
  };
}
