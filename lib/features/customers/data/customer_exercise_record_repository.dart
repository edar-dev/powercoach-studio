import '../../../core/di/service_locator.dart';
import '../../../core/network/gymblog_api_client.dart';
import '../../../core/sync/offline_models.dart';
import '../../../core/sync/offline_repository_support.dart';
import 'models/customer_exercise_record.dart';

/// Fetches and persists customer exercise records via GymBlog.API.
/// GET/POST/PUT/DELETE under /api/customers/{customerId}/exercise-records.
class CustomerExerciseRecordRepository {
  CustomerExerciseRecordRepository({GymBlogApiClient? api, OfflineRepositorySupport? offline})
      : _api = api ?? getIt<GymBlogApiClient>(),
        _offline = offline ?? OfflineRepositorySupport();

  final GymBlogApiClient _api;
  final OfflineRepositorySupport _offline;

  Future<List<CustomerExerciseRecord>> getByCustomerId(
    String customerId, {
    String? customExerciseId,
  }) async {
    try {
      final query = customExerciseId != null && customExerciseId.isNotEmpty
          ? '?customExerciseId=$customExerciseId'
          : '';
      final list = await _api.getList(
        '/api/customers/$customerId/exercise-records$query',
      );
      final models = list
          .whereType<Map<String, dynamic>>()
          .map(CustomerExerciseRecord.fromJson)
          .toList();
      for (final r in models) {
        await _offline.saveLocalEntity(
          type: OfflineEntityType.exerciseRecord,
          id: r.id,
          scopeId: customerId,
          payload: <String, dynamic>{
            'id': r.id,
            'customerId': r.customerId,
            'customExerciseId': r.customExerciseId,
            'exerciseName': r.exerciseName,
            'value': r.value,
            'unit': r.unit,
            'recordedAt': r.recordedAt.toIso8601String(),
            'note': r.note,
            'createdAt': r.createdAt.toIso8601String(),
            'updatedAt': r.updatedAt.toIso8601String(),
            'rowVersion': r.rowVersion,
          },
        );
      }
      return models;
    } catch (_) {
      final local = await _offline.readLocalEntities(
        OfflineEntityType.exerciseRecord,
        scopeId: customerId,
      );
      return local.map(CustomerExerciseRecord.fromJson).toList();
    }
  }

  Future<CustomerExerciseRecord?> getById(
    String customerId,
    String recordId,
  ) async {
    try {
      final data = await _api.get(
        '/api/customers/$customerId/exercise-records/$recordId',
      );
      return CustomerExerciseRecord.fromJson(data);
    } on GymBlogApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<CustomerExerciseRecord> create(
    String customerId,
    Map<String, dynamic> body,
  ) async {
    final id = _offline.newTempId('record');
    final now = DateTime.now().toIso8601String();
    final payload = <String, dynamic>{
      'id': id,
      'customerId': customerId,
      ...body,
      'createdAt': now,
      'updatedAt': now,
      'exerciseName': body['exerciseName'],
      'rowVersion': 1,
    };
    await _offline.saveLocalEntity(
      type: OfflineEntityType.exerciseRecord,
      id: id,
      scopeId: customerId,
      payload: payload,
      localOnly: true,
    );
    await _offline.enqueue(
      entityType: OfflineEntityType.exerciseRecord,
      entityId: id,
      scopeId: customerId,
      opType: OfflineOperationType.create,
      path: '/api/customers/$customerId/exercise-records',
      payload: body,
    );
    return CustomerExerciseRecord.fromJson(payload);
  }

  Future<CustomerExerciseRecord> update(
    String customerId,
    String recordId,
    Map<String, dynamic> body,
  ) async {
    final current = await _offline.readLocalEntityById(
      OfflineEntityType.exerciseRecord,
      recordId,
    );
    final apiPayload = Map<String, dynamic>.from(body);
    final expected = apiPayload['expectedRowVersion'] ?? current?['rowVersion'];
    if (expected != null) apiPayload['expectedRowVersion'] = expected;
    final localPatch = Map<String, dynamic>.from(body)..remove('expectedRowVersion');
    final payload = <String, dynamic>{
      ...?current,
      ...localPatch,
      'id': recordId,
      'customerId': customerId,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await _offline.saveLocalEntity(
      type: OfflineEntityType.exerciseRecord,
      id: recordId,
      scopeId: customerId,
      payload: payload,
      localOnly: true,
    );
    await _offline.enqueue(
      entityType: OfflineEntityType.exerciseRecord,
      entityId: recordId,
      scopeId: customerId,
      opType: OfflineOperationType.update,
      path: '/api/customers/$customerId/exercise-records/$recordId',
      payload: apiPayload,
      baseUpdatedAt: DateTime.tryParse(current?['updatedAt']?.toString() ?? ''),
    );
    return CustomerExerciseRecord.fromJson(payload);
  }

  Future<void> delete(String customerId, String recordId) async {
    await _offline.markDeleted(OfflineEntityType.exerciseRecord, recordId);
    await _offline.enqueue(
      entityType: OfflineEntityType.exerciseRecord,
      entityId: recordId,
      scopeId: customerId,
      opType: OfflineOperationType.delete,
      path: '/api/customers/$customerId/exercise-records/$recordId',
      payload: <String, dynamic>{},
    );
  }
}
