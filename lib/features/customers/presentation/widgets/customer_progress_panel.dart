import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import '../../domain/customer_progress_metrics.dart';

class CustomerProgressPanel extends StatelessWidget {
  const CustomerProgressPanel({
    super.key,
    required this.snapshot,
    required this.loading,
    this.onExport,
  });

  final CustomerProgressSnapshot snapshot;
  final bool loading;
  final VoidCallback? onExport;

  static const double _weekDotSize = 24;
  static const double _weekDotGap = 12;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: MarketingDarkColors.brandLight,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MarketingDarkColors.surfaceElevated,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl),
        border: Border.all(color: MarketingDarkColors.borderSubtle),
      ),
      child: !snapshot.hasAnyData
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PanelHeader(
                  title: l10n.customerProgressTitle,
                  exportTooltip: l10n.customerProgressExport,
                  onExport: onExport,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.customerProgressNoData,
                  style: const TextStyle(
                    fontSize: 14,
                    color: MarketingDarkColors.slate400,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PanelHeader(
                  title: l10n.customerProgressTitle,
                  exportTooltip: l10n.customerProgressExport,
                  onExport: onExport,
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.customerProgressAdherence,
                        style: const TextStyle(
                          fontSize: 14,
                          color: MarketingDarkColors.slate400,
                        ),
                      ),
                    ),
                    Text(
                      snapshot.adherencePercent == null
                          ? '—'
                          : '${(snapshot.adherencePercent! * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: MarketingDarkColors.brandLight,
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
                    backgroundColor: MarketingDarkColors.surface700,
                    color: MarketingDarkColors.brandMid,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${l10n.customerProgressLastSession}: ${_formatLastSession(l10n)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: MarketingDarkColors.slate500,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.customerProgressLast4Weeks,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MarketingDarkColors.slate400,
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
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: MarketingDarkColors.slate300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...snapshot.recentPrs.map(
                    (pr) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        l10n.customerProgressPrLine(
                          pr.exerciseName,
                          _formatPrValue(pr.value),
                          pr.unit,
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: MarketingDarkColors.text,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  String _formatLastSession(AppLocalizations l10n) {
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

  String _formatPrValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.title,
    required this.exportTooltip,
    this.onExport,
  });

  final String title;
  final String exportTooltip;
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: MarketingDarkColors.text,
            ),
          ),
        ),
        if (onExport != null)
          IconButton(
            tooltip: exportTooltip,
            icon: const Icon(Icons.ios_share_outlined),
            color: MarketingDarkColors.slate300,
            onPressed: onExport,
          ),
      ],
    );
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < dots.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? 0 : CustomerProgressPanel._weekDotGap / 2,
                right: i == dots.length - 1
                    ? 0
                    : CustomerProgressPanel._weekDotGap / 2,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: _WeekDot(dot: dots[i]),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    weekLabelBuilder(i),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    softWrap: true,
                    style: const TextStyle(
                      color: MarketingDarkColors.slate500,
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _WeekDot extends StatelessWidget {
  const _WeekDot({required this.dot});

  final WeeklyAdherenceDot dot;

  @override
  Widget build(BuildContext context) {
    final Color fill;
    if (dot.completed == null) {
      fill = MarketingDarkColors.borderMuted.withValues(alpha: 0.35);
    } else if (dot.completed!) {
      fill = MarketingDarkColors.emerald;
    } else {
      fill = MarketingDarkColors.slate500.withValues(alpha: 0.55);
    }

    return Container(
      width: CustomerProgressPanel._weekDotSize,
      height: CustomerProgressPanel._weekDotSize,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(6),
        border: dot.completed == null
            ? Border.all(
                color: MarketingDarkColors.borderMuted.withValues(alpha: 0.5),
              )
            : null,
      ),
    );
  }
}
