import '../../../workouts/data/workout_routine_model.dart';
import 'hevy_prescription_parser.dart';

/// Builds Hevy `POST /v1/routines` JSON from a [Day].
class HevyRoutineMapper {
  HevyRoutineMapper({HevyPrescriptionParser? parser})
      : _parser = parser ?? HevyPrescriptionParser();

  final HevyPrescriptionParser _parser;

  Map<String, dynamic> buildRoutineBody({
    required String title,
    required Day day,
    required Map<String, String> exerciseNameToTemplateId,
    String? notes,
  }) {
    final exercises = <Map<String, dynamic>>[];
    var index = 0;

    for (final partition in partitionExercisesBySuperset(day.exercises)) {
      if (partition is Exercise) {
        final templateId = exerciseNameToTemplateId[partition.id] ??
            exerciseNameToTemplateId[partition.name];
        if (templateId == null || templateId.isEmpty) continue;
        exercises.add(
          _exercisePayload(
            templateId: templateId,
            exercise: partition,
            index: index++,
          ),
        );
      } else if (partition is List<Exercise>) {
        for (final e in partition) {
          final templateId =
              exerciseNameToTemplateId[e.id] ?? exerciseNameToTemplateId[e.name];
          if (templateId == null || templateId.isEmpty) continue;
          exercises.add(
            _exercisePayload(templateId: templateId, exercise: e, index: index++),
          );
        }
      }
    }

    return {
      'routine': {
        'title': title,
        'folder_id': null,
        'notes': notes ?? '',
        'exercises': exercises,
      },
    };
  }

  Map<String, dynamic> _exercisePayload({
    required String templateId,
    required Exercise exercise,
    required int index,
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
          },
        )
        .toList();

    final notes = <String>[
      if (exercise.note.trim().isNotEmpty) exercise.note.trim(),
      for (final d in exercise.effectiveSetDetails)
        if (d.displayText.trim().isNotEmpty) d.displayText.trim(),
    ].join('\n');

    return {
      'exercise_template_id': templateId,
      'superset_id': null,
      'rest_seconds': null,
      'notes': notes,
      'sets': sets.isEmpty
          ? [
              {'type': 'normal', 'reps': null, 'weight_kg': null},
            ]
          : sets,
    };
  }
}
