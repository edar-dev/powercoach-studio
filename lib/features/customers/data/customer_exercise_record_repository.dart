import '../../../core/sync/offline_models.dart';
import '../../../core/sync/offline_repository_support.dart';
import 'models/customer_exercise_record.dart';

/// Persists customer exercise records in local storage.
class CustomerExerciseRecordRepository {
  CustomerExerciseRecordRepository({OfflineRepositorySupport? offline})
      : _offline = offline ?? OfflineRepositorySupport();

  final OfflineRepositorySupport _offline;

  Future<List<CustomerExerciseRecord>> getByCustomerId(
    String customerId, {
    String? customExerciseId,
  }) async {
    final local = await _offline.readLocalEntities(
      OfflineEntityType.exerciseRecord,
      scopeId: customerId,
    );
    var records = local.map(CustomerExerciseRecord.fromJson).toList();
    if (customExerciseId != null && customExerciseId.isNotEmpty) {
      records = records.where((r) => r.customExerciseId == customExerciseId).toList();
    }
    return records;
  }

  Future<CustomerExerciseRecord?> getById(
    String customerId,
    String recordId,
  ) async {
    final local = await _offline.readLocalEntityById(
      OfflineEntityType.exerciseRecord,
      recordId,
    );
    if (local == null) return null;
    return CustomerExerciseRecord.fromJson(local);
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
      localOnly: false,
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
      localOnly: false,
    );
    return CustomerExerciseRecord.fromJson(payload);
  }

  Future<void> delete(String customerId, String recordId) async {
    await _offline.markDeleted(OfflineEntityType.exerciseRecord, recordId);
  }
}
