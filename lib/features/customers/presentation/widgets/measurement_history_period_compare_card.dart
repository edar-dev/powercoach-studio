import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/measurement_period_compare.dart';

class MeasurementHistoryPeriodCompareCard extends StatelessWidget {
  const MeasurementHistoryPeriodCompareCard({
    super.key,
    required this.delta,
    required this.metricLabel,
  });

  final MeasurementPeriodDelta delta;
  final String metricLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final percent = delta.percentChange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.measurementHistoryCompareTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.measurementHistoryCompareSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (delta.recentCount == 0 && delta.previousCount == 0)
              Text(
                l10n.measurementHistoryCompareInsufficient,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else ...[
              MeasurementHistoryCompareRow(
                label: l10n.measurementHistoryCompareRecent,
                value: delta.recentAverage,
                count: delta.recentCount,
              ),
              const SizedBox(height: 8),
              MeasurementHistoryCompareRow(
                label: l10n.measurementHistoryComparePrevious,
                value: delta.previousAverage,
                count: delta.previousCount,
              ),
              if (percent != null) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.measurementHistoryCompareDelta(
                    metricLabel,
                    _formatSignedPercent(percent),
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: percent <= 0 ? colorScheme.tertiary : colorScheme.error,
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
  });

  final String label;
  final double? value;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final valueLabel = value == null
        ? l10n.measurementHistoryCompareNoData
        : value!.toStringAsFixed(1);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Text(
          valueLabel,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.measurementHistoryCompareSampleCount(count),
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
