import 'dart:convert';

import '../data/workout_routine_model.dart';

String buildWorkoutEditorSnapshot({
  required WorkoutRoutine routine,
  required String planName,
  required int initialWeekNumber,
  String? phase,
  String? tags,
  String? notes,
}) {
  final normalizedPhase = _normalizeOptionalText(phase);
  final normalizedTags = _normalizeOptionalText(tags);
  final normalizedNotes = _normalizeOptionalText(notes);

  return jsonEncode({
    'routine': routine.toJson(),
    'planName': planName.trim(),
    'initialWeekNumber': initialWeekNumber,
    'phase': normalizedPhase,
    'tags': normalizedTags,
    'notes': normalizedNotes,
  });
}

bool isWorkoutEditorDirty({
  required String? savedSnapshot,
  required String currentSnapshot,
}) {
  if (savedSnapshot == null) {
    return false;
  }
  return savedSnapshot != currentSnapshot;
}

String? _normalizeOptionalText(String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}
