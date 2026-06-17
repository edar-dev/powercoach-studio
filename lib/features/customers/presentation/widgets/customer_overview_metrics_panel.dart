import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../domain/customer_overview_metrics.dart';
import '../../domain/measurement_series_builder.dart';

class CustomerOverviewMetricsPanel extends StatelessWidget {
  const CustomerOverviewMetricsPanel({
    super.key,
    required this.snapshot,
    required this.loading,
    required this.onAddMeasurement,
    required this.onViewHistory,
  });

  final CustomerOverviewSnapshot snapshot;
  final bool loading;
  final VoidCallback onAddMeasurement;
  final VoidCallback onViewHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _OverviewStatCard(
                  label: l10n.customerCurrentWeight,
                  value: snapshot.weightKg == null
                      ? '—'
                      : CustomerOverviewMetrics.formatMetricValue(
                          snapshot.weightKg!,
                          isPercent: false,
                        ),
                  unit: 'kg',
                  subtitle: snapshot.weightFromProfile
                      ? l10n.customerOverviewFromProfile
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _OverviewStatCard(
                  label: snapshot.secondaryLabel,
                  value: snapshot.secondaryValue == null
                      ? '—'
                      : CustomerOverviewMetrics.formatMetricValue(
                          snapshot.secondaryValue!,
                          isPercent: snapshot.secondaryUnit == '%',
                        ),
                  unit: snapshot.secondaryUnit,
                  subtitle: snapshot.secondaryValue == null &&
                          snapshot.showSecondaryTrend == false
                      ? l10n.customerOverviewNoSecondaryData
                      : null,
                  trendText: snapshot.showSecondaryTrend
                      ? CustomerOverviewMetrics.formatTrendPercent(
                          snapshot.secondaryTrend!.percentChange!,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
        if (snapshot.lastMeasurementDate != null) ...[
          const SizedBox(height: 8),
          Text(
            l10n.customerOverviewLastMeasurement(
              DateFormat.yMMMd(
                Localizations.localeOf(context).toString(),
              ).format(snapshot.lastMeasurementDate!),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (snapshot.sparklinePoints.isNotEmpty)
          _OverviewSparkline(points: snapshot.sparklinePoints)
        else
          Text(
            !snapshot.hasMeasurements && snapshot.weightFromProfile
                ? l10n.customerOverviewProfileWeightHint
                : l10n.customerOverviewNoMeasurements,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 12),
        if (!snapshot.hasMeasurements)
          FilledButton.icon(
            onPressed: onAddMeasurement,
            icon: const Icon(Icons.add, size: 20),
            label: Text(l10n.measurementAdd),
          )
        else
          TextButton(
            onPressed: onViewHistory,
            child: Text(l10n.customerOverviewViewHistory),
          ),
      ],
    );
  }
}

class _OverviewStatCard extends StatelessWidget {
  const _OverviewStatCard({
    required this.label,
    required this.value,
    required this.unit,
    this.subtitle,
    this.trendText,
  });

  final String label;
  final String value;
  final String unit;
  final String? subtitle;
  final String? trendText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusXl),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 18,
            child: Align(
              alignment: Alignment.centerLeft,
              child: subtitle != null
                  ? Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    )
                  : trendText != null
                      ? Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              size: 14,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              trendText!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewSparkline extends StatelessWidget {
  const _OverviewSparkline({required this.points});

  final List<MeasurementChartPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final minY = points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY).abs() * 0.15;

    return SizedBox(
      height: 56,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: points.length > 1 ? (points.length - 1).toDouble() : 1,
          minY: minY - (padding == 0 ? 1 : padding),
          maxY: maxY + (padding == 0 ? 1 : padding),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), points[i].value),
              ],
              isCurved: true,
              color: StitchM3Theme.accent,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: StitchM3Theme.accent.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
