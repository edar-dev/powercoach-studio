import '../../../workouts/data/workout_routine_model.dart';
import 'hevy_exercise_payload_builder.dart';

/// Builds Hevy `POST /v1/routines` JSON from a [Day].
class HevyRoutineMapper {
  HevyRoutineMapper({HevyExercisePayloadBuilder? payloadBuilder})
      : _payloadBuilder = payloadBuilder ?? HevyExercisePayloadBuilder();

  final HevyExercisePayloadBuilder _payloadBuilder;

  Map<String, dynamic> buildRoutineBody({
    required String title,
    required Day day,
    required Map<String, String> exerciseNameToTemplateId,
    String? notes,
  }) {
    final exercises = _payloadBuilder.buildExercisesForDay(
      day,
      exerciseNameToTemplateId,
    );

    return {
      'routine': {
        'title': title,
        'folder_id': null,
        'notes': notes ?? '',
        'exercises': exercises,
      },
    };
  }
}
