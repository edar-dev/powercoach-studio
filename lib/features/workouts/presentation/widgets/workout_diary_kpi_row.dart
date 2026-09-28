import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/workout_diary_metrics.dart';

/// Three KPI summary cards for the diary (sessions, volume, compliance).
class WorkoutDiaryKpiRow extends StatelessWidget {
  const WorkoutDiaryKpiRow({super.key, required this.kpis});

  final WorkoutDiaryKpis kpis;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final volumeValue = kpis.hasParsableVolume
        ? '${formatVolumeKg(kpis.volumeKg)} ${l10n.workoutDiaryKpiVolumeUnit}'
        : kpis.setCount > 0
        ? l10n.workoutDiarySetsCount(kpis.setCount)
        : l10n.workoutDiaryExercisesCount(kpis.exerciseCount);
    final complianceValue = kpis.compliancePercent == null
        ? '—'
        : '${kpis.compliancePercent}%';
    final complianceHint = kpis.skippedCount > 0
        ? l10n.workoutDiaryKpiSkipped(kpis.skippedCount)
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final cards = [
          _KpiCard(
            label: l10n.workoutDiaryKpiSessions,
            value: '${kpis.completedCount}',
            icon: Icons.check_circle_outline,
            iconBg: const Color(0x1A34D399),
            iconColor: MarketingDarkColors.emerald,
            iconBorder: const Color(0x3334D399),
          ),
          _KpiCard(
            label: l10n.workoutDiaryKpiVolume,
            value: volumeValue,
            icon: Icons.fitness_center,
            iconBg: MarketingDarkColors.cyanBright.withValues(alpha: 0.1),
            iconColor: MarketingDarkColors.cyanBright,
            iconBorder: MarketingDarkColors.cyanBright.withValues(alpha: 0.2),
          ),
          _KpiCard(
            label: l10n.workoutDiaryKpiCompliance,
            value: complianceValue,
            hint: complianceHint,
            icon: Icons.track_changes_outlined,
            iconBg: MarketingDarkColors.brand.withValues(alpha: 0.12),
            iconColor: MarketingDarkColors.brandLight,
            iconBorder: MarketingDarkColors.brand.withValues(alpha: 0.25),
          ),
        ];

        if (wide) {
          return Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 12),
                Expanded(child: cards[1]),
              ],
            ),
            const SizedBox(height: 12),
            cards[2],
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.iconBorder,
    this.hint,
  });

  final String label;
  final String value;
  final String? hint;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color iconBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MarketingDarkColors.stitchCardElevated,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
        border: Border.all(
          color: MarketingDarkColors.stitchBorder.withValues(alpha: 0.9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: MarketingDarkColors.slate400,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: iconBorder),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: MarketingDarkColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(
              hint!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: MarketingDarkColors.slate500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
