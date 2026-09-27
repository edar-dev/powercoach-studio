import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/measurement_period_compare.dart';

class MeasurementHistoryPeriodCompareCard extends StatelessWidget {
  const MeasurementHistoryPeriodCompareCard({
    super.key,
    required this.delta,
    required this.metricLabel,
    this.dark = false,
  });

  final MeasurementPeriodDelta delta;
  final String metricLabel;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final percent = delta.percentChange;
    final onSurface = dark ? const Color(0xFFF1F5F9) : null;
    final onVariant =
        dark ? const Color(0xFF94A3B8) : colorScheme.onSurfaceVariant;
    final cardColor = dark ? const Color(0xFF0C1220) : null;
    final borderColor = dark ? const Color(0xFF1E293B) : null;

    return Card(
      color: cardColor,
      elevation: dark ? 0 : null,
      shape: dark
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: borderColor!),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.measurementHistoryCompareTitle,
              style: theme.textTheme.titleMedium?.copyWith(color: onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.measurementHistoryCompareSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(color: onVariant),
            ),
            const SizedBox(height: 16),
            if (delta.recentCount == 0 && delta.previousCount == 0)
              Text(
                l10n.measurementHistoryCompareInsufficient,
                style: theme.textTheme.bodyMedium?.copyWith(color: onVariant),
              )
            else ...[
              MeasurementHistoryCompareRow(
                label: l10n.measurementHistoryCompareRecent,
                value: delta.recentAverage,
                count: delta.recentCount,
                dark: dark,
              ),
              const SizedBox(height: 8),
              MeasurementHistoryCompareRow(
                label: l10n.measurementHistoryComparePrevious,
                value: delta.previousAverage,
                count: delta.previousCount,
                dark: dark,
              ),
              if (percent != null) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.measurementHistoryCompareDelta(
                    metricLabel,
                    _formatSignedPercent(percent),
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: percent <= 0
                        ? (dark
                            ? const Color(0xFF34D399)
                            : colorScheme.tertiary)
                        : (dark
                            ? const Color(0xFFFBBF24)
                            : colorScheme.error),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _formatSignedPercent(double value) {
    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }
}

class MeasurementHistoryCompareRow extends StatelessWidget {
  const MeasurementHistoryCompareRow({
    super.key,
    required this.label,
    required this.value,
    required this.count,
    this.dark = false,
  });

  final String label;
  final double? value;
  final int count;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final valueLabel = value == null
        ? l10n.measurementHistoryCompareNoData
        : value!.toStringAsFixed(1);
    final onSurface = dark ? const Color(0xFFF1F5F9) : null;
    final onVariant =
        dark ? const Color(0xFF94A3B8) : colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: onSurface),
          ),
        ),
        Text(
          valueLabel,
          style: theme.textTheme.titleSmall?.copyWith(color: onSurface),
        ),
        const SizedBox(width: 8),
        Text(
          l10n.measurementHistoryCompareSampleCount(count),
          style: theme.textTheme.labelSmall?.copyWith(color: onVariant),
        ),
      ],
    );
  }
}
