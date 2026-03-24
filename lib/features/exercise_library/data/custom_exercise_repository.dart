import 'dart:convert';

import '../../../core/network/gymblog_api_client.dart';
import '../../../core/sync/offline_models.dart';
import '../../../core/sync/offline_repository_support.dart';
import 'custom_exercise_item.dart';

/// Offline-first custom exercise library (tree API + outbox).
class CustomExerciseRepository {
  CustomExerciseRepository()
      : _api = GymBlogApiClient(),
        _offline = OfflineRepositorySupport();

  final GymBlogApiClient _api;
  final OfflineRepositorySupport _offline;

  static const _scope = 'library';
  static String _cacheId(bool? mobility) => 'cex_tree_${mobility ?? 'all'}';

  /// GET /api/custom-exercises?tree=true[&mobility=]
  Future<List<CustomExerciseItem>> getTree({bool? mobility}) async {
    final qp = <String, String>{'tree': 'true'};
    if (mobility != null) qp['mobility'] = mobility.toString();
    try {
      final list = await _api.getList(
        '/api/custom-exercises',
        queryParameters: qp,
      );
      await _offline.saveLocalEntity(
        type: OfflineEntityType.customExercise,
        id: _cacheId(mobility),
        scopeId: _scope,
        payload: {'json': jsonEncode(list)},
      );
      return list
          .whereType<Map<String, dynamic>>()
          .map(CustomExerciseItem.fromJson)
          .toList();
    } catch (_) {
      final row = await _offline.readLocalEntityById(
        OfflineEntityType.customExercise,
        _cacheId(mobility),
      );
      final raw = row?['json']?.toString();
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CustomExerciseItem.fromJson)
          .toList();
    }
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
      localOnly: true,
    );
    await _offline.enqueue(
      entityType: OfflineEntityType.customExercise,
      entityId: tempId,
      scopeId: _scope,
      opType: OfflineOperationType.create,
      path: '/api/custom-exercises',
      payload: body,
    );
    return local;
  }

  Future<void> update(String id, Map<String, dynamic> body) async {
    final current = await _offline.readLocalEntityById(
      OfflineEntityType.customExercise,
      id,
    );
    final apiBody = Map<String, dynamic>.from(body);
    final expected = apiBody['expectedRowVersion'] ?? current?['rowVersion'];
    if (expected != null) apiBody['expectedRowVersion'] = expected;

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
      localOnly: true,
    );
    await _offline.enqueue(
      entityType: OfflineEntityType.customExercise,
      entityId: id,
      scopeId: _scope,
      opType: OfflineOperationType.update,
      path: '/api/custom-exercises/$id',
      payload: apiBody,
      baseUpdatedAt: DateTime.tryParse(current?['updatedAt']?.toString() ?? ''),
    );
  }

  Future<void> delete(String id) async {
    await _offline.markDeleted(OfflineEntityType.customExercise, id);
    await _offline.enqueue(
      entityType: OfflineEntityType.customExercise,
      entityId: id,
      scopeId: _scope,
      opType: OfflineOperationType.delete,
      path: '/api/custom-exercises/$id',
      payload: <String, dynamic>{},
    );
  }
}
