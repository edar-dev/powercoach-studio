import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/coach_stats_loader.dart';

/// Bar chart of completed sessions per day for the selected period.
class CoachStatsAdherenceChart extends StatelessWidget {
  const CoachStatsAdherenceChart({
    super.key,
    required this.points,
    required this.l10n,
    this.onDaySelected,
  });

  final List<CoachStatsDailyPoint> points;
  final AppLocalizations l10n;
  final void Function(CoachStatsDailyPoint point)? onDaySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final locale = l10n.localeName;
    final maxY = points.fold<int>(
      0,
      (max, point) => point.completedCount > max ? point.completedCount : max,
    );
    final chartMaxY = maxY == 0 ? 1.0 : maxY.toDouble() + 1;
    final hasData = points.any((point) => point.completedCount > 0);
    final dateFormat = DateFormat.Md(locale);

    if (!hasData) {
      return Card(
        elevation: 0,
        color: cs.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.coachStatsChartTitle,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.coachStatsChartEmpty,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.coachStatsChartTitle,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: chartMaxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: chartMaxY <= 4 ? 1 : null,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          if (value != value.roundToDouble()) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: points.length <= 7 ? 1 : 5,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= points.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              dateFormat.format(points[index].date),
                              style: theme.textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < points.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: points[i].completedCount.toDouble(),
                            color: cs.primary,
                            width: points.length <= 7 ? 18 : 8,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                  ],
                  barTouchData: BarTouchData(
                    enabled: onDaySelected != null,
                    touchCallback: (event, response) {
                      if (!event.isInterestedForInteractions ||
                          response?.spot == null) {
                        return;
                      }
                      final index = response!.spot!.touchedBarGroup.x;
                      if (index >= 0 && index < points.length) {
                        onDaySelected?.call(points[index]);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
