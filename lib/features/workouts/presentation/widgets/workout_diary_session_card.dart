import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/domain/plan_calendar_event.dart';
import '../../domain/session_execution_service.dart';
import '../../domain/workout_diary_metrics.dart';

/// Session row card for the diary timeline.
class WorkoutDiarySessionCard extends StatelessWidget {
  const WorkoutDiarySessionCard({
    super.key,
    required this.entry,
    required this.customerName,
    required this.onTap,
  });

  final SessionExecutionEntry entry;
  final String customerName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!Breakpoints.isTabletOrWider(context)) {
      return _PhoneCard(
        entry: entry,
        customerName: customerName,
        onTap: onTap,
      );
    }
    return _DesktopCard(
      entry: entry,
      customerName: customerName,
      onTap: onTap,
    );
  }
}

class _PhoneCard extends StatelessWidget {
  const _PhoneCard({
    required this.entry,
    required this.customerName,
    required this.onTap,
  });

  final SessionExecutionEntry entry;
  final String customerName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final execution = entry.execution;
    final isSkipped = execution.status == PlanSessionStatus.skipped;
    final metrics = computeSessionMetrics(execution);
    final statusLabel = isSkipped
        ? l10n.sessionSkipped
        : l10n.sessionCompleted;
    final statusColor = isSkipped
        ? StitchMobileColors.error
        : StitchMobileColors.tertiary;
    final title = entry.planName.trim().isEmpty
        ? customerName
        : entry.planName;
    final volumeText = metrics.hasParsableVolume
        ? '${formatVolumeKg(metrics.volumeKg)} kg'
        : '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StitchMobileColors.surfaceContainer,
        borderRadius: BorderRadius.circular(StitchMobileColors.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: StitchMobileColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: StitchMobileColors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!isSkipped) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: StitchMobileColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(StitchMobileColors.radiusLg),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _MetricCell(
                      label: l10n.workoutDiaryExercisesMetric,
                      value: '${metrics.exerciseCount}',
                    ),
                  ),
                  Expanded(
                    child: _MetricCell(
                      label: l10n.workoutDiarySetsMetric,
                      value: '${metrics.setCount}',
                    ),
                  ),
                  Expanded(
                    child: _MetricCell(
                      label: l10n.workoutDiaryVolumeMetric,
                      value: volumeText,
                      valueColor: StitchMobileColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: Material(
              color: StitchMobileColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(StitchMobileColors.radiusLg),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(StitchMobileColors.radiusLg),
                child: Center(
                  child: Text(
                    l10n.workoutDiarySeeExerciseLog,
                    style: const TextStyle(
                      color: StitchMobileColors.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: StitchMobileColors.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: valueColor ?? StitchMobileColors.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DesktopCard extends StatelessWidget {
  const _DesktopCard({
    required this.entry,
    required this.customerName,
    required this.onTap,
  });

  final SessionExecutionEntry entry;
  final String customerName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final execution = entry.execution;
    final isSkipped = execution.status == PlanSessionStatus.skipped;
    final metrics = computeSessionMetrics(execution);
    final initials = customerInitials(customerName);
    final statusLabel = isSkipped
        ? l10n.sessionSkipped
        : l10n.sessionCompleted;
    final statusColor = isSkipped
        ? const Color(0xFFFB7185)
        : MarketingDarkColors.emerald;
    final notes = execution.notes.trim();

    return Material(
      color: isSkipped
          ? MarketingDarkColors.stitchCardElevated.withValues(alpha: 0.6)
          : MarketingDarkColors.stitchCardElevated,
      borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
            border: Border.all(
              color: MarketingDarkColors.stitchBorder.withValues(
                alpha: isSkipped ? 0.8 : 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(
                    initials: initials,
                    muted: isSkipped,
                    statusColor: statusColor,
                    isSkipped: isSkipped,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              entry.planName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isSkipped
                                    ? MarketingDarkColors.slate300
                                    : MarketingDarkColors.text,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                statusLabel,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '· $customerName',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isSkipped
                                    ? MarketingDarkColors.slate500
                                    : MarketingDarkColors.slate400,
                              ),
                            ),
                          ],
                        ),
                        if (!isSkipped) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 16,
                            runSpacing: 4,
                            children: [
                              _MetaChip(
                                icon: Icons.layers_outlined,
                                label:
                                    '${l10n.workoutDiaryExercisesCount(metrics.exerciseCount)} · ${l10n.workoutDiarySetsCount(metrics.setCount)}',
                              ),
                              if (metrics.hasParsableVolume)
                                _MetaChip(
                                  icon: Icons.fitness_center,
                                  label: l10n.workoutDiaryVolumeLabel(
                                    formatVolumeKg(metrics.volumeKg),
                                  ),
                                  accent: MarketingDarkColors.cyanBright,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: MarketingDarkColors.slate400,
                  ),
                ],
              ),
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x990E1522),
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      top: BorderSide(
                        color: MarketingDarkColors.stitchBorder.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: MarketingDarkColors.cyanBright,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          notes,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: MarketingDarkColors.slate300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.muted,
    required this.statusColor,
    required this.isSkipped,
  });

  final String initials;
  final bool muted;
  final Color statusColor;
  final bool isSkipped;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: muted
                ? MarketingDarkColors.surface800
                : MarketingDarkColors.cyanBright.withValues(alpha: 0.15),
            border: Border.all(
              color: muted
                  ? MarketingDarkColors.stitchBorderMuted
                  : MarketingDarkColors.cyanBright.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            initials,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: muted
                  ? MarketingDarkColors.slate400
                  : MarketingDarkColors.cyan,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: MarketingDarkColors.stitchCardElevated,
                width: 2,
              ),
            ),
            child: Icon(
              isSkipped ? Icons.close : Icons.check,
              size: 10,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.accent,
  });

  final IconData icon;
  final String label;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? MarketingDarkColors.slate400;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: accent ?? MarketingDarkColors.slate400,
            fontWeight: accent != null ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
