import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/plan_calendar_event.dart';
import 'coach_calendar_event_colors.dart';

/// Selected-day session list for the coach calendar sidebar / mobile stack.
class CoachCalendarDaySummary extends StatelessWidget {
  const CoachCalendarDaySummary({
    super.key,
    required this.day,
    required this.events,
    required this.loading,
    required this.onOpen,
    required this.onToggleCompleted,
    required this.onToggleSkipped,
  });

  final DateTime day;
  final List<PlanCalendarEvent> events;
  final bool loading;
  final ValueChanged<PlanCalendarEvent> onOpen;
  final void Function(PlanCalendarEvent event, bool completed) onToggleCompleted;
  final ValueChanged<PlanCalendarEvent> onToggleSkipped;

  @override
  Widget build(BuildContext context) {
    if (!Breakpoints.isTabletOrWider(context)) {
      return _PhoneDayAgenda(
        day: day,
        events: events,
        loading: loading,
        onOpen: onOpen,
        onToggleCompleted: onToggleCompleted,
        onToggleSkipped: onToggleSkipped,
      );
    }
    return _DesktopDaySummary(
      day: day,
      events: events,
      loading: loading,
      onOpen: onOpen,
      onToggleCompleted: onToggleCompleted,
      onToggleSkipped: onToggleSkipped,
    );
  }
}

class _PhoneDayAgenda extends StatelessWidget {
  const _PhoneDayAgenda({
    required this.day,
    required this.events,
    required this.loading,
    required this.onOpen,
    required this.onToggleCompleted,
    required this.onToggleSkipped,
  });

  final DateTime day;
  final List<PlanCalendarEvent> events;
  final bool loading;
  final ValueChanged<PlanCalendarEvent> onOpen;
  final void Function(PlanCalendarEvent event, bool completed) onToggleCompleted;
  final ValueChanged<PlanCalendarEvent> onToggleSkipped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;
    final title = DateFormat('EEEE d MMMM', locale).format(day);
    final capitalized = title.isEmpty
        ? title
        : '${title[0].toUpperCase()}${title.substring(1)}';
    final today = DateUtils.isSameDay(day, DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capitalized,
                    style: const TextStyle(
                      color: StitchMobileColors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.calendarSessionsCount(events.length),
                    style: const TextStyle(
                      color: StitchMobileColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (today)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: StitchMobileColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.calendarToday,
                  style: const TextStyle(
                    color: StitchMobileColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(
                color: StitchMobileColors.primary,
              ),
            ),
          )
        else if (events.isEmpty)
          Text(
            l10n.calendarEmptyMonth,
            style: const TextStyle(
              color: StitchMobileColors.onSurfaceVariant,
              fontSize: 14,
            ),
          )
        else
          for (final event in events) ...[
            _PhoneSessionCard(
              event: event,
              onOpen: () => onOpen(event),
              onToggleCompleted: (completed) =>
                  onToggleCompleted(event, completed),
              onToggleSkipped: () => onToggleSkipped(event),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _PhoneSessionCard extends StatelessWidget {
  const _PhoneSessionCard({
    required this.event,
    required this.onOpen,
    required this.onToggleCompleted,
    required this.onToggleSkipped,
  });

  final PlanCalendarEvent event;
  final VoidCallback onOpen;
  final ValueChanged<bool> onToggleCompleted;
  final VoidCallback onToggleSkipped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = coachCalendarPhoneEventColor(event);
    final completed = event.status == PlanSessionStatus.completed;
    final skipped = event.status == PlanSessionStatus.skipped;
    final statusLabel = skipped
        ? l10n.sessionSkipped
        : completed
        ? l10n.sessionCompleted
        : l10n.calendarStatusWaiting;
    final statusDetail = skipped
        ? l10n.sessionSkipped
        : completed
        ? l10n.sessionCompleted
        : l10n.calendarStatusScheduled;

    return Container(
      decoration: BoxDecoration(
        color: StitchMobileColors.surfaceContainer,
        borderRadius: BorderRadius.circular(StitchMobileColors.radiusXl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 4, color: accent),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.2),
                      ),
                      child: Text(
                        _initials(event.customerName),
                        style: TextStyle(
                          color: accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: StitchMobileColors.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            statusDetail,
                            style: TextStyle(
                              color: accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: StitchMobileColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(
                      StitchMobileColors.radiusLg,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.sessionLabel.isNotEmpty
                            ? event.sessionLabel
                            : event.programName,
                        style: const TextStyle(
                          color: StitchMobileColors.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (event.programName.isNotEmpty &&
                          event.sessionLabel.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          event.programName,
                          style: const TextStyle(
                            color: StitchMobileColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: Material(
                          color: StitchMobileColors.primaryContainer,
                          borderRadius: BorderRadius.circular(
                            StitchMobileColors.radiusLg,
                          ),
                          child: InkWell(
                            onTap: onOpen,
                            borderRadius: BorderRadius.circular(
                              StitchMobileColors.radiusLg,
                            ),
                            child: Center(
                              child: Text(
                                l10n.calendarOpenSession,
                                style: const TextStyle(
                                  color: StitchMobileColors.onPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: Material(
                        color: StitchMobileColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(
                          StitchMobileColors.radiusLg,
                        ),
                        child: InkWell(
                          onTap: () => onToggleCompleted(!completed),
                          onLongPress: onToggleSkipped,
                          borderRadius: BorderRadius.circular(
                            StitchMobileColors.radiusLg,
                          ),
                          child: Icon(
                            completed
                                ? Icons.check_circle
                                : skipped
                                    ? Icons.block
                                    : Icons.check_circle_outline,
                            color: completed
                                ? StitchMobileColors.tertiary
                                : skipped
                                    ? StitchMobileColors.secondary
                                    : StitchMobileColors.onSurfaceVariant,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return p.substring(0, p.length >= 2 ? 2 : 1).toUpperCase();
    }
    return ('${parts.first[0]}${parts.last[0]}').toUpperCase();
  }
}

class _DesktopDaySummary extends StatelessWidget {
  const _DesktopDaySummary({
    required this.day,
    required this.events,
    required this.loading,
    required this.onOpen,
    required this.onToggleCompleted,
    required this.onToggleSkipped,
  });

  final DateTime day;
  final List<PlanCalendarEvent> events;
  final bool loading;
  final ValueChanged<PlanCalendarEvent> onOpen;
  final void Function(PlanCalendarEvent event, bool completed) onToggleCompleted;
  final ValueChanged<PlanCalendarEvent> onToggleSkipped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = l10n.localeName;
    final weekday = DateFormat.EEEE(locale).format(day);
    final dateLabel = DateFormat.yMMMMd(locale).format(day);

    return Container(
      decoration: BoxDecoration(
        color: MarketingDarkColors.surfaceElevated,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
        border: Border.all(color: MarketingDarkColors.stitchBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MarketingDarkColors.surface.withValues(alpha: 0.6),
              border: Border(
                bottom: BorderSide(color: MarketingDarkColors.stitchBorder),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dateLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: MarketingDarkColors.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: MarketingDarkColors.brand.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: MarketingDarkColors.brand.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Text(
                        weekday,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: MarketingDarkColors.brandLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.calendarDaySummaryTitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: MarketingDarkColors.slate400,
                  ),
                ),
              ],
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: CircularProgressIndicator(
                  color: MarketingDarkColors.brandLight,
                ),
              ),
            )
          else if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.calendarEmptyMonth,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: MarketingDarkColors.slate400,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  for (final event in events) ...[
                    _SessionTile(
                      event: event,
                      onOpen: () => onOpen(event),
                      onToggleCompleted: (v) => onToggleCompleted(event, v),
                      onLongPress: () => onToggleSkipped(event),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.event,
    required this.onOpen,
    required this.onToggleCompleted,
    required this.onLongPress,
  });

  final PlanCalendarEvent event;
  final VoidCallback onOpen;
  final ValueChanged<bool> onToggleCompleted;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final color = coachCalendarEventColor(event);
    final completed = event.status == PlanSessionStatus.completed;
    final skipped = event.status == PlanSessionStatus.skipped;
    final statusLabel = skipped
        ? l10n.sessionSkipped
        : completed
        ? l10n.sessionCompleted
        : l10n.sessionPlanned;
    final statusColor = skipped
        ? const Color(0xFFFB7185)
        : completed
        ? MarketingDarkColors.emerald
        : MarketingDarkColors.amber;

    return Material(
      color: MarketingDarkColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onOpen,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Checkbox(
                    value: completed,
                    onChanged: (v) => onToggleCompleted(v ?? false),
                    activeColor: MarketingDarkColors.brand,
                    checkColor: Colors.white,
                    side: const BorderSide(
                      color: MarketingDarkColors.slate500,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.2),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      _initials(event.customerName),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: MarketingDarkColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${event.programName} · ${event.sessionLabel}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: MarketingDarkColors.slate400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: MarketingDarkColors.brand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: onOpen,
                  child: Text(l10n.calendarOpenSession),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return p.substring(0, p.length >= 2 ? 2 : 1).toUpperCase();
    }
    return ('${parts.first[0]}${parts.last[0]}').toUpperCase();
  }
}
