import '../../../core/sync/offline_models.dart';
import '../../../core/sync/offline_repository_support.dart';
import 'models/customer_measurement.dart';

/// Persists customer measurements in local storage.
class CustomerMeasurementRepository {
  CustomerMeasurementRepository({OfflineRepositorySupport? offline})
      : _offline = offline ?? OfflineRepositorySupport();

  final OfflineRepositorySupport _offline;

  Future<List<CustomerMeasurement>> getByCustomerId(String customerId) async {
    final local = await _offline.readLocalEntities(
      OfflineEntityType.measurement,
      scopeId: customerId,
    );
    return local.map(CustomerMeasurement.fromJson).toList();
  }

  Future<CustomerMeasurement?> getById(String customerId, String measurementId) async {
    final local = await _offline.readLocalEntityById(
      OfflineEntityType.measurement,
      measurementId,
    );
    if (local == null) return null;
    return CustomerMeasurement.fromJson(local);
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
      'rowVersion': 1,
    };
    await _offline.saveLocalEntity(
      type: OfflineEntityType.measurement,
      id: id,
      scopeId: customerId,
      payload: payload,
      localOnly: false,
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
    final localPatch = Map<String, dynamic>.from(body)..remove('expectedRowVersion');
    final payload = <String, dynamic>{
      ...?current,
      ...localPatch,
      'id': measurementId,
      'customerId': customerId,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await _offline.saveLocalEntity(
      type: OfflineEntityType.measurement,
      id: measurementId,
      scopeId: customerId,
      payload: payload,
      localOnly: false,
    );
    return CustomerMeasurement.fromJson(payload);
  }

  Future<void> delete(String customerId, String measurementId) async {
    await _offline.markDeleted(OfflineEntityType.measurement, measurementId);
  }
}
