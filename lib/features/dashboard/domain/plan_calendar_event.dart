import '../../workouts/data/workout_routine_model.dart';

/// Session state for calendarized workout slots.
enum PlanSessionStatus { planned, completed, skipped }

/// Calendar row derived from a workout plan assignment.
class PlanCalendarEvent {
  const PlanCalendarEvent({
    required this.day,
    required this.customerId,
    required this.planId,
    required this.customerName,
    required this.programName,
    required this.weekIndex,
    required this.dayIndex,
    required this.sessionLabel,
    required this.status,
    this.originalDay,
  });

  final DateTime day;
  final String customerId;
  final String planId;
  final String customerName;
  final String programName;
  final int weekIndex;
  final int dayIndex;
  final String sessionLabel;
  final PlanSessionStatus status;
  final DateTime? originalDay;

  String get sessionKey => '$weekIndex-$dayIndex';
}

/// Maps a week/day slot to a calendar day from [startDate].
///
/// v1 rule: each week occupies a 7-day block; day index is the offset inside that block.
DateTime planSessionDate({
  required DateTime startDate,
  required int weekIndex,
  required int dayIndex,
  int? scheduledWeekday,
}) {
  final normalized = DateTime(startDate.year, startDate.month, startDate.day);
  final weekStart = normalized.add(Duration(days: weekIndex * 7));
  if (scheduledWeekday == null) {
    return weekStart.add(Duration(days: dayIndex));
  }
  final normalizedWeekday = scheduledWeekday < DateTime.monday
      ? DateTime.monday
      : (scheduledWeekday > DateTime.sunday
            ? DateTime.sunday
            : scheduledWeekday);
  final offset = (normalizedWeekday - weekStart.weekday + 7) % 7;
  return weekStart.add(Duration(days: offset));
}

DateTime calendarDayOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

PlanSessionStatus planSessionStatus({
  required Map<String, bool> completionByKey,
  required Map<String, bool> skippedByKey,
  required int weekIndex,
  required int dayIndex,
}) {
  final key = '$weekIndex-$dayIndex';
  if (completionByKey[key] == true) {
    return PlanSessionStatus.completed;
  }
  if (skippedByKey[key] == true) {
    return PlanSessionStatus.skipped;
  }
  return PlanSessionStatus.planned;
}

bool isPlanSessionWithinRange({
  required DateTime sessionDay,
  required DateTime? endDate,
}) {
  if (endDate == null) {
    return true;
  }
  final end = calendarDayOnly(endDate);
  return !calendarDayOnly(sessionDay).isAfter(end);
}

String sessionOccurrenceKey({
  required int weekIndex,
  required int dayIndex,
  required DateTime originalDay,
}) {
  final d = calendarDayOnly(originalDay);
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$weekIndex-$dayIndex-$y-$m-$day';
}

DateTime? resolveSessionOverrideDay({
  required int weekIndex,
  required int dayIndex,
  required DateTime originalDay,
  required Map<String, SessionOverride> sessionOverrides,
}) {
  final key = sessionOccurrenceKey(
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    originalDay: originalDay,
  );
  final override = sessionOverrides[key];
  if (override == null) return originalDay;
  if (override.kind == SessionOverrideKind.skipped) return null;
  return override.movedToDate ?? originalDay;
}
