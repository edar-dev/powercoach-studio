import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/exercise_catalog_source.dart';
import '../../../core/sync/offline_models.dart';
import '../../../core/sync/offline_repository_support.dart';
import 'custom_exercise_item.dart';

/// Local-only custom exercise library.
class CustomExerciseRepository {
  CustomExerciseRepository({OfflineRepositorySupport? offline})
      : _offline = offline ?? OfflineRepositorySupport();

  final OfflineRepositorySupport _offline;

  static const _scope = 'library';

  /// Legacy Hevy catalog source value (removed integration).
  static const _legacyHevyCatalogSource = 'hevy';

  /// Prefs keys formerly used by the Hevy integration (cleared on purge).
  static const _legacyHevyApiKeyPref = 'hevy_api_key_v1';
  static const _legacyHevyMappingsPref = 'hevy_exercise_mappings_json_v1';

  static bool _legacyHevyPurgeDone = false;

  /// Reset one-shot purge gate between tests.
  @visibleForTesting
  static void resetLegacyHevyPurgeForTest() {
    _legacyHevyPurgeDone = false;
  }

  /// One-shot cleanup of leftover Hevy catalog rows and prefs.
  Future<void> ensureLegacyHevyPurged() async {
    if (_legacyHevyPurgeDone) return;

    final entities = await _offline.readLocalEntities(
      OfflineEntityType.customExercise,
      scopeId: _scope,
    );
    for (final entity in entities) {
      final id = entity['id']?.toString();
      if (id == null || id.isEmpty) continue;
      if (entity['catalogSource']?.toString() == _legacyHevyCatalogSource) {
        await _offline.markDeleted(OfflineEntityType.customExercise, id);
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_legacyHevyApiKeyPref);
    await prefs.remove(_legacyHevyMappingsPref);
    _legacyHevyPurgeDone = true;
  }

  Future<List<CustomExerciseItem>> getTree({
    bool? mobility,
    String? catalogSource,
  }) async {
    final items =
        await listFlat(mobility: mobility, catalogSource: catalogSource);
    return _buildTree(items);
  }

  Future<List<CustomExerciseItem>> listFlat({
    bool? mobility,
    String? catalogSource,
  }) async {
    await ensureLegacyHevyPurged();
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

  /// Soft-deletes all library custom exercises (strength + mobility).
  /// Returns the number of entities marked deleted.
  Future<int> deleteAll() async {
    final items = await listFlat();
    for (final item in items) {
      await delete(item.id);
    }
    return items.length;
  }
}
