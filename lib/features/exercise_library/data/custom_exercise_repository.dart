import '../../integrations/hevy/data/hevy_api_models.dart';
import '../../integrations/hevy/domain/exercise_catalog_source.dart';
import '../../../core/sync/offline_models.dart';
import '../../../core/sync/offline_repository_support.dart';
import 'custom_exercise_item.dart';

/// Local-only custom exercise library.
class CustomExerciseRepository {
  CustomExerciseRepository({OfflineRepositorySupport? offline})
      : _offline = offline ?? OfflineRepositorySupport();

  final OfflineRepositorySupport _offline;

  static const _scope = 'library';

  Future<List<CustomExerciseItem>> getTree({
    bool? mobility,
    String? catalogSource,
  }) async {
    final items = await listFlat(mobility: mobility, catalogSource: catalogSource);
    return _buildTree(items);
  }

  Future<List<CustomExerciseItem>> listFlat({
    bool? mobility,
    String? catalogSource,
  }) async {
    final entities = await _offline.readLocalEntities(
      OfflineEntityType.customExercise,
      scopeId: _scope,
    );
    return entities
        .where((e) => e['id'] != null)
        .map(CustomExerciseItem.fromJson)
        .where((e) => mobility == null || e.isMobility == mobility)
        .where((e) => catalogSource == null || e.catalogSource == catalogSource)
        .toList();
  }

  Future<CustomExerciseItem?> findByHevyTemplateId(String templateId) async {
    final flat = await listFlat(catalogSource: ExerciseCatalogSource.hevy);
    for (final item in flat) {
      if (item.hevyTemplateId == templateId) return item;
    }
    return null;
  }

  List<CustomExerciseItem> _buildTree(List<CustomExerciseItem> items) {
    final byId = <String, CustomExerciseItem>{
      for (final item in items)
        item.id: CustomExerciseItem(
          id: item.id,
          name: item.name,
          description: item.description,
          parentId: item.parentId,
          sortOrder: item.sortOrder,
          isMobility: item.isMobility,
          catalogSource: item.catalogSource,
          hevyTemplateId: item.hevyTemplateId,
          hevyStableKey: item.hevyStableKey,
          isHevyFolder: item.isHevyFolder,
          createdAt: item.createdAt,
          updatedAt: item.updatedAt,
          rowVersion: item.rowVersion,
          children: const [],
        ),
    };
    final childrenByParent = <String, List<CustomExerciseItem>>{};
    final roots = <CustomExerciseItem>[];

    for (final item in byId.values) {
      final parentId = item.parentId;
      if (parentId == null || parentId.isEmpty || !byId.containsKey(parentId)) {
        roots.add(item);
        continue;
      }
      childrenByParent.putIfAbsent(parentId, () => <CustomExerciseItem>[]).add(item);
    }

    CustomExerciseItem withChildren(CustomExerciseItem item) {
      final children = List<CustomExerciseItem>.from(
        childrenByParent[item.id] ?? const <CustomExerciseItem>[],
      );
      children.sort(_sortItems);
      return CustomExerciseItem(
        id: item.id,
        name: item.name,
        description: item.description,
        parentId: item.parentId,
        sortOrder: item.sortOrder,
        isMobility: item.isMobility,
        catalogSource: item.catalogSource,
        hevyTemplateId: item.hevyTemplateId,
        hevyStableKey: item.hevyStableKey,
        isHevyFolder: item.isHevyFolder,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
        rowVersion: item.rowVersion,
        children: children.map(withChildren).toList(),
      );
    }

    roots.sort(_sortItems);
    return roots.map(withChildren).toList();
  }

  int _sortItems(CustomExerciseItem a, CustomExerciseItem b) {
    final aSort = a.sortOrder ?? 9999;
    final bSort = b.sortOrder ?? 9999;
    if (aSort != bSort) return aSort.compareTo(bSort);
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final tempId = _offline.newTempId('cex');
    final now = DateTime.now().toIso8601String();
    final local = <String, dynamic>{
      'id': tempId,
      'userId': '',
      'name': body['name']?.toString() ?? '',
      'description': body['description'],
      'parentId': body['parentId'],
      'sortOrder': body['sortOrder'],
      'isMobility': body['isMobility'] ?? false,
      'catalogSource': body['catalogSource'] ?? ExerciseCatalogSource.manual,
      if (body['hevyTemplateId'] != null) 'hevyTemplateId': body['hevyTemplateId'],
      if (body['hevyStableKey'] != null) 'hevyStableKey': body['hevyStableKey'],
      'isHevyFolder': body['isHevyFolder'] ?? false,
      'createdAt': now,
      'updatedAt': now,
      'rowVersion': 1,
      'children': <dynamic>[],
    };
    await _offline.saveLocalEntity(
      type: OfflineEntityType.customExercise,
      id: tempId,
      scopeId: _scope,
      payload: local,
      localOnly: false,
    );
    return local;
  }

  Future<void> update(String id, Map<String, dynamic> body) async {
    final current = await _offline.readLocalEntityById(
      OfflineEntityType.customExercise,
      id,
    );
    final localPatch = Map<String, dynamic>.from(body)
      ..remove('expectedRowVersion');
    final merged = <String, dynamic>{
      ...?current,
      ...localPatch,
      'id': id,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await _offline.saveLocalEntity(
      type: OfflineEntityType.customExercise,
      id: id,
      scopeId: _scope,
      payload: merged,
      localOnly: false,
    );
  }

  Future<void> delete(String id) async {
    await _offline.markDeleted(OfflineEntityType.customExercise, id);
  }

  /// Upserts Hevy catalog nodes (folders + leaves) by stable key / template id.
  Future<int> upsertHevyCatalogNodes(
    List<HevyCatalogImportNode> nodes, {
    void Function(int current, int total)? onProgress,
  }) async {
    final existing = await listFlat(catalogSource: ExerciseCatalogSource.hevy);
    final byStable = <String, CustomExerciseItem>{
      for (final e in existing)
        if (e.hevyStableKey != null) e.hevyStableKey!: e,
    };
    final byTemplate = <String, CustomExerciseItem>{
      for (final e in existing)
        if (e.hevyTemplateId != null) e.hevyTemplateId!: e,
    };

    final stableToLocalId = <String, String>{};
    var count = 0;
    final total = nodes.length;

    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      onProgress?.call(i + 1, total);

      final parentLocalId = node.parentStableKey != null
          ? stableToLocalId[node.parentStableKey!]
          : null;

      final existingItem = node.isFolder
          ? byStable[node.stableKey]
          : byTemplate[node.hevyTemplateId ?? node.stableKey];

      if (existingItem != null) {
        stableToLocalId[node.stableKey] = existingItem.id;
        await update(existingItem.id, {
          'name': node.name,
          'parentId': parentLocalId,
          'sortOrder': node.sortOrder,
          'isMobility': node.isMobility,
          'catalogSource': ExerciseCatalogSource.hevy,
          'hevyTemplateId': node.hevyTemplateId,
          'hevyStableKey': node.stableKey,
          'isHevyFolder': node.isFolder,
        });
      } else {
        final created = await create({
          'name': node.name,
          'parentId': parentLocalId,
          'sortOrder': node.sortOrder,
          'isMobility': node.isMobility,
          'catalogSource': ExerciseCatalogSource.hevy,
          'hevyTemplateId': node.hevyTemplateId,
          'hevyStableKey': node.stableKey,
          'isHevyFolder': node.isFolder,
        });
        final localId = created['id']?.toString() ?? '';
        stableToLocalId[node.stableKey] = localId;
        if (node.hevyTemplateId != null) {
          byTemplate[node.hevyTemplateId!] = CustomExerciseItem.fromJson(created);
        }
        byStable[node.stableKey] = CustomExerciseItem.fromJson(created);
        count++;
      }
    }
    return count;
  }
}
