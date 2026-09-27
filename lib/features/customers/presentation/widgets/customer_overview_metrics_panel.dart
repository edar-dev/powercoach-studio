import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
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

    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: MarketingDarkColors.brandLight,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.monitor_heart_outlined,
              size: 16,
              color: MarketingDarkColors.brandLight,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.customerBiometricParamsTitle.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: MarketingDarkColors.slate400,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onAddMeasurement,
              icon: const Icon(Icons.add_circle_outline, size: 16),
              label: Text(l10n.customerRegisterNewMeasurement),
              style: TextButton.styleFrom(
                foregroundColor: MarketingDarkColors.brandLight,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 640;
            final cards = <Widget>[
              _KpiCard(
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
              _KpiCard(
                label: l10n.customerMuscleMass,
                value: snapshot.muscleMassKg == null
                    ? '—'
                    : CustomerOverviewMetrics.formatMetricValue(
                        snapshot.muscleMassKg!,
                        isPercent: false,
                      ),
                unit: 'kg',
                delta: snapshot.muscleMassDelta,
                deltaUnit: 'kg',
                subtitle: snapshot.muscleMassKg == null
                    ? l10n.customerOverviewNoSecondaryData
                    : null,
              ),
              _KpiCard(
                label: l10n.measurementBodyFat,
                value: snapshot.bodyFatPercent == null
                    ? '—'
                    : CustomerOverviewMetrics.formatMetricValue(
                        snapshot.bodyFatPercent!,
                        isPercent: true,
                      ),
                unit: '%',
                delta: snapshot.bodyFatDelta,
                deltaUnit: '%',
                subtitle: snapshot.bodyFatPercent == null
                    ? l10n.customerOverviewNoSecondaryData
                    : null,
              ),
              if (snapshot.sbdTotal != null)
                _KpiCard(
                  label: l10n.measurementSbdTotal,
                  value: CustomerOverviewMetrics.formatMetricValue(
                    snapshot.sbdTotal!,
                    isPercent: false,
                  ),
                  unit: 'kg',
                  delta: snapshot.sbdDelta,
                  deltaUnit: 'kg',
                ),
            ];

            if (wide) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(child: cards[i]),
                    ],
                  ],
                ),
              );
            }

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final card in cards)
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: card,
                  ),
              ],
            );
          },
        ),
        if (snapshot.lastMeasurementDate != null) ...[
          const SizedBox(height: 10),
          Text(
            l10n.customerOverviewLastMeasurement(
              DateFormat.yMMMd(
                Localizations.localeOf(context).toString(),
              ).format(snapshot.lastMeasurementDate!),
            ),
            style: const TextStyle(
              fontSize: 12,
              color: MarketingDarkColors.slate500,
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
            style: const TextStyle(
              fontSize: 14,
              color: MarketingDarkColors.slate400,
            ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 12),
        if (!snapshot.hasMeasurements)
          FilledButton.icon(
            onPressed: onAddMeasurement,
            icon: const Icon(Icons.add, size: 20),
            label: Text(l10n.measurementAdd),
            style: FilledButton.styleFrom(
              backgroundColor: MarketingDarkColors.brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(MarketingDarkColors.radiusXl),
              ),
            ),
          )
        else
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onViewHistory,
              style: TextButton.styleFrom(
                foregroundColor: MarketingDarkColors.brandLight,
              ),
              child: Text(l10n.customerOverviewViewHistory),
            ),
          ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.unit,
    this.subtitle,
    this.delta,
    this.deltaUnit,
  });

  final String label;
  final String value;
  final String unit;
  final String? subtitle;
  final double? delta;
  final String? deltaUnit;

  @override
  Widget build(BuildContext context) {
    final deltaText = delta != null && deltaUnit != null
        ? CustomerOverviewMetrics.formatAbsoluteDelta(delta!, unit: deltaUnit!)
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MarketingDarkColors.surfaceElevated,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl),
        border: Border.all(color: MarketingDarkColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: MarketingDarkColors.slate400,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: MarketingDarkColors.text,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: MarketingDarkColors.slate400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 18,
            child: Align(
              alignment: Alignment.centerLeft,
              child: deltaText != null
                  ? _DeltaChip(text: deltaText, positive: delta! >= 0)
                  : (subtitle != null
                      ? Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: MarketingDarkColors.slate500,
                          ),
                        )
                      : null),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.text, required this.positive});

  final String text;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final color =
        positive ? MarketingDarkColors.emerald : MarketingDarkColors.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
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

    return Container(
      height: 64,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: MarketingDarkColors.surfaceRow.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
        border: Border.all(color: MarketingDarkColors.border.withValues(alpha: 0.7)),
      ),
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
              color: MarketingDarkColors.brandMid,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: MarketingDarkColors.brand.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
