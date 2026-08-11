import 'customer_progress_export_labels.dart';
import 'customer_progress_metrics.dart';

/// Builds a short human-readable progress narrative (2–4 sentences).
///
/// Skips sentences when adherence, last session, or PR data is missing.
String buildCustomerProgressNarrative({
  required CustomerProgressExportLabels labels,
  required CustomerProgressSnapshot progress,
  CustomerPrHighlight? topPr,
}) {
  final sentences = <String>[];

  final adherence = progress.adherencePercent;
  if (adherence != null) {
    final percent = '${(adherence * 100).round()}%';
    sentences.add(
      labels.narrativeSummary(
        percent,
        progress.completedSessions30d,
        progress.skippedSessions30d,
      ),
    );
  }

  final lastSession = progress.lastSessionDate;
  if (lastSession != null) {
    sentences.add(
      labels.narrativeLastSession(_formatNarrativeDate(lastSession)),
    );
  }

  if (topPr != null) {
    sentences.add(
      labels.narrativeRecentPr(
        topPr.exerciseName,
        _formatPrValue(topPr.value),
        topPr.unit,
      ),
    );
  }

  return sentences.join(' ');
}

String _formatNarrativeDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String _formatPrValue(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}
