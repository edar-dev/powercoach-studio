import '../../../workouts/data/workout_routine_model.dart';
import '../../../workouts/domain/density_block.dart';
import 'hevy_prescription_parser.dart';

/// Builds Hevy exercise JSON shared by routine and workout create payloads.
class HevyExercisePayloadBuilder {
  HevyExercisePayloadBuilder({HevyPrescriptionParser? parser})
      : _parser = parser ?? HevyPrescriptionParser();

  final HevyPrescriptionParser _parser;

  List<Map<String, dynamic>> buildExercisesForDay(
    Day day,
    Map<String, String> exerciseNameToTemplateId, {
    bool assignSupersetIds = false,
  }) {
    final exercises = <Map<String, dynamic>>[];
    var groupCounter = 1;

    for (final partition in partitionExercisesBySuperset(day.exercises)) {
      if (partition is Exercise) {
        final templateId = _templateId(partition, exerciseNameToTemplateId);
        if (templateId == null) continue;
        exercises.add(
          buildExercise(
            templateId: templateId,
            exercise: partition,
            supersetId: assignSupersetIds && partition.supersetGroupId != null
                ? groupCounter++
                : null,
          ),
        );
      } else if (partition is List<Exercise>) {
        final groupId = assignSupersetIds ? groupCounter++ : null;
        final densityPrefix = densityBlockHevyNotePrefix(day, partition);
        var isFirstInGroup = true;
        for (final e in partition) {
          final templateId = _templateId(e, exerciseNameToTemplateId);
          if (templateId == null) continue;
          exercises.add(
            buildExercise(
              templateId: templateId,
              exercise: e,
              supersetId: groupId,
              notesPrefix: isFirstInGroup ? densityPrefix : null,
            ),
          );
          isFirstInGroup = false;
        }
      }
    }
    return exercises;
  }

  Map<String, dynamic> buildExercise({
    required String templateId,
    required Exercise exercise,
    int? supersetId,
    String? notesPrefix,
  }) {
    final parsedSets = _parser.parseExercise(exercise);
    final sets = parsedSets
        .map(
          (s) => {
            'type': s.type,
            'weight_kg': s.weightKg,
            'reps': s.reps,
            'distance_meters': null,
            'duration_seconds': s.durationSeconds,
            if (s.rpe != null) 'rpe': s.rpe,
          },
        )
        .toList();

    final notes = <String>[
      if (notesPrefix != null && notesPrefix.trim().isNotEmpty)
        notesPrefix.trim(),
      if (exercise.note.trim().isNotEmpty) exercise.note.trim(),
      for (final d in exercise.effectiveSetDetails)
        if (d.displayText.trim().isNotEmpty) d.displayText.trim(),
    ].join('\n');

    return {
      'exercise_template_id': templateId,
      'superset_id': supersetId,
      'rest_seconds': null,
      'notes': notes,
      'sets': sets.isEmpty
          ? [
              {'type': 'normal', 'reps': null, 'weight_kg': null},
            ]
          : sets,
    };
  }

  String? _templateId(Exercise exercise, Map<String, String> idByName) {
    return idByName[exercise.id] ?? idByName[exercise.name];
  }
}
