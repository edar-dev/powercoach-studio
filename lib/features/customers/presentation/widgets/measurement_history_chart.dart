import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/measurement_series_builder.dart';

class MeasurementHistoryChart extends StatelessWidget {
  const MeasurementHistoryChart({
    super.key,
    required this.points,
    required this.metricLabel,
    required this.dateAxisLabel,
    required this.valueAxisLabel,
  });

  final List<MeasurementChartPoint> points;
  final String metricLabel;
  final String dateAxisLabel;
  final String valueAxisLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();

    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final minY = points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final yPadding = (maxY - minY).abs() * 0.1;
    final chartMinY = minY - (yPadding == 0 ? 1 : yPadding);
    final chartMaxY = maxY + (yPadding == 0 ? 1 : yPadding);

    return Semantics(
      label: metricLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            metricLabel,
            style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 260,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: points.length > 1 ? (points.length - 1).toDouble() : 1,
                minY: chartMinY,
                maxY: chartMaxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: colorScheme.outline),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text(
                      dateAxisLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: _bottomTitleInterval(points.length),
                      getTitlesWidget: (value, meta) {
                        final index = value.round();
                        if (index < 0 || index >= points.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat.Md(locale).format(points[index].date),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(
                      valueAxisLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatAxisValue(value),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => colorScheme.inverseSurface,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.round().clamp(0, points.length - 1);
                        final point = points[index];
                        final dateLabel = DateFormat.yMMMd(locale).format(point.date);
                        return LineTooltipItem(
                          '$dateLabel\n${_formatAxisValue(point.value)}',
                          TextStyle(color: colorScheme.onInverseSurface),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < points.length; i++)
                        FlSpot(i.toDouble(), points[i].value),
                    ],
                    isCurved: points.length > 2,
                    color: colorScheme.primary,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: points.length <= 24,
                      getDotPainter: (spot, percent, bar, index) {
                        final isLast = index == points.length - 1;
                        return FlDotCirclePainter(
                          radius: isLast ? 5 : 3,
                          color: isLast ? colorScheme.tertiary : colorScheme.primary,
                          strokeWidth: isLast ? 2 : 0,
                          strokeColor: colorScheme.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: colorScheme.primary.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _bottomTitleInterval(int count) {
    if (count <= 4) {
      return 1;
    }
    if (count <= 8) {
      return 2;
    }
    return (count / 4).ceilToDouble();
  }

  String _formatAxisValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}

String measurementHistoryNoMetricDataMessage(AppLocalizations l10n) {
  return l10n.measurementHistoryNoMetricData;
}
