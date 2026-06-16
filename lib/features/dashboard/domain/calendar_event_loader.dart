import '../../workouts/data/workout_plan_api_model.dart';
import '../../workouts/data/workout_plan_repository.dart';
import 'plan_calendar_event.dart';

/// Expands workout plans into calendar events for dashboard views.
class CalendarEventLoader {
  const CalendarEventLoader._();

  static List<PlanCalendarEvent> eventsForPlans({
    required List<WorkoutPlanApiModel> plans,
    required Map<String, String> customerNamesById,
    required DateTime rangeStart,
    required DateTime rangeEndExclusive,
    required String unknownClientLabel,
    required String untitledProgramLabel,
  }) {
    final normalizedStart = calendarDayOnly(rangeStart);
    final normalizedEnd = calendarDayOnly(rangeEndExclusive);
    final events = <PlanCalendarEvent>[];

    for (final plan in plans) {
      try {
        final routine = planDataToRoutine(plan.planData);
        final startDate = routine.startDate;
        if (startDate == null || routine.weeks.isEmpty) {
          continue;
        }

        final customerName =
            customerNamesById[plan.customerId] ?? unknownClientLabel;
        final programName = plan.name.trim().isEmpty
            ? untitledProgramLabel
            : plan.name.trim();

        for (var weekIndex = 0; weekIndex < routine.weeks.length; weekIndex++) {
          final week = routine.weeks[weekIndex];
          for (var dayIndex = 0; dayIndex < week.days.length; dayIndex++) {
            final day = week.days[dayIndex];
            final sessionDay = planSessionDate(
              startDate: startDate,
              weekIndex: weekIndex,
              dayIndex: dayIndex,
              scheduledWeekday: day.scheduledWeekday,
            );
            final effectiveDay = resolveSessionOverrideDay(
              weekIndex: weekIndex,
              dayIndex: dayIndex,
              originalDay: sessionDay,
              sessionOverrides: routine.sessionOverrides,
            );
            if (effectiveDay == null) {
              continue;
            }
            if (!isPlanSessionWithinRange(
              sessionDay: effectiveDay,
              endDate: routine.endDate,
            )) {
              continue;
            }
            final normalizedSessionDay = calendarDayOnly(effectiveDay);
            if (normalizedSessionDay.isBefore(normalizedStart) ||
                !normalizedSessionDay.isBefore(normalizedEnd)) {
              continue;
            }

            events.add(
              PlanCalendarEvent(
                day: normalizedSessionDay,
                customerId: plan.customerId,
                planId: plan.id,
                customerName: customerName,
                programName: programName,
                weekIndex: weekIndex,
                dayIndex: dayIndex,
                sessionLabel: day.name.trim().isEmpty
                    ? 'W${weekIndex + 1} D${dayIndex + 1}'
                    : day.name.trim(),
                originalDay: calendarDayOnly(sessionDay),
                status: planSessionStatus(
                  completionByKey: routine.sessionCompletionByKey,
                  skippedByKey: routine.sessionSkippedByKey,
                  weekIndex: weekIndex,
                  dayIndex: dayIndex,
                ),
              ),
            );
          }
        }
      } catch (_) {
        continue;
      }
    }

    events.sort((a, b) {
      final byDay = a.day.compareTo(b.day);
      if (byDay != 0) {
        return byDay;
      }
      final byClient = a.customerName.compareTo(b.customerName);
      if (byClient != 0) {
        return byClient;
      }
      return a.programName.compareTo(b.programName);
    });
    return events;
  }

  static List<PlanCalendarEvent> upcomingEventsForPlan({
    required WorkoutPlanApiModel plan,
    required DateTime fromDay,
    int limit = 5,
  }) {
    try {
      final routine = planDataToRoutine(plan.planData);
      final startDate = routine.startDate;
      if (startDate == null || routine.weeks.isEmpty) {
        return const [];
      }

      final from = calendarDayOnly(fromDay);
      final events = <PlanCalendarEvent>[];
      for (var weekIndex = 0; weekIndex < routine.weeks.length; weekIndex++) {
        final week = routine.weeks[weekIndex];
        for (var dayIndex = 0; dayIndex < week.days.length; dayIndex++) {
          final day = week.days[dayIndex];
          final sessionDay = calendarDayOnly(
            planSessionDate(
              startDate: startDate,
              weekIndex: weekIndex,
              dayIndex: dayIndex,
              scheduledWeekday: day.scheduledWeekday,
            ),
          );
          final effectiveDay = resolveSessionOverrideDay(
            weekIndex: weekIndex,
            dayIndex: dayIndex,
            originalDay: sessionDay,
            sessionOverrides: routine.sessionOverrides,
          );
          if (effectiveDay == null) {
            continue;
          }
          final normalizedEffectiveDay = calendarDayOnly(effectiveDay);
          if (normalizedEffectiveDay.isBefore(from)) {
            continue;
          }
          if (!isPlanSessionWithinRange(
            sessionDay: normalizedEffectiveDay,
            endDate: routine.endDate,
          )) {
            continue;
          }
          events.add(
            PlanCalendarEvent(
              day: normalizedEffectiveDay,
              customerId: plan.customerId,
              planId: plan.id,
              customerName: '',
              programName: plan.name,
              weekIndex: weekIndex,
              dayIndex: dayIndex,
              sessionLabel: day.name.trim().isEmpty
                  ? 'W${weekIndex + 1} D${dayIndex + 1}'
                  : day.name.trim(),
              originalDay: sessionDay,
              status: planSessionStatus(
                completionByKey: routine.sessionCompletionByKey,
                skippedByKey: routine.sessionSkippedByKey,
                weekIndex: weekIndex,
                dayIndex: dayIndex,
              ),
            ),
          );
        }
      }

      events.sort((a, b) => a.day.compareTo(b.day));
      if (events.length <= limit) {
        return events;
      }
      return events.sublist(0, limit);
    } catch (_) {
      return const [];
    }
  }
}
