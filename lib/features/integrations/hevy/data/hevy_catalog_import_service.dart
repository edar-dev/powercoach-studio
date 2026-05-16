import '../../../exercise_library/data/custom_exercise_repository.dart';
import '../domain/hevy_catalog_hierarchy_builder.dart';
import 'hevy_api_client.dart';
import 'hevy_api_models.dart';

typedef HevyImportProgress = void Function(int current, int total, String label);

/// Full fetch + hierarchical upsert into custom exercise library.
class HevyCatalogImportService {
  HevyCatalogImportService({
    HevyApiClient? api,
    CustomExerciseRepository? exerciseRepo,
    HevyCatalogHierarchyBuilder? hierarchyBuilder,
  })  : _api = api ?? HevyApiClient(),
        _exerciseRepo = exerciseRepo ?? CustomExerciseRepository(),
        _builder = hierarchyBuilder ?? HevyCatalogHierarchyBuilder();

  final HevyApiClient _api;
  final CustomExerciseRepository _exerciseRepo;
  final HevyCatalogHierarchyBuilder _builder;

  Future<int> importAllFromApi({HevyImportProgress? onProgress}) async {
    try {
      final templates = await _api.fetchAllExerciseTemplates(
        onPage: (page, pageCount) {
          onProgress?.call(page, pageCount, 'Fetching page $page/$pageCount');
        },
      );
      return importFromTemplates(templates, onProgress: onProgress);
    } catch (e) {
      HevyApiClient.handleDioError(e);
    }
  }

  Future<int> importFromTemplates(
    List<HevyExerciseTemplateDto> templates, {
    HevyImportProgress? onProgress,
  }) async {
    final nodes = _builder.build(templates);
    return _exerciseRepo.upsertHevyCatalogNodes(
      nodes,
      onProgress: (current, total) {
        onProgress?.call(current, total, 'Importing $current/$total');
      },
    );
  }
}
