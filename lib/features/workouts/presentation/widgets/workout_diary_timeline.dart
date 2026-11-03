import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/domain/plan_calendar_event.dart';
import '../../domain/session_execution_service.dart';
import '../../domain/workout_diary_metrics.dart';
import 'workout_diary_session_card.dart';

/// Date-grouped timeline list for diary entries.
///
/// On tablet+ uses a compact history table (Date / Athlete / Status / Volume /
/// RPE) instead of large cards.
class WorkoutDiaryTimeline extends StatelessWidget {
  const WorkoutDiaryTimeline({
    super.key,
    required this.groups,
    required this.dateFormat,
    required this.customerNameOf,
    required this.onOpenEntry,
    required this.loadingMore,
    this.compactTable,
  });

  final List<MapEntry<DateTime, List<SessionExecutionEntry>>> groups;
  final DateFormat dateFormat;
  final String Function(String customerId) customerNameOf;
  final ValueChanged<SessionExecutionEntry> onOpenEntry;
  final bool loadingMore;

  /// When null, defaults to compact table on tablet+.
  final bool? compactTable;

  @override
  Widget build(BuildContext context) {
    final phone = !Breakpoints.isTabletOrWider(context);
    final useTable = compactTable ?? !phone;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (useTable && !phone) {
      return _DesktopTable(
        groups: groups,
        dateFormat: dateFormat,
        customerNameOf: customerNameOf,
        onOpenEntry: onOpenEntry,
        loadingMore: loadingMore,
        theme: theme,
        l10n: l10n,
      );
    }

    final children = <Widget>[];
    final today = DateUtils.dateOnly(DateTime.now());

    for (var i = 0; i < groups.length; i++) {
      final group = groups[i];
      final day = DateUtils.dateOnly(group.key);
      final isToday = day == today;

      if (phone) {
        final label = isToday
            ? '${l10n.calendarToday} · ${DateFormat('d MMMM', l10n.localeName).format(group.key)}'
            : dateFormat.format(group.key);
        children.add(
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 8, bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                color: StitchMobileColors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      } else {
        children.add(
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 6, bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: MarketingDarkColors.surface800.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: MarketingDarkColors.stitchBorderMuted.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                  child: Text(
                    dateFormat.format(group.key).toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: MarketingDarkColors.slate400,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Divider(
                    color: MarketingDarkColors.stitchBorder,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      for (final entry in group.value) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: WorkoutDiarySessionCard(
              entry: entry,
              customerName: customerNameOf(entry.customerId),
              onTap: () => onOpenEntry(entry),
            ),
          ),
        );
      }
    }

    if (loadingMore) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: CircularProgressIndicator(
              color: phone
                  ? StitchMobileColors.primary
                  : MarketingDarkColors.cyanBright,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _DesktopTable extends StatelessWidget {
  const _DesktopTable({
    required this.groups,
    required this.dateFormat,
    required this.customerNameOf,
    required this.onOpenEntry,
    required this.loadingMore,
    required this.theme,
    required this.l10n,
  });

  final List<MapEntry<DateTime, List<SessionExecutionEntry>>> groups;
  final DateFormat dateFormat;
  final String Function(String customerId) customerNameOf;
  final ValueChanged<SessionExecutionEntry> onOpenEntry;
  final bool loadingMore;
  final ThemeData theme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final shortDate = DateFormat.yMMMd(l10n.localeName);
    final rows = <SessionExecutionEntry>[
      for (final g in groups) ...g.value,
    ];

    return Container(
      decoration: BoxDecoration(
        color: MarketingDarkColors.stitchCardElevated,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
        border: Border.all(
          color: MarketingDarkColors.stitchBorder.withValues(alpha: 0.9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    l10n.workoutDiaryColDate.toUpperCase(),
                    style: _headerStyle(theme),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    l10n.workoutDiaryColAthlete.toUpperCase(),
                    style: _headerStyle(theme),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    l10n.workoutDiaryColStatus.toUpperCase(),
                    style: _headerStyle(theme),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    l10n.workoutDiaryColVolume.toUpperCase(),
                    style: _headerStyle(theme),
                  ),
                ),
                Expanded(
                  child: Text(
                    l10n.workoutDiaryColRpe.toUpperCase(),
                    style: _headerStyle(theme),
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
          const Divider(height: 1, color: MarketingDarkColors.stitchBorder),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, color: MarketingDarkColors.stitchBorder),
            _TableRow(
              entry: rows[i],
              customerName: customerNameOf(rows[i].customerId),
              dateLabel: shortDate.format(
                rows[i].execution.completedAt ?? rows[i].execution.sessionDate,
              ),
              onTap: () => onOpenEntry(rows[i]),
              l10n: l10n,
              theme: theme,
            ),
          ],
          if (loadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(
                  color: MarketingDarkColors.cyanBright,
                ),
              ),
            ),
        ],
      ),
    );
  }

  TextStyle? _headerStyle(ThemeData theme) {
    return theme.textTheme.labelSmall?.copyWith(
      color: MarketingDarkColors.slate500,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.entry,
    required this.customerName,
    required this.dateLabel,
    required this.onTap,
    required this.l10n,
    required this.theme,
  });

  final SessionExecutionEntry entry;
  final String customerName;
  final String dateLabel;
  final VoidCallback onTap;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final execution = entry.execution;
    final isSkipped = execution.status == PlanSessionStatus.skipped;
    final metrics = computeSessionMetrics(execution);
    final statusLabel =
        isSkipped ? l10n.sessionSkipped : l10n.sessionCompleted;
    final statusColor =
        isSkipped ? const Color(0xFFFB7185) : MarketingDarkColors.emerald;
    final volumeText = metrics.hasParsableVolume
        ? '${formatVolumeKg(metrics.volumeKg)} kg'
        : '—';
    final rpeText = metrics.hasRpeSamples && metrics.avgRpe != null
        ? formatAvgRpe(metrics.avgRpe!)
        : '—';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  dateLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: MarketingDarkColors.slate300,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: MarketingDarkColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (entry.planName.trim().isNotEmpty)
                      Text(
                        entry.planName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: MarketingDarkColors.slate500,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
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
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  volumeText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: MarketingDarkColors.cyanBright,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  rpeText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: MarketingDarkColors.slate300,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: MarketingDarkColors.slate400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
