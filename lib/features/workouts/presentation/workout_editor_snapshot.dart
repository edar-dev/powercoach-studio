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
    'routineFingerprint': buildWorkoutRoutineFingerprint(routine),
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

/// Stable, allocation-light routine fingerprint for dirty tracking.
///
/// The save path still uses full JSON encoding. Dirty checks only need a stable
/// representation that changes when editable builder content changes.
String buildWorkoutRoutineFingerprint(WorkoutRoutine routine) {
  final buffer = StringBuffer()
    ..write(routine.name)
    ..write('|cw:')
    ..write(routine.currentWeek)
    ..write('|sd:')
    ..write(routine.startDate?.toIso8601String() ?? '')
    ..write('|ed:')
    ..write(routine.endDate?.toIso8601String() ?? '')
    ..write('|weeks:');

  for (final week in routine.weeks) {
    buffer
      ..write('w(')
      ..write(week.id)
      ..write(',')
      ..write(week.name)
      ..write(')');
    for (final day in week.days) {
      buffer
        ..write('d(')
        ..write(day.id)
        ..write(',')
        ..write(day.name)
        ..write(',')
        ..write(day.scheduledWeekday ?? '')
        ..write(')');
      for (final exercise in day.exercises) {
        buffer
          ..write('e(')
          ..write(exercise.id)
          ..write(',')
          ..write(exercise.name)
          ..write(',')
          ..write(exercise.shortName)
          ..write(',')
          ..write(exercise.sets)
          ..write(',')
          ..write(exercise.reps)
          ..write(',')
          ..write(exercise.rpe)
          ..write(',')
          ..write(exercise.note)
          ..write(',')
          ..write(exercise.customExerciseId ?? '')
          ..write(',')
          ..write(exercise.supersetGroupId ?? '')
          ..write(',')
          ..write(exercise.prescriptionScope.name)
          ..write(')');
        for (final set in exercise.effectiveSetDetails) {
          buffer
            ..write('s(')
            ..write(set.line)
            ..write(',')
            ..write(set.sets)
            ..write(',')
            ..write(set.reps)
            ..write(',')
            ..write(set.rpe)
            ..write(',')
            ..write(set.note)
            ..write(')');
        }
      }
    }
  }

  buffer.write('|mobility:');
  for (final section in routine.mobilitySections) {
    buffer
      ..write('ms(')
      ..write(section.id)
      ..write(',')
      ..write(section.name)
      ..write(',')
      ..write(section.scheduleHint)
      ..write(')');
  }
  for (final item in routine.mobilityItems) {
    buffer
      ..write('mi(')
      ..write(item.id)
      ..write(',')
      ..write(item.title)
      ..write(',')
      ..write(item.shortTitle)
      ..write(',')
      ..write(item.subtitle)
      ..write(',')
      ..write(item.sectionId)
      ..write(',')
      ..write(item.categoryIndex)
      ..write(',')
      ..write(item.customExerciseId ?? '')
      ..write(')');
  }

  _writeBoolMap(buffer, 'completed', routine.sessionCompletionByKey);
  _writeBoolMap(buffer, 'skipped', routine.sessionSkippedByKey);
  buffer.write('|overrides:');
  for (final key in routine.sessionOverrides.keys.toList()..sort()) {
    final override = routine.sessionOverrides[key]!;
    buffer
      ..write(key)
      ..write('=')
      ..write(override.kind.name)
      ..write(',')
      ..write(override.movedToDate?.toIso8601String() ?? '')
      ..write(';');
  }
  buffer.write('|executions:');
  for (final key in routine.sessionExecutions.keys.toList()..sort()) {
    final execution = routine.sessionExecutions[key]!;
    buffer
      ..write(key)
      ..write('=')
      ..write(execution.status.name)
      ..write(',')
      ..write(execution.sessionDate.toIso8601String())
      ..write(',')
      ..write(execution.completedAt?.toIso8601String() ?? '')
      ..write(',')
      ..write(execution.notes)
      ..write(',')
      ..write(execution.exercises.length)
      ..write(';');
  }

  return buffer.toString();
}

String? _normalizeOptionalText(String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

void _writeBoolMap(
  StringBuffer buffer,
  String label,
  Map<String, bool> values,
) {
  buffer
    ..write('|')
    ..write(label)
    ..write(':');
  for (final key in values.keys.toList()..sort()) {
    buffer
      ..write(key)
      ..write('=')
      ..write(values[key])
      ..write(';');
  }
}
