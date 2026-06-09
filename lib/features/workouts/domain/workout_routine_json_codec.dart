import 'dart:convert';

import '../data/workout_routine_model.dart';

const int workoutRoutineJsonSchemaVersion = 1;
const String workoutRoutineJsonFormat = 'powercoach-workout-routine';

/// Wraps [routine] in a versioned export envelope for interchange.
Map<String, dynamic> encodeWorkoutRoutineEnvelope(WorkoutRoutine routine) {
  return {
    'schemaVersion': workoutRoutineJsonSchemaVersion,
    'format': workoutRoutineJsonFormat,
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'routine': routine.toJson(),
  };
}

/// Parses JSON text into a [WorkoutRoutine].
///
/// Accepts the export envelope or a raw planData object.
WorkoutRoutine decodeWorkoutRoutineJson(String jsonText) {
  final decoded = jsonDecode(jsonText);
  if (decoded is! Map) {
    throw const FormatException('Root must be a JSON object');
  }
  final map = decoded.cast<String, dynamic>();
  final routineMap = _extractRoutineMap(map);
  if (routineMap['weeks'] is! List) {
    throw const FormatException('Missing weeks array');
  }
  return WorkoutRoutine.fromJson(routineMap);
}

String encodeWorkoutRoutineJson(WorkoutRoutine routine) {
  return const JsonEncoder.withIndent('  ').convert(
    encodeWorkoutRoutineEnvelope(routine),
  );
}

Map<String, dynamic> _extractRoutineMap(Map<String, dynamic> map) {
  final format = map['format']?.toString();
  if (format == workoutRoutineJsonFormat || map.containsKey('routine')) {
    final routine = map['routine'];
    if (routine is! Map) {
      throw const FormatException('Invalid routine envelope');
    }
    final version = map['schemaVersion'];
    if (version is num && version.toInt() > workoutRoutineJsonSchemaVersion) {
      throw FormatException('Unsupported schema version: ${version.toInt()}');
    }
    return routine.cast<String, dynamic>();
  }
  return map;
}
