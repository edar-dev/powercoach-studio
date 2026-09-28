import 'dart:convert';

import '../data/workout_plan_api_model.dart';
import 'workout_plan_query_helpers.dart';

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

  /// Structured phase names joined for display (not free-text plan.phase).
  final String? phase;
}

/// Prefer structured [Phase] names from planData; drop free-text plan.phase chip.
String? structuredPhaseSummaryFromPlanData(String planData) {
  try {
    final routine = planDataToRoutine(planData);
    final names = routine.phases
        .map((p) => p.name.trim())
        .where((n) => n.isNotEmpty)
        .toList();
    if (names.isEmpty) return null;
    return names.join(' · ');
  } catch (_) {
    return null;
  }
}

TemplateSummary summarizeTemplate(WorkoutPlanApiModel plan) {
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
        phase: structuredPhaseSummaryFromPlanData(plan.planData),
      );
    }
    final phases = decoded['phases'];
    if (phases is List && phases.isNotEmpty) {
      for (final phase in phases) {
        if (phase is! Map) continue;
        final weeks = phase['weeks'];
        if (weeks is! List) continue;
        weekCount += weeks.length;
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
    } else {
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
    }
  } catch (_) {}

  return TemplateSummary(
    weekCount: weekCount,
    dayCount: dayCount,
    exerciseCount: exerciseCount,
    phase: structuredPhaseSummaryFromPlanData(plan.planData),
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
    // Legacy free-text phase/tags still searchable for old JSON.
    final phase = (template.phase ?? '').toLowerCase();
    final tags = (template.tags ?? '').toLowerCase();
    final structured =
        (structuredPhaseSummaryFromPlanData(template.planData) ?? '')
            .toLowerCase();
    return name.contains(q) ||
        phase.contains(q) ||
        tags.contains(q) ||
        structured.contains(q);
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
