import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/data/models/customer.dart';
import '../../domain/workout_diary_filter.dart';

/// Date range pills, athlete selector, and status chips for the diary.
class WorkoutDiaryFiltersBar extends StatelessWidget {
  const WorkoutDiaryFiltersBar({
    super.key,
    required this.dateRange,
    required this.statusFilter,
    required this.customers,
    required this.filterCustomerId,
    required this.visibleCount,
    required this.onDateRangeChanged,
    required this.onStatusChanged,
    required this.onAthleteTap,
  });

  final DiaryDateRange dateRange;
  final DiaryStatusFilter statusFilter;
  final List<Customer> customers;
  final String? filterCustomerId;
  final int visibleCount;
  final ValueChanged<DiaryDateRange> onDateRangeChanged;
  final ValueChanged<DiaryStatusFilter> onStatusChanged;
  final VoidCallback onAthleteTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    String athleteLabel = l10n.workoutDiaryFilterAll;
    if (filterCustomerId != null) {
      for (final c in customers) {
        if (c.id == filterCustomerId) {
          athleteLabel = c.name;
          break;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2A),
        borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
        border: Border.all(color: MarketingDarkColors.stitchBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 720;
              final datePills = _DatePills(
                dateRange: dateRange,
                onChanged: onDateRangeChanged,
              );
              final athlete = _AthleteSelector(
                label: l10n.workoutDiaryFilterAthlete,
                value: athleteLabel,
                onTap: onAthleteTap,
              );
              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    datePills,
                    const SizedBox(height: 12),
                    athlete,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: datePills),
                  const SizedBox(width: 16),
                  SizedBox(width: 240, child: athlete),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: MarketingDarkColors.stitchBorder.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _StatusChip(
                label: l10n.workoutDiaryFilterStatusAll,
                selected: statusFilter == DiaryStatusFilter.all,
                onTap: () => onStatusChanged(DiaryStatusFilter.all),
              ),
              _StatusChip(
                label: l10n.sessionCompleted,
                selected: statusFilter == DiaryStatusFilter.completed,
                onTap: () => onStatusChanged(DiaryStatusFilter.completed),
                accent: MarketingDarkColors.emerald,
              ),
              _StatusChip(
                label: l10n.sessionSkipped,
                selected: statusFilter == DiaryStatusFilter.skipped,
                onTap: () => onStatusChanged(DiaryStatusFilter.skipped),
                accent: const Color(0xFFFB7185),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.workoutDiaryShowingCount(visibleCount),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: MarketingDarkColors.slate400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DatePills extends StatelessWidget {
  const _DatePills({required this.dateRange, required this.onChanged});

  final DiaryDateRange dateRange;
  final ValueChanged<DiaryDateRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0D131F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MarketingDarkColors.stitchBorder),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          _DatePill(
            label: l10n.coachStatsPeriod7d,
            selected: dateRange == DiaryDateRange.last7,
            onTap: () => onChanged(DiaryDateRange.last7),
          ),
          _DatePill(
            label: l10n.coachStatsPeriod30d,
            selected: dateRange == DiaryDateRange.last30,
            onTap: () => onChanged(DiaryDateRange.last30),
          ),
          _DatePill(
            label: l10n.workoutDiaryFilterDateAll,
            selected: dateRange == DiaryDateRange.all,
            onTap: () => onChanged(DiaryDateRange.all),
          ),
        ],
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? MarketingDarkColors.cyanBright
          : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected
                  ? MarketingDarkColors.cyanOn
                  : MarketingDarkColors.slate300,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _AthleteSelector extends StatelessWidget {
  const _AthleteSelector({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: MarketingDarkColors.slate400,
          ),
        ),
        const SizedBox(height: 4),
        Material(
          color: const Color(0xFF0D131F),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: MarketingDarkColors.stitchBorderMuted.withValues(
                    alpha: 0.8,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.unfold_more,
                    size: 16,
                    color: MarketingDarkColors.slate400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.accent,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final active = selected;
    final accentColor = accent ?? MarketingDarkColors.cyanBright;
    final bg = active
        ? accentColor.withValues(alpha: 0.15)
        : MarketingDarkColors.surface800.withValues(alpha: 0.9);
    final border = active
        ? accentColor.withValues(alpha: 0.35)
        : MarketingDarkColors.stitchBorderMuted;
    final fg = active ? accentColor : MarketingDarkColors.text;

    return Material(
      color: bg,
      shape: StadiumBorder(side: BorderSide(color: border)),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (accent != null) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
