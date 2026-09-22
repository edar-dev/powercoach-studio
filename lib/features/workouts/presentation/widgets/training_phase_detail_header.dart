import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/workout_phase_presets.dart';

/// Header for the selected phase: name, objective, duration, frequency, progress.
class TrainingPhaseDetailHeader extends StatelessWidget {
  const TrainingPhaseDetailHeader({
    super.key,
    required this.phase,
    required this.phaseIndex,
    required this.progressPercent,
    required this.onDuplicate,
    required this.onSettings,
    this.onDelete,
    this.readOnly = false,
  });

  final Phase phase;
  final int phaseIndex;
  final int progressPercent;
  final VoidCallback onDuplicate;
  final VoidCallback onSettings;
  final VoidCallback? onDelete;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final name = localizedPhaseName(l10n, phase.name);
    final avgSessions = phaseAverageSessionsPerWeek(phase).round();
    final objective = phase.objective?.trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.workoutPhaseNumbered(phaseIndex + 1),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (!readOnly) ...[
                TextButton(
                  onPressed: onDuplicate,
                  child: Text(l10n.workoutPhaseDuplicate),
                ),
                TextButton(
                  onPressed: onSettings,
                  child: Text(l10n.workoutPhaseSettings),
                ),
                if (onDelete != null)
                  IconButton(
                    tooltip: l10n.workoutPhaseDeleteMenu,
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline, color: cs.error),
                  ),
              ],
            ],
          ),
          if (objective != null && objective.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${l10n.workoutPhaseObjectiveLabel}: ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: objective,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _MetaChip(
                label: l10n.workoutPhaseDurationLabel,
                value: l10n.workoutPhaseWeeksCount(phase.weeks.length),
              ),
              _MetaChip(
                label: l10n.workoutPhaseFrequencyLabel,
                value: l10n.workoutPhaseFrequencyValue(avgSessions),
              ),
              _MetaChip(
                label: l10n.workoutPhaseProgressLabel,
                value: l10n.workoutPhaseProgressValue(progressPercent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPercent / 100,
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
