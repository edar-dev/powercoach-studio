import '../../../exercise_library/data/custom_exercise_item.dart';
import '../../../exercise_library/data/custom_exercise_repository.dart';
import '../../../exercise_library/data/pinned_exercises_store.dart';
import '../../../exercise_library/data/recent_exercises_store.dart';
import '../../../exercise_library/domain/default_exercise_catalog_seeder.dart';
import '../../domain/exercise_picker_index_helpers.dart';
import '../../domain/powercoach_catalog_dedupe_cleanup.dart';

/// Loaded exercise picker state for the add-exercise sheet.
class ExerciseAddSheetPickerData {
  const ExerciseAddSheetPickerData({
    required this.exerciseOptions,
    required this.treeRoots,
    required this.recentExercises,
    required this.pinnedExerciseIds,
    required this.exerciseDepth,
    required this.exerciseParentName,
  });

  final List<CustomExerciseItem> exerciseOptions;

  /// Deduped / pruned forest for the visual tree body.
  final List<CustomExerciseItem> treeRoots;
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
    await ensurePowercoachCatalogDedupeCleanup(
      exerciseRepo: _customExerciseRepo,
    );
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
    final treeRoots = sortExercisePickerTree(
      index.treeRoots,
      pinnedIds: pinnedIds,
    );
    return ExerciseAddSheetPickerData(
      exerciseOptions: sorted,
      treeRoots: treeRoots,
      recentExercises: recent.take(6).toList(),
      pinnedExerciseIds: pinnedIds,
      exerciseDepth: Map<String, int>.from(index.depthById),
      exerciseParentName: Map<String, String>.from(index.parentNameById),
    );
  }
}
