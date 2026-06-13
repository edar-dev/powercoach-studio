import '../data/workout_routine_model.dart';

/// Inferred ISO weekday (1=Mon … 7=Sun) from legacy day slot index.
int inferredScheduledWeekday(int dayIndex) => (dayIndex % 7) + DateTime.monday;

/// Weekday used for calendar UI: persisted value or legacy inference.
int effectiveScheduledWeekday({required Day day, required int dayIndex}) {
  return day.scheduledWeekday ?? inferredScheduledWeekday(dayIndex);
}

/// Fills missing [Day.scheduledWeekday] from slot index (import/legacy plans).
WorkoutRoutine hydrateScheduledWeekdays(WorkoutRoutine routine) {
  final weeks = routine.weeks.map((week) {
    final days = week.days.asMap().entries.map((entry) {
      final day = entry.value;
      if (day.scheduledWeekday != null) return day;
      return day.copyWith(scheduledWeekday: inferredScheduledWeekday(entry.key));
    }).toList();
    return week.copyWith(days: days);
  }).toList();
  return routine.copyWith(weeks: weeks);
}

/// Short Italian weekday labels for compact chips (Ma/Me disambiguation).
const Map<int, String> kItalianWeekdayShortLabels = {
  DateTime.monday: 'L',
  DateTime.tuesday: 'Ma',
  DateTime.wednesday: 'Me',
  DateTime.thursday: 'G',
  DateTime.friday: 'V',
  DateTime.saturday: 'S',
  DateTime.sunday: 'D',
};

const Map<int, String> kItalianWeekdayFullLabels = {
  DateTime.monday: 'Lunedì',
  DateTime.tuesday: 'Martedì',
  DateTime.wednesday: 'Mercoledì',
  DateTime.thursday: 'Giovedì',
  DateTime.friday: 'Venerdì',
  DateTime.saturday: 'Sabato',
  DateTime.sunday: 'Domenica',
};
