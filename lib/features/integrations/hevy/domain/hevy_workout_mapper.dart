import '../../../workouts/data/workout_routine_model.dart';
import 'hevy_exercise_payload_builder.dart';

/// Builds Hevy `POST /v1/workouts` JSON from a [Day].
class HevyWorkoutMapper {
  HevyWorkoutMapper({HevyExercisePayloadBuilder? payloadBuilder})
      : _payloadBuilder = payloadBuilder ?? HevyExercisePayloadBuilder();

  final HevyExercisePayloadBuilder _payloadBuilder;

  /// Default session length when creating a workout to start now.
  static const defaultSessionDuration = Duration(minutes: 90);

  Map<String, dynamic> buildWorkoutBody({
    required String title,
    required Day day,
    required Map<String, String> exerciseNameToTemplateId,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    final start = (startTime ?? DateTime.now()).toUtc();
    final end = (endTime ?? start.add(defaultSessionDuration)).toUtc();
    final exercises = _payloadBuilder.buildExercisesForDay(
      day,
      exerciseNameToTemplateId,
      assignSupersetIds: true,
    );

    return {
      'workout': {
        'title': title,
        'description': description ?? '',
        'start_time': _toIso8601(start),
        'end_time': _toIso8601(end),
        'is_private': false,
        'exercises': exercises,
      },
    };
  }

  static String _toIso8601(DateTime dt) {
    return dt.toIso8601String().replaceFirst(RegExp(r'\.\d+'), '');
  }
}
