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
            const SizedBox(height: 16),
            Row(
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
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: snapshot.adherencePercent,
                minHeight: 8,
                backgroundColor: cs.surfaceContainerHigh,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${l10n.customerProgressLastSession}: ${_formatLastSession(context, l10n)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: snapshot.last4Weeks.map((dot) {
                final color = dot.completed == null
                    ? cs.outlineVariant
                    : (dot.completed!
                          ? StitchM3Theme.success
                          : cs.outline);
                return Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: dot.completed == null ? 0.3 : 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }).toList(),
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
}
