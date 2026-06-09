import 'dart:convert';
import 'dart:typed_data';

import '../../../core/export/export_artifact.dart';
import '../data/models/customer_measurement.dart';

Future<ExportArtifact> exportMeasurementsToCsv(
  List<CustomerMeasurement> measurements,
  String fileBaseName,
) async {
  final sorted = List<CustomerMeasurement>.from(measurements)
    ..sort((a, b) => a.measurementDate.compareTo(b.measurementDate));

  final header = [
    'measurementDate',
    'squat1RM',
    'benchPress1RM',
    'deadlift1RM',
    'tricepsSkinfold',
    'bicepsSkinfold',
    'subscapularSkinfold',
    'iliacSkinfold',
    'abdominalSkinfold',
    'thighSkinfold',
    'bodyFatPercent',
    'muscleMassKg',
    'waterPercent',
    'fatMassKg',
    'chestCm',
    'waistCm',
    'armsCm',
    'thighsCm',
    'notes',
  ];

  final rows = <String>[header.join(',')];
  for (final measurement in sorted) {
    rows.add(
      [
        CustomerMeasurement.toDateString(measurement.measurementDate),
        _formatNumber(measurement.squat1RM),
        _formatNumber(measurement.benchPress1RM),
        _formatNumber(measurement.deadlift1RM),
        _formatNumber(measurement.tricepsSkinfold),
        _formatNumber(measurement.bicepsSkinfold),
        _formatNumber(measurement.subscapularSkinfold),
        _formatNumber(measurement.iliacSkinfold),
        _formatNumber(measurement.abdominalSkinfold),
        _formatNumber(measurement.thighSkinfold),
        _formatNumber(measurement.bodyFatPercent),
        _formatNumber(measurement.muscleMassKg),
        _formatNumber(measurement.waterPercent),
        _formatNumber(measurement.fatMassKg),
        _formatNumber(measurement.chestCm),
        _formatNumber(measurement.waistCm),
        _formatNumber(measurement.armsCm),
        _formatNumber(measurement.thighsCm),
        _escapeCsv(measurement.notes ?? ''),
      ].join(','),
    );
  }

  final sanitized = fileBaseName.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
  final base = sanitized.isEmpty ? 'measurements' : sanitized;
  return ExportArtifact(
    bytes: Uint8List.fromList(utf8.encode(rows.join('\n'))),
    filename: '${base}_${DateTime.now().millisecondsSinceEpoch}.csv',
    mimeType: 'text/csv',
  );
}

String _formatNumber(double? value) {
  if (value == null) {
    return '';
  }
  return value.toString();
}

String _escapeCsv(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
