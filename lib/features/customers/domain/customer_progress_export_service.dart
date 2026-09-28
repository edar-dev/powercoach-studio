import 'dart:convert';
import 'dart:typed_data';

import '../../../core/export/export_artifact.dart';
import '../data/models/customer_measurement.dart';
import 'customer_overview_metrics.dart';
import 'customer_progress_export_labels.dart';
import 'customer_progress_metrics.dart';
import 'customer_progress_narrative.dart';

/// Inputs for a unified customer progress CSV export.
class CustomerProgressExportInput {
  const CustomerProgressExportInput({
    required this.customerName,
    required this.progress,
    required this.measurements,
    this.overview,
    this.exportedAt,
    this.maxMeasurements = 10,
    this.labels,
  });

  final String customerName;
  final CustomerProgressSnapshot progress;
  final List<CustomerMeasurement> measurements;
  final CustomerOverviewSnapshot? overview;
  final DateTime? exportedAt;
  final int maxMeasurements;
  final CustomerProgressExportLabels? labels;
}

String buildCustomerProgressCsv(CustomerProgressExportInput input) {
  final exportedAt = input.exportedAt ?? DateTime.now();
  final labels = input.labels;
  final dateStamp = _formatDate(exportedAt);
  final lines = <String>[];

  if (labels != null) {
    lines.addAll([
      '# ${labels.title} — ${input.customerName}',
      '# ${labels.generatedOn}: $dateStamp',
      '#',
    ]);
    final narrative = buildCustomerProgressNarrative(
      labels: labels,
      progress: input.progress,
    );
    if (narrative.isNotEmpty) {
      lines.add(narrative);
      lines.add('#');
    }
    lines.add('# ${labels.dataSection}');
  } else {
    lines.addAll([
      '# PowerCoach Studio — ${input.customerName}',
      '# Generated: $dateStamp',
      '',
    ]);
  }

  lines.addAll([
    'section,adherence_30d,completed_sessions_30d,skipped_sessions_30d,last_session_date',
    _summaryRow(input.progress),
    '',
    'section,week_index,adherence',
    ..._weeklyRows(input.progress.last4Weeks, labels: labels),
    '',
    'section,measurement,value,unit,date',
    ..._measurementRows(
      overview: input.overview,
      measurements: input.measurements,
      maxMeasurements: input.maxMeasurements,
    ),
  ]);

  return '${lines.join('\n')}\n';
}

Future<ExportArtifact> exportCustomerProgressToCsv(
  CustomerProgressExportInput input,
) async {
  final csv = buildCustomerProgressCsv(input);
  final sanitized = input.customerName.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
  final base = sanitized.isEmpty ? 'customer_progress' : sanitized;
  final dateStamp = _formatDate(input.exportedAt ?? DateTime.now());
  return ExportArtifact(
    bytes: Uint8List.fromList(utf8.encode(csv)),
    filename: '${base}_progress_$dateStamp.csv',
    mimeType: 'text/csv',
  );
}

String _summaryRow(CustomerProgressSnapshot progress) {
  final adherence = progress.adherencePercent?.toStringAsFixed(3) ?? '';
  final lastSession = progress.lastSessionDate == null
      ? ''
      : _formatDate(progress.lastSessionDate!);
  return 'summary,$adherence,${progress.completedSessions30d},'
      '${progress.skippedSessions30d},$lastSession';
}

List<String> _weeklyRows(
  List<WeeklyAdherenceDot> dots, {
  CustomerProgressExportLabels? labels,
}) {
  if (dots.isEmpty) {
    final emptyLabel = labels?.weeklyNoData ?? '';
    return ['weekly,0,$emptyLabel'];
  }
  return [
    for (var i = 0; i < dots.length; i++)
      'weekly,$i,${_weeklyAdherenceLabel(dots[i], labels: labels)}',
  ];
}

String _weeklyAdherenceLabel(
  WeeklyAdherenceDot dot, {
  CustomerProgressExportLabels? labels,
}) {
  if (dot.completed == null) {
    return labels?.weeklyNoData ?? '';
  }
  if (labels == null) {
    return dot.completed! ? 'completed' : 'missed';
  }
  return dot.completed! ? labels.weeklyCompleted : labels.weeklyMissed;
}

List<String> _measurementRows({
  required CustomerOverviewSnapshot? overview,
  required List<CustomerMeasurement> measurements,
  required int maxMeasurements,
}) {
  final rows = <String>[];

  final weight = overview?.weightKg;
  if (weight != null) {
    rows.add('measures,profile_weight,$weight,kg,');
  }

  final sorted = List<CustomerMeasurement>.from(measurements)
    ..sort((a, b) => b.measurementDate.compareTo(a.measurementDate));

  for (final measurement in sorted.take(maxMeasurements)) {
    final date = _formatDate(measurement.measurementDate);
    _appendMeasurementMetric(rows, 'body_fat_percent', measurement.bodyFatPercent, '%', date);
    _appendMeasurementMetric(rows, 'muscle_mass_kg', measurement.muscleMassKg, 'kg', date);
    _appendMeasurementMetric(rows, 'bench_press_1rm', measurement.benchPress1RM, 'kg', date);
    _appendMeasurementMetric(rows, 'squat_1rm', measurement.squat1RM, 'kg', date);
    _appendMeasurementMetric(rows, 'deadlift_1rm', measurement.deadlift1RM, 'kg', date);
  }

  if (rows.isEmpty) {
    rows.add('measures,,,,');
  }

  return rows;
}

void _appendMeasurementMetric(
  List<String> rows,
  String key,
  double? value,
  String unit,
  String date,
) {
  if (value == null) return;
  rows.add('measures,$key,$value,$unit,$date');
}

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
