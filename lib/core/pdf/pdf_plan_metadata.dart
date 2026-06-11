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

String? formatPlanPeriodLabel(
  WorkoutRoutine routine,
  PdfExportLabels labels,
) {
  final start = routine.startDate;
  if (start == null) return null;
  final end = routine.endDate;
  final startLabel = labels.formatPlanDate(start);
  if (end == null) return labels.pdfPlanPeriodOpen(startLabel);
  return labels.pdfPlanPeriod(startLabel, labels.formatPlanDate(end));
}

PdfPlanMetadata buildPdfPlanMetadata({
  required WorkoutRoutine routine,
  required PdfExportLabels labels,
  String? clientName,
}) {
  return PdfPlanMetadata(
    clientName: clientName?.trim(),
    planPeriodLabel: formatPlanPeriodLabel(routine, labels),
    currentWeek: routine.currentWeek,
  );
}
