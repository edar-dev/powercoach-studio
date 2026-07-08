import 'dart:convert';

class TemplatePreviewWeek {
  const TemplatePreviewWeek({required this.name, required this.days});

  final String name;
  final List<TemplatePreviewDay> days;
}

class TemplatePreviewDay {
  const TemplatePreviewDay({
    required this.name,
    required this.exercises,
    required this.remainingExercises,
  });

  final String name;
  final List<String> exercises;
  final int remainingExercises;
}

List<TemplatePreviewWeek> parseTemplatePreviewWeeks(
  String planData, {
  int maxWeeks = 5,
  int maxExercisesPerDay = 3,
}) {
  try {
    final decoded = jsonDecode(planData);
    if (decoded is! Map<String, dynamic>) return const [];
    final rawWeeks = decoded['weeks'];
    if (rawWeeks is! List) return const [];

    final weeks = <TemplatePreviewWeek>[];
    final safeWeekCount = rawWeeks.length < maxWeeks
        ? rawWeeks.length
        : maxWeeks;

    for (var weekIndex = 0; weekIndex < safeWeekCount; weekIndex++) {
      final weekMap = rawWeeks[weekIndex];
      if (weekMap is! Map) continue;
      final weekNameRaw = weekMap['name']?.toString().trim();
      final weekName = (weekNameRaw == null || weekNameRaw.isEmpty)
          ? 'Week ${weekIndex + 1}'
          : weekNameRaw;

      final rawDays = weekMap['days'];
      final days = <TemplatePreviewDay>[];
      if (rawDays is List) {
        for (var dayIndex = 0; dayIndex < rawDays.length; dayIndex++) {
          final dayMap = rawDays[dayIndex];
          if (dayMap is! Map) continue;
          final dayNameRaw = dayMap['name']?.toString().trim();
          final dayName = (dayNameRaw == null || dayNameRaw.isEmpty)
              ? 'Day ${dayIndex + 1}'
              : dayNameRaw;

          final rawExercises = dayMap['exercises'];
          final exerciseNames = <String>[];
          var remaining = 0;
          if (rawExercises is List) {
            final takeCount = rawExercises.length < maxExercisesPerDay
                ? rawExercises.length
                : maxExercisesPerDay;
            for (var i = 0; i < takeCount; i++) {
              final exercise = rawExercises[i];
              if (exercise is! Map) continue;
              final name = exercise['name']?.toString().trim();
              if (name != null && name.isNotEmpty) {
                exerciseNames.add(name);
              }
            }
            remaining = rawExercises.length - takeCount;
          }

          days.add(
            TemplatePreviewDay(
              name: dayName,
              exercises: exerciseNames,
              remainingExercises: remaining < 0 ? 0 : remaining,
            ),
          );
        }
      }

      weeks.add(TemplatePreviewWeek(name: weekName, days: days));
    }

    return weeks;
  } catch (_) {
    return const [];
  }
}
