import 'dart:convert';
import 'dart:typed_data';

import '../../../core/export/export_artifact.dart';
import '../data/models/customer_exercise_record.dart';
import '../data/models/customer_measurement.dart';
import 'customer_overview_metrics.dart';
import 'customer_progress_metrics.dart';

/// Inputs for a unified customer progress CSV export.
class CustomerProgressExportInput {
  const CustomerProgressExportInput({
    required this.customerName,
    required this.progress,
    required this.measurements,
    this.overview,
    this.exerciseRecords = const [],
    this.exportedAt,
    this.maxMeasurements = 10,
    this.maxPersonalRecords = 10,
  });

  final String customerName;
  final CustomerProgressSnapshot progress;
  final List<CustomerMeasurement> measurements;
  final CustomerOverviewSnapshot? overview;
  final List<CustomerExerciseRecord> exerciseRecords;
  final DateTime? exportedAt;
  final int maxMeasurements;
  final int maxPersonalRecords;
}

String buildCustomerProgressCsv(CustomerProgressExportInput input) {
  final exportedAt = input.exportedAt ?? DateTime.now();
  final lines = <String>[
    '# PowerCoach Studio — ${input.customerName}',
    '# Generated: ${_formatDate(exportedAt)}',
    '',
    'section,adherence_30d,completed_sessions_30d,skipped_sessions_30d,last_session_date',
    _summaryRow(input.progress),
    '',
    'section,week_index,adherence',
    ..._weeklyRows(input.progress.last4Weeks),
    '',
    'section,exercise,value,unit,date',
    ..._personalRecordRows(
      progress: input.progress,
      exerciseRecords: input.exerciseRecords,
      maxPersonalRecords: input.maxPersonalRecords,
    ),
    '',
    'section,measurement,value,unit,date',
    ..._measurementRows(
      overview: input.overview,
      measurements: input.measurements,
      maxMeasurements: input.maxMeasurements,
    ),
  ];

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

List<String> _weeklyRows(List<WeeklyAdherenceDot> dots) {
  if (dots.isEmpty) {
    return const ['weekly,0,'];
  }
  return [
    for (var i = 0; i < dots.length; i++)
      'weekly,$i,${_weeklyAdherenceLabel(dots[i])}',
  ];
}

String _weeklyAdherenceLabel(WeeklyAdherenceDot dot) {
  if (dot.completed == null) return '';
  return dot.completed! ? 'completed' : 'missed';
}

List<String> _personalRecordRows({
  required CustomerProgressSnapshot progress,
  required List<CustomerExerciseRecord> exerciseRecords,
  required int maxPersonalRecords,
}) {
  if (exerciseRecords.isNotEmpty) {
    final sorted = List<CustomerExerciseRecord>.from(exerciseRecords)
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return sorted
        .take(maxPersonalRecords)
        .map(
          (record) =>
              'pr,${_escapeCsv(record.displayName)},${record.value},'
              '${_escapeCsv(record.unit)},${_formatDate(record.recordedAt)}',
        )
        .toList();
  }

  return progress.recentPrs
      .map(
        (pr) =>
            'pr,${_escapeCsv(pr.exerciseName)},${pr.value},'
            '${_escapeCsv(pr.unit)},${_formatDate(pr.recordedAt)}',
      )
      .toList();
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
    _appendMeasurementMetric(rows, 'waist_cm', measurement.waistCm, 'cm', date);
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

String _escapeCsv(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
