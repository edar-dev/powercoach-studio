import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/workout_phase_presets.dart';

/// Meta chips grid for the selected phase (Stitch phase detail row).
///
/// Actions (duplicate / settings / delete) live on [TrainingPhaseRail].
class TrainingPhaseDetailHeader extends StatelessWidget {
  const TrainingPhaseDetailHeader({
    super.key,
    required this.phase,
    required this.phaseIndex,
    required this.progressPercent,
    this.onDuplicate,
    this.onSettings,
    this.onDelete,
    this.readOnly = false,
  });

  final Phase phase;
  final int phaseIndex;
  final int progressPercent;

  /// Kept for API compatibility; prefer rail trailing actions.
  final VoidCallback? onDuplicate;
  final VoidCallback? onSettings;
  final VoidCallback? onDelete;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final avgSessions = phaseAverageSessionsPerWeek(phase).round();
    final objective = phase.objective?.trim();

    final chips = <Widget>[
      if (objective != null && objective.isNotEmpty)
        _MetaChip(
          label: l10n.workoutPhaseObjectiveLabel,
          value: objective,
          cs: cs,
          theme: theme,
        ),
      _MetaChip(
        label: l10n.workoutPhaseDurationLabel,
        value: l10n.workoutPhaseWeeksCount(phase.weeks.length),
        cs: cs,
        theme: theme,
        valueColor: cs.primary,
      ),
      _MetaChip(
        label: l10n.workoutPhaseFrequencyLabel,
        value: l10n.workoutPhaseFrequencyValue(avgSessions),
        cs: cs,
        theme: theme,
      ),
      _ProgressMetaChip(
        label: l10n.workoutPhaseProgressLabel,
        percent: progressPercent,
        percentLabel: l10n.workoutPhaseProgressValue(progressPercent),
        cs: cs,
        theme: theme,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!readOnly &&
            (onDuplicate != null || onSettings != null || onDelete != null))
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 4,
              children: [
                if (onDelete != null)
                  IconButton(
                    tooltip: l10n.workoutPhaseDeleteMenu,
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline, color: cs.error, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 1100
                ? 4
                : width >= 700
                    ? 3
                    : width >= 420
                        ? 2
                        : 1;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: columns == 1 ? 4.8 : 3.6,
              children: chips,
            );
          },
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.value,
    required this.cs,
    required this.theme,
    this.valueColor,
  });

  final String label;
  final String value;
  final ColorScheme cs;
  final ThemeData theme;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Text(
            '$label:',
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: valueColor ?? cs.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressMetaChip extends StatelessWidget {
  const _ProgressMetaChip({
    required this.label,
    required this.percent,
    required this.percentLabel,
    required this.cs,
    required this.theme,
  });

  final String label;
  final int percent;
  final String percentLabel;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Text(
            '$label:',
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: (percent.clamp(0, 100)) / 100,
                minHeight: 6,
                backgroundColor: cs.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            percentLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
