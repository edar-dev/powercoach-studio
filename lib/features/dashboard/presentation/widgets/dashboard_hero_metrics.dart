import 'package:flutter/material.dart';

import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/dashboard_snapshot.dart';
import 'dashboard_surface_card.dart';

/// Four-tile KPI strip at the top of the coach dashboard (Stitch hero metrics).
class DashboardHeroMetrics extends StatelessWidget {
  const DashboardHeroMetrics({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.l10n,
    required this.snapshot,
    required this.loading,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final DashboardSnapshot? snapshot;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final showPlaceholder = loading && snapshot == null;
    final clients = showPlaceholder ? '–' : '${snapshot?.clientCount ?? 0}';
    final programs = showPlaceholder ? '–' : '${snapshot?.activePrograms ?? 0}';
    final weekly = showPlaceholder ? '–' : '${snapshot?.weeklyUpdates ?? 0}';
    final attentionCount = showPlaceholder
        ? null
        : (snapshot?.stalePlans.length ?? 0) +
            (snapshot?.customersWithoutPlan.length ?? 0);
    final attentionValue =
        attentionCount == null ? '–' : '$attentionCount';
    final attentionOk = attentionCount != null && attentionCount == 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 640;
        final tiles = [
          _HeroMetricTile(
            theme: theme,
            colorScheme: colorScheme,
            label: l10n.dashboardMetricAthletes,
            value: clients,
            icon: Icons.groups_outlined,
            iconTint: StitchM3Theme.accent,
          ),
          _HeroMetricTile(
            theme: theme,
            colorScheme: colorScheme,
            label: l10n.dashboardMetricActivePlans,
            value: programs,
            icon: Icons.assignment_outlined,
            iconTint: colorScheme.secondary,
          ),
          _HeroMetricTile(
            theme: theme,
            colorScheme: colorScheme,
            label: l10n.dashboardMetricWeeklyUpdates,
            value: weekly,
            icon: Icons.trending_up,
            iconTint: StitchM3Theme.success,
          ),
          _HeroMetricTile(
            theme: theme,
            colorScheme: colorScheme,
            label: l10n.dashboardMetricCoachAttention,
            value: attentionValue,
            valueSuffix: attentionCount == null
                ? null
                : l10n.dashboardMetricAlertsSuffix,
            valueColor: attentionOk ? StitchM3Theme.success : null,
            icon: attentionOk
                ? Icons.check_circle_outline
                : Icons.warning_amber_outlined,
            iconTint: attentionOk
                ? StitchM3Theme.success
                : StitchM3Theme.warning,
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
    );
  }
}

class _HeroMetricTile extends StatelessWidget {
  const _HeroMetricTile({
    required this.theme,
    required this.colorScheme,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconTint,
    this.valueSuffix,
    this.valueColor,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final String label;
  final String value;
  final String? valueSuffix;
  final Color? valueColor;
  final IconData icon;
  final Color iconTint;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: valueColor ?? colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (valueSuffix != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        valueSuffix!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconTint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
              border: Border.all(color: iconTint.withValues(alpha: 0.22)),
            ),
            child: Icon(icon, size: 20, color: iconTint),
          ),
        ],
      ),
    );
  }
}
