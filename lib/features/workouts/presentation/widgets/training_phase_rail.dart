import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/workout_phase_presets.dart';

/// Horizontal / vertical rail of phases (Stitch phase pills).
class TrainingPhaseRail extends StatelessWidget {
  const TrainingPhaseRail({
    super.key,
    required this.phases,
    required this.selectedPhaseIndex,
    required this.onSelectPhase,
    this.onAddPhase,
    this.vertical = false,
  });

  final List<Phase> phases;
  final int selectedPhaseIndex;
  final ValueChanged<int> onSelectPhase;
  final VoidCallback? onAddPhase;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final chips = <Widget>[
      for (var i = 0; i < phases.length; i++)
        _PhaseChip(
          index: i,
          phase: phases[i],
          selected: i == selectedPhaseIndex,
          onTap: () => onSelectPhase(i),
          l10n: l10n,
          theme: theme,
          cs: cs,
        ),
      if (onAddPhase != null)
        OutlinedButton.icon(
          onPressed: onAddPhase,
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.workoutPhaseAdd),
        ),
    ];

    if (vertical) {
      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final chip in chips) ...[
            chip,
            const SizedBox(height: 8),
          ],
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          for (var i = 0; i < chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            chips[i],
          ],
        ],
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({
    required this.index,
    required this.phase,
    required this.selected,
    required this.onTap,
    required this.l10n,
    required this.theme,
    required this.cs,
  });

  final int index;
  final Phase phase;
  final bool selected;
  final VoidCallback onTap;
  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final label = localizedPhaseName(l10n, phase.name);
    final weeksLabel = l10n.workoutPhaseWeeksCount(phase.weeks.length);
    final bg = selected ? cs.primary : cs.surfaceContainerHighest;
    final fg = selected ? cs.onPrimary : cs.onSurface;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.workoutPhaseNumbered(index + 1),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: fg.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                weeksLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: fg.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
