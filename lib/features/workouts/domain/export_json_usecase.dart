import 'dart:convert';
import 'dart:typed_data';

import '../../../core/export/export_artifact.dart';
import '../data/workout_routine_model.dart';
import 'workout_routine_json_codec.dart';

/// Exports [routine] as an indented JSON file (versioned envelope).
Future<ExportArtifact> exportWorkoutRoutineToJson(WorkoutRoutine routine) async {
  final jsonText = encodeWorkoutRoutineJson(routine);
  final sanitizedName = routine.name.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
  final base = sanitizedName.isEmpty ? 'workout_plan' : sanitizedName;
  final stamp = DateTime.now().toUtc().toIso8601String().split('T').first;
  return ExportArtifact(
    bytes: Uint8List.fromList(utf8.encode(jsonText)),
    filename: '${base}_$stamp.json',
    mimeType: 'application/json',
  );
}
