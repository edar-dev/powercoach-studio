import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../domain/plan_calendar_event.dart';
import 'coach_calendar_event_colors.dart';

/// Month grid card wrapping [TableCalendar] with Stitch dark styling.
class CoachCalendarGridCard extends StatelessWidget {
  const CoachCalendarGridCard({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.locale,
    required this.eventsOnDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final String locale;
  final List<PlanCalendarEvent> Function(DateTime day) eventsOnDay;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);

    return Container(
      decoration: BoxDecoration(
        color: MarketingDarkColors.surfaceElevated,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
        border: Border.all(color: MarketingDarkColors.stitchBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: TableCalendar<PlanCalendarEvent>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        eventLoader: eventsOnDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        locale: locale,
        rowHeight: isDesktop ? 96 : 72,
        daysOfWeekHeight: 36,
        headerVisible: false,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: true,
          cellMargin: const EdgeInsets.all(2),
          defaultDecoration: const BoxDecoration(),
          weekendDecoration: BoxDecoration(
            color: const Color(0xFF090E1A),
            borderRadius: BorderRadius.circular(4),
          ),
          outsideDecoration: BoxDecoration(
            color: MarketingDarkColors.surfaceElevated.withValues(alpha: 0.6),
          ),
          todayDecoration: BoxDecoration(
            color: MarketingDarkColors.brand.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: MarketingDarkColors.brand,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: MarketingDarkColors.brand.withValues(alpha: 0.4),
                blurRadius: 8,
              ),
            ],
          ),
          defaultTextStyle: const TextStyle(
            color: MarketingDarkColors.slate300,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          weekendTextStyle: const TextStyle(
            color: MarketingDarkColors.slate400,
            fontSize: 12,
          ),
          outsideTextStyle: TextStyle(
            color: MarketingDarkColors.slate500.withValues(alpha: 0.7),
            fontSize: 12,
          ),
          todayTextStyle: const TextStyle(
            color: MarketingDarkColors.brandLight,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          markersMaxCount: 3,
          markerSize: 0,
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: MarketingDarkColors.slate400,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          weekendStyle: TextStyle(
            color: MarketingDarkColors.slate500,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return const SizedBox.shrink();
            final visible = events.take(2).toList();
            final overflow = events.length - visible.length;
            return Positioned(
              left: 2,
              right: 2,
              bottom: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final event in visible)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: coachCalendarEventColor(event).withValues(
                          alpha: 0.18,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: coachCalendarEventColor(event).withValues(
                            alpha: 0.35,
                          ),
                        ),
                      ),
                      child: Text(
                        event.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: coachCalendarEventColor(event),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (overflow > 0)
                    Text(
                      '+$overflow',
                      style: const TextStyle(
                        color: MarketingDarkColors.slate500,
                        fontSize: 9,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
      ),
    );
  }
}
