import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

/// Uppercase section label in the training week/day planner.
class TrainingSectionLabel extends StatelessWidget {
  const TrainingSectionLabel({
    super.key,
    required this.text,
    required this.theme,
    required this.colorScheme,
  });

  final String text;
  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

/// Selectable week/day chip in the training planner.
class TrainingPlannerChip extends StatelessWidget {
  const TrainingPlannerChip({
    super.key,
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

/// Day chip that supports swipe-up to delete when multiple days exist.
class TrainingSwipeableDayChip extends StatelessWidget {
  const TrainingSwipeableDayChip({
    super.key,
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
    final chip = TrainingPlannerChip(label: label, selected: selected, onTap: onTap);
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

/// Add chip for weeks/days in the training planner.
class TrainingPlannerAddChip extends StatelessWidget {
  const TrainingPlannerAddChip({
    super.key,
    required this.label,
    required this.onTap,
  });

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
