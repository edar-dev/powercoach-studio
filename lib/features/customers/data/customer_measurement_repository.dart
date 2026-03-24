import '../../../core/network/gymblog_api_client.dart';
import '../../../core/sync/offline_models.dart';
import '../../../core/sync/offline_repository_support.dart';
import 'models/customer_measurement.dart';

/// Fetches and persists customer measurements via GymBlog.API.
/// GET/POST/PUT/DELETE under /api/customers/{customerId}/measurements.
class CustomerMeasurementRepository {
  CustomerMeasurementRepository()
      : _api = GymBlogApiClient(),
        _offline = OfflineRepositorySupport();

  final GymBlogApiClient _api;
  final OfflineRepositorySupport _offline;

  Future<List<CustomerMeasurement>> getByCustomerId(String customerId) async {
    try {
      final list = await _api.getList('/api/customers/$customerId/measurements');
      final models = list
          .whereType<Map<String, dynamic>>()
          .map(CustomerMeasurement.fromJson)
          .toList();
      for (final m in models) {
        await _offline.saveLocalEntity(
          type: OfflineEntityType.measurement,
          id: m.id,
          scopeId: customerId,
          payload: <String, dynamic>{
            'id': m.id,
            'customerId': m.customerId,
            'userId': m.userId,
            'measurementDate': m.measurementDate.toIso8601String(),
            'squat1RM': m.squat1RM,
            'benchPress1RM': m.benchPress1RM,
            'deadlift1RM': m.deadlift1RM,
            'tricepsSkinfold': m.tricepsSkinfold,
            'bicepsSkinfold': m.bicepsSkinfold,
            'subscapularSkinfold': m.subscapularSkinfold,
            'iliacSkinfold': m.iliacSkinfold,
            'abdominalSkinfold': m.abdominalSkinfold,
            'thighSkinfold': m.thighSkinfold,
            'bodyFatPercent': m.bodyFatPercent,
            'muscleMassKg': m.muscleMassKg,
            'waterPercent': m.waterPercent,
            'fatMassKg': m.fatMassKg,
            'chestCm': m.chestCm,
            'waistCm': m.waistCm,
            'armsCm': m.armsCm,
            'thighsCm': m.thighsCm,
            'notes': m.notes,
            'createdAt': m.createdAt.toIso8601String(),
            'updatedAt': m.updatedAt.toIso8601String(),
          },
        );
      }
      return models;
    } catch (_) {
      final local = await _offline.readLocalEntities(
        OfflineEntityType.measurement,
        scopeId: customerId,
      );
      return local.map(CustomerMeasurement.fromJson).toList();
    }
  }

  Future<CustomerMeasurement?> getById(String customerId, String measurementId) async {
    try {
      final data = await _api.get('/api/customers/$customerId/measurements/$measurementId');
      return CustomerMeasurement.fromJson(data);
    } on GymBlogApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<CustomerMeasurement> create(String customerId, Map<String, dynamic> body) async {
    final id = _offline.newTempId('measurement');
    final now = DateTime.now().toIso8601String();
    final payload = <String, dynamic>{
      'id': id,
      'customerId': customerId,
      'userId': '',
      ...body,
      'createdAt': now,
      'updatedAt': now,
    };
    await _offline.saveLocalEntity(
      type: OfflineEntityType.measurement,
      id: id,
      scopeId: customerId,
      payload: payload,
      localOnly: true,
    );
    await _offline.enqueue(
      entityType: OfflineEntityType.measurement,
      entityId: id,
      scopeId: customerId,
      opType: OfflineOperationType.create,
      path: '/api/customers/$customerId/measurements',
      payload: body,
    );
    return CustomerMeasurement.fromJson(payload);
  }

  Future<CustomerMeasurement> update(
    String customerId,
    String measurementId,
    Map<String, dynamic> body,
  ) async {
    final current = await _offline.readLocalEntityById(
      OfflineEntityType.measurement,
      measurementId,
    );
    final payload = <String, dynamic>{
      ...?current,
      ...body,
      'id': measurementId,
      'customerId': customerId,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await _offline.saveLocalEntity(
      type: OfflineEntityType.measurement,
      id: measurementId,
      scopeId: customerId,
      payload: payload,
      localOnly: true,
    );
    await _offline.enqueue(
      entityType: OfflineEntityType.measurement,
      entityId: measurementId,
      scopeId: customerId,
      opType: OfflineOperationType.update,
      path: '/api/customers/$customerId/measurements/$measurementId',
      payload: body,
      baseUpdatedAt: DateTime.tryParse(current?['updatedAt']?.toString() ?? ''),
    );
    return CustomerMeasurement.fromJson(payload);
  }

  Future<void> delete(String customerId, String measurementId) async {
    await _offline.markDeleted(OfflineEntityType.measurement, measurementId);
    await _offline.enqueue(
      entityType: OfflineEntityType.measurement,
      entityId: measurementId,
      scopeId: customerId,
      opType: OfflineOperationType.delete,
      path: '/api/customers/$customerId/measurements/$measurementId',
      payload: <String, dynamic>{},
    );
  }
}
