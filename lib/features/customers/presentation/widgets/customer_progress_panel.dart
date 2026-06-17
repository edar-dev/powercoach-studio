import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../domain/customer_progress_metrics.dart';

class CustomerProgressPanel extends StatelessWidget {
  const CustomerProgressPanel({
    super.key,
    required this.snapshot,
    required this.loading,
  });

  final CustomerProgressSnapshot snapshot;
  final bool loading;

  static const double _weekDotSize = 24;
  static const double _weekDotGap = 12;

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

    if (!snapshot.hasAnyData) {
      return Card(
        elevation: 0,
        color: cs.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.customerProgressTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.customerProgressNoData,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.customerProgressTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    l10n.customerProgressAdherence,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  snapshot.adherencePercent == null
                      ? '—'
                      : '${(snapshot.adherencePercent! * 100).round()}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: snapshot.adherencePercent ?? 0,
                minHeight: 6,
                backgroundColor: cs.surfaceContainerHigh,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '${l10n.customerProgressLastSession}: ${_formatLastSession(context, l10n)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.customerProgressLast4Weeks,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            _WeeklyAdherenceStrip(
              dots: snapshot.last4Weeks,
              weekLabelBuilder: (index) =>
                  _weekLabel(l10n, index, snapshot.last4Weeks.length),
            ),
            if (snapshot.recentPrs.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                l10n.customerProgressRecentPrs,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...snapshot.recentPrs.map(
                (pr) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '· ${pr.exerciseName} ${pr.value} ${pr.unit}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatLastSession(BuildContext context, AppLocalizations l10n) {
    final date = snapshot.lastSessionDate;
    if (date == null) return l10n.customerProgressNoSession;

    final today = DateTime.now();
    final dayOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    final diff = todayOnly.difference(dayOnly).inDays;

    if (diff == 0) return l10n.customerProgressToday;
    if (diff == 1) return l10n.customerProgressYesterday;
    return l10n.customerProgressDaysAgo(diff);
  }

  String _weekLabel(AppLocalizations l10n, int index, int total) {
    final weeksAgo = total - 1 - index;
    if (weeksAgo == 0) return l10n.customerProgressThisWeek;
    return l10n.customerProgressWeeksAgo(weeksAgo);
  }
}

class _WeeklyAdherenceStrip extends StatelessWidget {
  const _WeeklyAdherenceStrip({
    required this.dots,
    required this.weekLabelBuilder,
  });

  final List<WeeklyAdherenceDot> dots;
  final String Function(int index) weekLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        for (var i = 0; i < dots.length; i++) ...[
          if (i > 0) const SizedBox(width: CustomerProgressPanel._weekDotGap),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _WeekDot(dot: dots[i]),
              const SizedBox(height: 6),
              SizedBox(
                width: CustomerProgressPanel._weekDotSize + 20,
                child: Text(
                  weekLabelBuilder(i),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _WeekDot extends StatelessWidget {
  const _WeekDot({required this.dot});

  final WeeklyAdherenceDot dot;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final Color fill;
    if (dot.completed == null) {
      fill = cs.outlineVariant.withValues(alpha: 0.35);
    } else if (dot.completed!) {
      fill = StitchM3Theme.success;
    } else {
      fill = cs.outline.withValues(alpha: 0.55);
    }

    return Container(
      width: CustomerProgressPanel._weekDotSize,
      height: CustomerProgressPanel._weekDotSize,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(6),
        border: dot.completed == null
            ? Border.all(color: cs.outlineVariant.withValues(alpha: 0.5))
            : null,
      ),
    );
  }
}
