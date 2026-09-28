import '../../../exercise_library/data/custom_exercise_item.dart';
import '../../../exercise_library/data/custom_exercise_repository.dart';
import '../../../exercise_library/data/pinned_exercises_store.dart';
import '../../../exercise_library/data/recent_exercises_store.dart';
import '../../../exercise_library/domain/default_exercise_catalog_seeder.dart';
import '../../domain/exercise_picker_index_helpers.dart';

/// Loaded exercise picker state for the add-exercise sheet.
class ExerciseAddSheetPickerData {
  const ExerciseAddSheetPickerData({
    required this.exerciseOptions,
    required this.recentExercises,
    required this.pinnedExerciseIds,
    required this.exerciseDepth,
    required this.exerciseParentName,
  });

  final List<CustomExerciseItem> exerciseOptions;
  final List<CustomExerciseItem> recentExercises;
  final Set<String> pinnedExerciseIds;
  final Map<String, int> exerciseDepth;
  final Map<String, String> exerciseParentName;
}

class ExerciseAddSheetLoader {
  ExerciseAddSheetLoader({
    CustomExerciseRepository? customExerciseRepo,
    RecentExercisesStore? recentStore,
    PinnedExercisesStore? pinnedStore,
  })  : _customExerciseRepo = customExerciseRepo ?? CustomExerciseRepository(),
        _recentStore = recentStore ?? RecentExercisesStore.instance,
        _pinnedStore = pinnedStore ?? PinnedExercisesStore.instance;

  final CustomExerciseRepository _customExerciseRepo;
  final RecentExercisesStore _recentStore;
  final PinnedExercisesStore _pinnedStore;

  Future<ExerciseAddSheetPickerData> loadPickerData() async {
    await DefaultExerciseCatalogSeeder(
      exerciseRepo: _customExerciseRepo,
    ).ensureSeeded();
    final items = await _customExerciseRepo.getTree();
    final index = buildExercisePickerIndex(items);
    final recentIds = await _recentStore.getRecentIds();
    final pinnedIds = await _pinnedStore.getPinnedIds();
    final byId = {for (final e in index.flat) e.id: e};
    final recent = recentIds
        .map((id) => byId[id])
        .whereType<CustomExerciseItem>()
        .toList();
    final sorted = sortExercisePickerOptions(
      flat: index.flat,
      pinnedIds: pinnedIds,
      recentIds: recentIds,
      displayName: (e) => exercisePickerDisplayName(
        e,
        index.parentNameById,
      ),
    );
    return ExerciseAddSheetPickerData(
      exerciseOptions: sorted,
      recentExercises: recent.take(6).toList(),
      pinnedExerciseIds: pinnedIds,
      exerciseDepth: Map<String, int>.from(index.depthById),
      exerciseParentName: Map<String, String>.from(index.parentNameById),
    );
  }
}
