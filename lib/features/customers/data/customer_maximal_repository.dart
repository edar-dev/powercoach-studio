import '../../../core/remote/coach_entities_remote.dart';
import '../../../core/sync/offline_models.dart';
import '../../../core/sync/offline_repository_support.dart';
import 'models/customer_maximal.dart';

/// Persists custom customer massimali (online-required writes → Drift cache).
class CustomerMaximalRepository {
  CustomerMaximalRepository({OfflineRepositorySupport? offline})
      : _offline = offline ??
            OfflineRepositorySupport(remote: CoachEntitiesRemote());

  final OfflineRepositorySupport _offline;

  Future<List<CustomerMaximal>> getByCustomerId(String customerId) async {
    final local = await _offline.readLocalEntities(
      OfflineEntityType.customerMaximal,
      scopeId: customerId,
    );
    return local.map(CustomerMaximal.fromJson).toList();
  }

  Future<CustomerMaximal?> getById(String customerId, String maximalId) async {
    final local = await _offline.readLocalEntityById(
      OfflineEntityType.customerMaximal,
      maximalId,
    );
    if (local == null) return null;
    return CustomerMaximal.fromJson(local);
  }

  Future<CustomerMaximal> create(String customerId, Map<String, dynamic> body) async {
    final id = _offline.newTempId('customerMaximal');
    final now = DateTime.now().toIso8601String();
    final payload = <String, dynamic>{
      'id': id,
      'customerId': customerId,
      ...body,
      'updatedAt': now,
    };
    await _offline.saveLocalEntity(
      type: OfflineEntityType.customerMaximal,
      id: id,
      scopeId: customerId,
      payload: payload,
      localOnly: false,
    );
    return CustomerMaximal.fromJson(payload);
  }

  Future<CustomerMaximal> update(
    String customerId,
    String maximalId,
    Map<String, dynamic> body,
  ) async {
    final current = await _offline.readLocalEntityById(
      OfflineEntityType.customerMaximal,
      maximalId,
    );
    final payload = <String, dynamic>{
      ...?current,
      ...body,
      'id': maximalId,
      'customerId': customerId,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await _offline.saveLocalEntity(
      type: OfflineEntityType.customerMaximal,
      id: maximalId,
      scopeId: customerId,
      payload: payload,
      localOnly: false,
    );
    return CustomerMaximal.fromJson(payload);
  }

  Future<void> delete(String customerId, String maximalId) async {
    await _offline.markDeleted(OfflineEntityType.customerMaximal, maximalId);
  }
}
