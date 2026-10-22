import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/maximal_load_math.dart';

/// 40–100% slider (step 1) with rounded-kg readout for the Massimali panel.
class MaximalPercentSlider extends StatelessWidget {
  const MaximalPercentSlider({
    super.key,
    required this.percent,
    required this.onChanged,
    this.maximalKg,
    this.incrementKg = 2.5,
    this.enabled = true,
  });

  final int percent;
  final ValueChanged<int> onChanged;
  final double? maximalKg;
  final double incrementKg;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final clamped = percent.clamp(
      kMaximalPercentSliderMin,
      kMaximalPercentSliderMax,
    );
    final kg = maximalKg == null
        ? null
        : applyPercentRounded(
            maximalKg: maximalKg!,
            percent: clamped,
            incrementKg: incrementKg,
          );
    final kgLabel = kg == null ? '—' : formatMaximalDisplayKg(kg);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.maximalPercentReadout(clamped, kgLabel),
          style: theme.textTheme.labelLarge?.copyWith(
            color: enabled
                ? cs.onSurface
                : cs.onSurface.withValues(alpha: 0.38),
            fontWeight: FontWeight.w600,
          ),
        ),
        Slider(
          value: clamped.toDouble(),
          min: kMaximalPercentSliderMin.toDouble(),
          max: kMaximalPercentSliderMax.toDouble(),
          divisions: kMaximalPercentSliderMax - kMaximalPercentSliderMin,
          label: '$clamped%',
          onChanged: enabled
              ? (value) => onChanged(value.round())
              : null,
        ),
      ],
    );
  }

}
