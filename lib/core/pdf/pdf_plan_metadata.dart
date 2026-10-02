import '../../features/workouts/data/workout_routine_model.dart';
import 'pdf_export_labels.dart';

/// Client and calendar context shown on workout PDF exports.
class PdfPlanMetadata {
  const PdfPlanMetadata({
    this.clientName,
    this.planPeriodLabel,
    this.currentWeek,
  });

  final String? clientName;
  final String? planPeriodLabel;
  final int? currentWeek;

  bool get hasClient => clientName != null && clientName!.trim().isNotEmpty;
  bool get hasPlanPeriod =>
      planPeriodLabel != null && planPeriodLabel!.trim().isNotEmpty;
}

/// Builds the plan period subtitle for a PDF.
///
/// When [weekIndices] selects a subset of weeks, the date range is scoped to
/// those weeks (from [routine.startDate]) instead of the full plan span.
String? formatPlanPeriodLabel(
  WorkoutRoutine routine,
  PdfExportLabels labels, {
  List<int>? weekIndices,
}) {
  final start = routine.startDate;
  if (start == null) return null;

  final scoped = _scopedWeekIndices(routine, weekIndices);
  if (scoped == null) {
    final end = routine.endDate;
    final startLabel = labels.formatPlanDate(start);
    if (end == null) return labels.pdfPlanPeriodOpen(startLabel);
    return labels.pdfPlanPeriod(startLabel, labels.formatPlanDate(end));
  }

  final first = scoped.first;
  final last = scoped.last;
  final rangeStart = DateTime(start.year, start.month, start.day)
      .add(Duration(days: first * 7));
  var rangeEnd = DateTime(start.year, start.month, start.day)
      .add(Duration(days: (last + 1) * 7 - 1));
  final planEnd = routine.endDate;
  if (planEnd != null && rangeEnd.isAfter(planEnd)) {
    rangeEnd = DateTime(planEnd.year, planEnd.month, planEnd.day);
  }
  if (rangeEnd.isBefore(rangeStart)) {
    rangeEnd = rangeStart;
  }
  return labels.pdfPlanPeriod(
    labels.formatPlanDate(rangeStart),
    labels.formatPlanDate(rangeEnd),
  );
}

PdfPlanMetadata buildPdfPlanMetadata({
  required WorkoutRoutine routine,
  required PdfExportLabels labels,
  String? clientName,
  List<int>? weekIndices,
}) {
  return PdfPlanMetadata(
    clientName: clientName?.trim(),
    planPeriodLabel: formatPlanPeriodLabel(
      routine,
      labels,
      weekIndices: weekIndices,
    ),
    currentWeek: routine.currentWeek,
  );
}

/// Returns sorted valid week indices when filtering is active; otherwise null
/// (meaning "all weeks" / full plan period).
List<int>? _scopedWeekIndices(WorkoutRoutine routine, List<int>? weekIndices) {
  if (weekIndices == null || weekIndices.isEmpty) return null;
  final valid = <int>{
    for (final i in weekIndices)
      if (i >= 0 && i < routine.weeks.length) i,
  }.toList()
    ..sort();
  if (valid.isEmpty || valid.length >= routine.weeks.length) return null;
  return valid;
}
