import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

import '../customer_list_metrics.dart';

/// Four compact KPI cards above the customers toolbar (Stitch metrics bar).
class CustomerListMetricsBar extends StatelessWidget {
  const CustomerListMetricsBar({
    super.key,
    required this.metrics,
  });

  final CustomerListMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 640;
          final tiles = [
            _MetricCard(
              label: l10n.customersMetricTotalAthletes,
              value: '${metrics.totalAthletes}',
              subtitle: l10n.customersMetricActiveCount(metrics.activeCount),
              subtitleColor: MarketingDarkColors.emerald,
              icon: Icons.groups_outlined,
              iconTint: MarketingDarkColors.brandLight,
              iconBg: MarketingDarkColors.brand.withValues(alpha: 0.12),
              iconBorder: MarketingDarkColors.brandMid.withValues(alpha: 0.25),
            ),
            _MetricCard(
              label: l10n.customersMetricPlansInProgress,
              value: '${metrics.plansInProgress}',
              subtitle: l10n.customersMetricPlansSubtitle,
              subtitleColor: MarketingDarkColors.slate400,
              icon: Icons.assignment_outlined,
              iconTint: MarketingDarkColors.brandLight,
              iconBg: const Color(0xFF3B82F6).withValues(alpha: 0.12),
              iconBorder: const Color(0xFF3B82F6).withValues(alpha: 0.25),
            ),
            _MetricCard(
              label: l10n.customersMetricPaused,
              value: '${metrics.pausedCount}',
              subtitle: l10n.customersMetricPausedSubtitle,
              subtitleColor: MarketingDarkColors.slate400,
              icon: Icons.pause_circle_outline,
              iconTint: MarketingDarkColors.emerald,
              iconBg: MarketingDarkColors.emerald.withValues(alpha: 0.12),
              iconBorder: MarketingDarkColors.emerald.withValues(alpha: 0.25),
            ),
            _MetricCard(
              label: l10n.customersMetricNeedsUpdate,
              value: '${metrics.needsUpdateCount}',
              valueColor: MarketingDarkColors.amber,
              subtitle: l10n.customersMetricNeedsUpdateSubtitle,
              subtitleColor: MarketingDarkColors.amberSoft.withValues(alpha: 0.85),
              icon: Icons.schedule_outlined,
              iconTint: MarketingDarkColors.amber,
              iconBg: MarketingDarkColors.amber.withValues(alpha: 0.12),
              iconBorder: MarketingDarkColors.amber.withValues(alpha: 0.25),
            ),
          ];

          if (wide) {
            return Row(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(child: tiles[i]),
                ],
              ],
            );
          }

          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: tiles[0]),
                  const SizedBox(width: 12),
                  Expanded(child: tiles[1]),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: tiles[2]),
                  const SizedBox(width: 12),
                  Expanded(child: tiles[3]),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.subtitleColor,
    required this.icon,
    required this.iconTint,
    required this.iconBg,
    required this.iconBorder,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final String subtitle;
  final Color subtitleColor;
  final IconData icon;
  final Color iconTint;
  final Color iconBg;
  final Color iconBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
        border: Border.all(
          color: MarketingDarkColors.border.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                    color: MarketingDarkColors.slate400,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: valueColor ?? MarketingDarkColors.text,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: subtitleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: iconBorder),
            ),
            child: Icon(icon, size: 20, color: iconTint),
          ),
        ],
      ),
    );
  }
}
