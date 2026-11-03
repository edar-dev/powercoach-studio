import 'package:flutter/material.dart';

import '../../domain/maximal_load_math.dart';

/// Preset % chip row for the Massimali set editor (`50…95`).
class MaximalPercentChips extends StatelessWidget {
  const MaximalPercentChips({
    super.key,
    required this.onPercentSelected,
    this.selectedPercent,
    this.enabled = true,
  });

  final ValueChanged<int> onPercentSelected;
  final int? selectedPercent;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final percent in kMaximalPercentPresets)
          _PercentChip(
            percent: percent,
            selected: selectedPercent == percent,
            enabled: enabled,
            colorScheme: cs,
            onSelected: () => onPercentSelected(percent),
          ),
      ],
    );
  }
}

class _PercentChip extends StatelessWidget {
  const _PercentChip({
    required this.percent,
    required this.selected,
    required this.enabled,
    required this.colorScheme,
    required this.onSelected,
  });

  final int percent;
  final bool selected;
  final bool enabled;
  final ColorScheme colorScheme;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text('$percent%'),
      selected: selected,
      showCheckmark: false,
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: !enabled
            ? colorScheme.onSurface.withValues(alpha: 0.38)
            : selected
                ? colorScheme.onPrimary
                : colorScheme.onSurface,
      ),
      selectedColor: colorScheme.primary,
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.55,
      ),
      side: BorderSide(
        color: selected
            ? colorScheme.primary
            : colorScheme.outlineVariant.withValues(alpha: 0.7),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: enabled ? (_) => onSelected() : null,
    );
  }
}
