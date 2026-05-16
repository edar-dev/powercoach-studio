import '../data/hevy_api_client.dart';
import '../data/hevy_api_models.dart';
import '../../../workouts/data/workout_routine_model.dart';
import 'hevy_exercise_resolver.dart';
import 'hevy_routine_mapper.dart';

class HevyExportDayResult {
  const HevyExportDayResult({
    required this.success,
    this.routineId,
    this.unmapped = const [],
    this.errorMessage,
  });

  final bool success;
  final String? routineId;
  final List<HevyResolvedExercise> unmapped;
  final String? errorMessage;
}

/// Exports a single plan day to a Hevy routine.
class HevyExportDayUseCase {
  HevyExportDayUseCase({
    HevyApiClient? api,
    HevyExerciseResolver? resolver,
    HevyRoutineMapper? mapper,
  })  : _api = api ?? HevyApiClient(),
        _resolver = resolver ?? HevyExerciseResolver(),
        _mapper = mapper ?? HevyRoutineMapper();

  final HevyApiClient _api;
  final HevyExerciseResolver _resolver;
  final HevyRoutineMapper _mapper;

  Future<HevyExportDayResult> execute({
    required Day day,
    required String programName,
    int? weekIndex,
    int? dayIndex,
    String? customerName,
  }) async {
    try {
      final resolved = await _resolver.resolveDay(day);
      final unmapped =
          resolved.values.where((r) => !r.isMapped).toList();
      if (unmapped.isNotEmpty) {
        return HevyExportDayResult(success: false, unmapped: unmapped);
      }

      final idByExerciseId = {
        for (final r in resolved.values)
          if (r.hevyTemplateId != null) r.exerciseId: r.hevyTemplateId!,
      };
      final idByName = <String, String>{};
      for (var i = 0; i < day.exercises.length; i++) {
        final e = day.exercises[i];
        final r = resolved[e.id];
        if (r?.hevyTemplateId != null) {
          idByName[e.id] = r!.hevyTemplateId!;
          idByName[e.name] = r.hevyTemplateId!;
        }
      }

      final titleParts = <String>[
        programName.trim(),
        if (day.name.trim().isNotEmpty) day.name.trim(),
        if (weekIndex != null && dayIndex != null)
          'W${weekIndex + 1} D${dayIndex + 1}',
      ];
      final notes = customerName != null && customerName.trim().isNotEmpty
          ? 'Exported from PowerCoach Studio · $customerName'
          : 'Exported from PowerCoach Studio';

      final body = _mapper.buildRoutineBody(
        title: titleParts.join(' · '),
        day: day,
        exerciseNameToTemplateId: {...idByName, ...idByExerciseId},
        notes: notes,
      );

      final response = await _api.createRoutine(body);
      final routine = response['routine'] as Map<String, dynamic>?;
      final id = routine?['id']?.toString() ?? response['id']?.toString();

      return HevyExportDayResult(success: true, routineId: id);
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
