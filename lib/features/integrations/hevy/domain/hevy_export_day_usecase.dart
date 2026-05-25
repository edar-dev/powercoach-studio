import '../data/hevy_api_client.dart';
import '../data/hevy_api_models.dart';
import '../../../workouts/data/workout_routine_model.dart';
import 'hevy_exercise_resolver.dart';
import 'hevy_routine_mapper.dart';
import 'hevy_workout_mapper.dart';

enum HevyExportTarget { routine, workout }

class HevyExportDayResult {
  const HevyExportDayResult({
    required this.success,
    this.exportedId,
    this.target,
    this.unmapped = const [],
    this.errorMessage,
  });

  final bool success;
  final String? exportedId;
  final HevyExportTarget? target;
  final List<HevyResolvedExercise> unmapped;
  final String? errorMessage;

  /// Back-compat for routine-only callers.
  String? get routineId =>
      target == HevyExportTarget.routine ? exportedId : null;
}

/// Exports a single plan day to Hevy (routine or logged workout).
class HevyExportDayUseCase {
  HevyExportDayUseCase({
    HevyApiClient? api,
    HevyExerciseResolver? resolver,
    HevyRoutineMapper? routineMapper,
    HevyWorkoutMapper? workoutMapper,
  })  : _api = api ?? HevyApiClient(),
        _resolver = resolver ?? HevyExerciseResolver(),
        _routineMapper = routineMapper ?? HevyRoutineMapper(),
        _workoutMapper = workoutMapper ?? HevyWorkoutMapper();

  final HevyApiClient _api;
  final HevyExerciseResolver _resolver;
  final HevyRoutineMapper _routineMapper;
  final HevyWorkoutMapper _workoutMapper;

  Future<HevyExportDayResult> execute({
    required Day day,
    required String programName,
    required HevyExportTarget target,
    int? weekIndex,
    int? dayIndex,
    String? customerName,
    DateTime? workoutStartTime,
    DateTime? workoutEndTime,
  }) async {
    try {
      final resolved = await _resolver.resolveDay(day);
      final unmapped = resolved.values.where((r) => !r.isMapped).toList();
      if (unmapped.isNotEmpty) {
        return HevyExportDayResult(success: false, unmapped: unmapped);
      }

      final idByExerciseId = {
        for (final r in resolved.values)
          if (r.hevyTemplateId != null) r.exerciseId: r.hevyTemplateId!,
      };
      final idByName = <String, String>{};
      for (final e in day.exercises) {
        final r = resolved[e.id];
        if (r?.hevyTemplateId != null) {
          idByName[e.id] = r!.hevyTemplateId!;
          idByName[e.name] = r.hevyTemplateId!;
        }
      }
      final templateIds = {...idByName, ...idByExerciseId};

      final titleParts = <String>[
        programName.trim(),
        if (day.name.trim().isNotEmpty) day.name.trim(),
        if (weekIndex != null && dayIndex != null)
          'W${weekIndex + 1} D${dayIndex + 1}',
      ];
      final title = titleParts.join(' · ');
      final notes = customerName != null && customerName.trim().isNotEmpty
          ? 'Exported from PowerCoach Studio · $customerName'
          : 'Exported from PowerCoach Studio';

      if (target == HevyExportTarget.routine) {
        final body = _routineMapper.buildRoutineBody(
          title: title,
          day: day,
          exerciseNameToTemplateId: templateIds,
          notes: notes,
        );
        final response = await _api.createRoutine(body);
        final id = parseHevyCreatedRoutineId(response);
        return HevyExportDayResult(
          success: true,
          exportedId: id,
          target: HevyExportTarget.routine,
        );
      }

      final body = _workoutMapper.buildWorkoutBody(
        title: title,
        day: day,
        exerciseNameToTemplateId: templateIds,
        description: notes,
        startTime: workoutStartTime,
        endTime: workoutEndTime,
      );
      final response = await _api.createWorkout(body);
      final id = parseHevyCreatedWorkoutId(response);
      return HevyExportDayResult(
        success: true,
        exportedId: id,
        target: HevyExportTarget.workout,
      );
    } on HevyApiException catch (e) {
      return HevyExportDayResult(
        success: false,
        errorMessage: e.message,
        unmapped: const [],
      );
    } catch (e) {
      return HevyExportDayResult(
        success: false,
        errorMessage: e.toString(),
        unmapped: const [],
      );
    }
  }
}
