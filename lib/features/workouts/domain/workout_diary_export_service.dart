import 'dart:convert';
import 'dart:typed_data';

import '../../../core/export/export_artifact.dart';
import '../../dashboard/domain/plan_calendar_event.dart';
import 'session_execution_service.dart';
import 'workout_diary_metrics.dart';

/// Builds a CSV [ExportArtifact] from the currently visible diary entries.
Future<ExportArtifact> exportWorkoutDiaryToCsv({
  required List<SessionExecutionEntry> entries,
  required String Function(String customerId) customerNameOf,
  DateTime? exportedAt,
}) async {
  final stamp = exportedAt ?? DateTime.now();
  final lines = <String>[
    'date,customer,plan,status,volume_kg,rpe_samples,avg_rpe',
  ];

  for (final entry in entries) {
    final execution = entry.execution;
    final when = execution.completedAt ?? execution.sessionDate;
    final metrics = computeSessionMetrics(execution);
    final status = switch (execution.status) {
      PlanSessionStatus.completed => 'completed',
      PlanSessionStatus.skipped => 'skipped',
      PlanSessionStatus.planned => 'planned',
    };
    final volume = metrics.hasParsableVolume
        ? metrics.volumeKg.toStringAsFixed(1)
        : '';
    final avgRpe = metrics.hasRpeSamples && metrics.avgRpe != null
        ? formatAvgRpe(metrics.avgRpe!)
        : '';
    lines.add(
      [
        _csv(_formatDate(when)),
        _csv(customerNameOf(entry.customerId)),
        _csv(entry.planName),
        _csv(status),
        _csv(volume),
        _csv('${metrics.rpeSampleCount}'),
        _csv(avgRpe),
      ].join(','),
    );
  }

  final csv = '${lines.join('\n')}\n';
  final dateStamp = _formatDate(stamp);
  return ExportArtifact(
    bytes: Uint8List.fromList(utf8.encode(csv)),
    filename: 'workout_diary_$dateStamp.csv',
    mimeType: 'text/csv',
  );
}

String _formatDate(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

String _csv(String value) {
  final needsQuotes =
      value.contains(',') || value.contains('"') || value.contains('\n');
  if (!needsQuotes) return value;
  return '"${value.replaceAll('"', '""')}"';
}
