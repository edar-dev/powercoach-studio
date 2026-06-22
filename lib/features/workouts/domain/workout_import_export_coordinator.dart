import 'dart:convert';

import '../data/workout_routine_model.dart';
import 'workout_routine_json_codec.dart';

enum WorkoutImportFailureReason { empty, invalidFormat }

class WorkoutImportResult {
  const WorkoutImportResult._({this.routine, this.failureReason});

  const WorkoutImportResult.success(WorkoutRoutine routine)
    : this._(routine: routine);

  const WorkoutImportResult.failure(WorkoutImportFailureReason reason)
    : this._(failureReason: reason);

  final WorkoutRoutine? routine;
  final WorkoutImportFailureReason? failureReason;

  bool get isSuccess => routine != null;
}

WorkoutImportResult parseWorkoutRoutineImport(String content) {
  if (content.trim().isEmpty) {
    return const WorkoutImportResult.failure(WorkoutImportFailureReason.empty);
  }
  try {
    return WorkoutImportResult.success(decodeWorkoutRoutineJson(content));
  } on FormatException {
    return const WorkoutImportResult.failure(
      WorkoutImportFailureReason.invalidFormat,
    );
  } on Object {
    return const WorkoutImportResult.failure(
      WorkoutImportFailureReason.invalidFormat,
    );
  }
}

String encodeWorkoutRoutineExport(WorkoutRoutine routine) {
  return const JsonEncoder.withIndent('  ').convert(routine.toJson());
}
