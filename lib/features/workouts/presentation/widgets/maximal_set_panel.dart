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
    this.sourceLabel,
    this.onSetMaximal,
    this.onRetryLoad,
    this.enabled = true,
    this.loading = false,
    this.loadFailed = false,
    this.isSandbox = false,
  });

  final MaximalRef? maximalRef;
  final double? maximalKg;

  /// Human-readable linked source (lift name or custom label), when known.
  final String? sourceLabel;
  final MaximalResolveMode resolveMode;
  final ValueChanged<MaximalResolveMode> onResolveModeChanged;
  final bool showResolveModeToggle;
  final int percent;
  final ValueChanged<int> onPercentChanged;
  final double incrementKg;
  final ValueChanged<String> onApplyLoad;
  final VoidCallback? onSetMaximal;
  final VoidCallback? onRetryLoad;
  final bool enabled;
  final bool loading;
  final bool loadFailed;
  final bool isSandbox;

  bool get _hasResolvedKg => maximalKg != null && maximalKg! > 0;
  bool get _hasOrphanLink => maximalRef != null && !_hasResolvedKg;
  bool get _canApply => enabled && !loading && !loadFailed && _hasResolvedKg;

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
              sourceLabel: sourceLabel,
              loading: loading,
              enabled: enabled && !isSandbox,
              hasOrphanLink: _hasOrphanLink,
              onSetMaximal: onSetMaximal,
            ),
            if (isSandbox) ...[
              const SizedBox(height: 6),
              Text(
                l10n.maximalSandboxHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ] else if (loadFailed) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.maximalLoadError,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.error,
                      ),
                    ),
                  ),
                  if (onRetryLoad != null)
                    TextButton(
                      onPressed: loading ? null : onRetryLoad,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(l10n.cloudSaveRetryAction),
                    ),
                ],
              ),
            ] else if (!_hasResolvedKg && !loading) ...[
              const SizedBox(height: 6),
              Text(
                _hasOrphanLink ? l10n.maximalOrphanHint : l10n.maximalEmptyHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
            if (showResolveModeToggle && _hasResolvedKg) ...[
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
                showSelectedIcon: false,
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
            if (_hasResolvedKg) ...[
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
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.maximalRoundingIncrementHint(
                    formatMaximalDisplayKg(incrementKg),
                  ),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
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
    required this.hasOrphanLink,
    this.sourceLabel,
    this.onSetMaximal,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final double? maximalKg;
  final String? sourceLabel;
  final bool loading;
  final bool enabled;
  final bool hasOrphanLink;
  final VoidCallback? onSetMaximal;

  @override
  Widget build(BuildContext context) {
    final hasKg = maximalKg != null && maximalKg! > 0;
    final source = sourceLabel?.trim();
    final showSource = source != null && source.isNotEmpty && hasKg;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: loading
              ? Text(
                  l10n.maximalLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasKg
                          ? l10n.maximalHeaderWithKg(
                              formatMaximalDisplayKg(maximalKg!),
                            )
                          : '${l10n.maximalLabel}: —',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: hasKg ? FontWeight.w700 : FontWeight.w600,
                        color: hasKg ? null : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (showSource) ...[
                      const SizedBox(height: 2),
                      Text(
                        source,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
        if (loading)
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (!hasKg && !hasOrphanLink)
          FilledButton.tonal(
            onPressed: enabled ? onSetMaximal : null,
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(l10n.maximalSetCta),
          )
        else
          TextButton(
            onPressed: enabled ? onSetMaximal : null,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(l10n.maximalSetCtaChange),
          ),
      ],
    );
  }
}
