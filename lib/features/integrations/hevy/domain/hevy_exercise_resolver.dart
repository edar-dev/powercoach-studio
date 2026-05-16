import '../../../exercise_library/data/custom_exercise_item.dart';
import '../../../exercise_library/data/custom_exercise_repository.dart';
import '../../../workouts/data/workout_routine_model.dart';
import '../data/hevy_exercise_mapping_repository.dart';

/// Resolves plan exercises to Hevy template ids.
class HevyExerciseResolver {
  HevyExerciseResolver({
    CustomExerciseRepository? exerciseRepo,
    HevyExerciseMappingRepository? mappingRepo,
  })  : _exerciseRepo = exerciseRepo ?? CustomExerciseRepository(),
        _mappingRepo = mappingRepo ?? HevyExerciseMappingRepository();

  final CustomExerciseRepository _exerciseRepo;
  final HevyExerciseMappingRepository _mappingRepo;

  /// exercise.id -> hevyTemplateId (null = unmapped)
  Future<Map<String, HevyResolvedExercise>> resolveDay(Day day) async {
    final flat = await _exerciseRepo.listFlat();
    final byId = {for (final e in flat) e.id: e};
    final manual = await _mappingRepo.loadAll();

    final out = <String, HevyResolvedExercise>{};
    for (final e in day.exercises) {
      out[e.id] = await _resolveOne(e, byId, manual);
    }
    return out;
  }

  Future<HevyResolvedExercise> _resolveOne(
    Exercise exercise,
    Map<String, CustomExerciseItem> byId,
    Map<String, String> manual,
  ) async {
    if (exercise.customExerciseId != null) {
      final item = byId[exercise.customExerciseId];
      if (item != null &&
          item.hevyTemplateId != null &&
          item.hevyTemplateId!.isNotEmpty &&
          !item.isHevyFolder) {
        return HevyResolvedExercise(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          hevyTemplateId: item.hevyTemplateId,
          source: HevyResolveSource.library,
        );
      }
    }

    final key = exercise.customExerciseId ?? exercise.name.trim().toLowerCase();
    final mapped = manual[key];
    if (mapped != null && mapped.isNotEmpty) {
      return HevyResolvedExercise(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        hevyTemplateId: mapped,
        source: HevyResolveSource.manualMapping,
      );
    }

    return HevyResolvedExercise(
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      hevyTemplateId: null,
      source: HevyResolveSource.unmapped,
    );
  }
}

enum HevyResolveSource { library, manualMapping, unmapped }

class HevyResolvedExercise {
  const HevyResolvedExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.hevyTemplateId,
    required this.source,
  });

  final String exerciseId;
  final String exerciseName;
  final String? hevyTemplateId;
  final HevyResolveSource source;

  bool get isMapped => hevyTemplateId != null && hevyTemplateId!.isNotEmpty;
}
