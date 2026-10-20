import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/maximal_load_math.dart';
import '../../domain/maximal_ref.dart';
import 'maximal_percent_chips.dart';
import 'maximal_percent_slider.dart';

/// Massimale header + resolve-mode toggle + % chips/slider for the set editor.
///
/// Pure presentation: callers resolve kg and supply [onApplyLoad] with a
/// formatted load string (e.g. `"80kg"`). [onSetMaximal] opens associate/edit.
class MaximalSetPanel extends StatelessWidget {
  const MaximalSetPanel({
    super.key,
    required this.maximalRef,
    required this.maximalKg,
    required this.resolveMode,
    required this.onResolveModeChanged,
    required this.showResolveModeToggle,
    required this.percent,
    required this.onPercentChanged,
    required this.incrementKg,
    required this.onApplyLoad,
    this.onSetMaximal,
    this.enabled = true,
    this.loading = false,
  });

  final MaximalRef? maximalRef;
  final double? maximalKg;
  final MaximalResolveMode resolveMode;
  final ValueChanged<MaximalResolveMode> onResolveModeChanged;
  final bool showResolveModeToggle;
  final int percent;
  final ValueChanged<int> onPercentChanged;
  final double incrementKg;
  final ValueChanged<String> onApplyLoad;
  final VoidCallback? onSetMaximal;
  final bool enabled;
  final bool loading;

  bool get _hasResolvedKg => maximalKg != null && maximalKg! > 0;
  bool get _canApply => enabled && !loading && _hasResolvedKg;

  void _applyPercent(int nextPercent) {
    onPercentChanged(nextPercent);
    if (!_canApply) return;
    final kg = applyPercentRounded(
      maximalKg: maximalKg!,
      percent: nextPercent,
      incrementKg: incrementKg,
    );
    onApplyLoad(formatMaximalLoadKg(kg));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              l10n: l10n,
              theme: theme,
              colorScheme: cs,
              maximalKg: maximalKg,
              loading: loading,
              enabled: enabled,
              onSetMaximal: onSetMaximal,
            ),
            if (showResolveModeToggle) ...[
              const SizedBox(height: 8),
              SegmentedButton<MaximalResolveMode>(
                segments: [
                  ButtonSegment(
                    value: MaximalResolveMode.ultimo,
                    label: Text(l10n.maximalToggleLatest),
                  ),
                  ButtonSegment(
                    value: MaximalResolveMode.massimoStorico,
                    label: Text(l10n.maximalToggleHistoricMax),
                  ),
                ],
                selected: {resolveMode},
                onSelectionChanged: enabled && !loading
                    ? (next) {
                        if (next.isEmpty) return;
                        onResolveModeChanged(next.first);
                      }
                    : null,
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
            const SizedBox(height: 10),
            MaximalPercentChips(
              selectedPercent: percent,
              enabled: _canApply,
              onPercentSelected: _applyPercent,
            ),
            const SizedBox(height: 4),
            MaximalPercentSlider(
              percent: percent,
              maximalKg: maximalKg,
              incrementKg: incrementKg,
              enabled: _canApply,
              onChanged: _applyPercent,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.l10n,
    required this.theme,
    required this.colorScheme,
    required this.maximalKg,
    required this.loading,
    required this.enabled,
    this.onSetMaximal,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final double? maximalKg;
  final bool loading;
  final bool enabled;
  final VoidCallback? onSetMaximal;

  @override
  Widget build(BuildContext context) {
    final hasKg = maximalKg != null && maximalKg! > 0;
    return Row(
      children: [
        Expanded(
          child: loading
              ? Text(
                  l10n.maximalLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                )
              : hasKg
                  ? Text(
                      l10n.maximalHeaderWithKg(_formatHeaderKg(maximalKg!)),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : Text(
                      '${l10n.maximalLabel}: —',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
        ),
        if (loading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          TextButton(
            onPressed: enabled ? onSetMaximal : null,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(hasKg ? l10n.maximalSetCtaChange : l10n.maximalSetCta),
          ),
      ],
    );
  }

  static String _formatHeaderKg(double kg) {
    final asInt = kg.round();
    if ((kg - asInt).abs() < 1e-6) return asInt.toString();
    final oneDecimal = (kg * 10).round() / 10.0;
    if ((oneDecimal - oneDecimal.roundToDouble()).abs() < 1e-9) {
      return oneDecimal.round().toString();
    }
    return oneDecimal.toStringAsFixed(1);
  }
}
