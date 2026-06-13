import 'dart:convert';

import '../data/workout_plan_api_model.dart';

enum TemplateSort { nameAsc, updatedDesc, weekCountDesc }

class TemplateSummary {
  const TemplateSummary({
    required this.weekCount,
    required this.dayCount,
    required this.exerciseCount,
    this.phase,
  });

  final int weekCount;
  final int dayCount;
  final int exerciseCount;
  final String? phase;
}

TemplateSummary summarizeTemplate(WorkoutPlanApiModel plan) {
  final phase = plan.phase?.trim();
  var weekCount = 0;
  var dayCount = 0;
  var exerciseCount = 0;
  try {
    final decoded = jsonDecode(plan.planData);
    if (decoded is! Map<String, dynamic>) {
      return TemplateSummary(
        weekCount: weekCount,
        dayCount: dayCount,
        exerciseCount: exerciseCount,
        phase: phase != null && phase.isNotEmpty ? phase : null,
      );
    }
    final weeks = decoded['weeks'];
    if (weeks is List) {
      weekCount = weeks.length;
      for (final week in weeks) {
        if (week is! Map) continue;
        final days = week['days'];
        if (days is! List) continue;
        dayCount += days.length;
        for (final day in days) {
          if (day is! Map) continue;
          final exercises = day['exercises'];
          if (exercises is List) {
            exerciseCount += exercises.length;
          }
        }
      }
    }
  } catch (_) {}

  return TemplateSummary(
    weekCount: weekCount,
    dayCount: dayCount,
    exerciseCount: exerciseCount,
    phase: phase != null && phase.isNotEmpty ? phase : null,
  );
}

List<WorkoutPlanApiModel> searchTemplates(
  List<WorkoutPlanApiModel> templates,
  String query,
) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return List<WorkoutPlanApiModel>.from(templates);
  }
  return templates.where((template) {
    final name = template.name.toLowerCase();
    final phase = (template.phase ?? '').toLowerCase();
    final tags = (template.tags ?? '').toLowerCase();
    return name.contains(q) || phase.contains(q) || tags.contains(q);
  }).toList();
}

List<WorkoutPlanApiModel> sortTemplates(
  List<WorkoutPlanApiModel> templates,
  TemplateSort sort,
) {
  final sorted = List<WorkoutPlanApiModel>.from(templates);
  final summaryById = <String, TemplateSummary>{};

  TemplateSummary summaryOf(WorkoutPlanApiModel plan) =>
      summaryById.putIfAbsent(plan.id, () => summarizeTemplate(plan));

  sorted.sort((a, b) {
    switch (sort) {
      case TemplateSort.nameAsc:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      case TemplateSort.updatedDesc:
        return b.updatedAt.compareTo(a.updatedAt);
      case TemplateSort.weekCountDesc:
        final weeksCmp = summaryOf(
          b,
        ).weekCount.compareTo(summaryOf(a).weekCount);
        if (weeksCmp != 0) return weeksCmp;
        return b.updatedAt.compareTo(a.updatedAt);
    }
  });
  return sorted;
}

List<WorkoutPlanApiModel> applyTemplateListQuery({
  required List<WorkoutPlanApiModel> templates,
  String searchQuery = '',
  TemplateSort sort = TemplateSort.updatedDesc,
}) {
  final searched = searchTemplates(templates, searchQuery);
  return sortTemplates(searched, sort);
}
