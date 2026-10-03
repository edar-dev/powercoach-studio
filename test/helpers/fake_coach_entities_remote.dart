import 'package:powercoach_studio/core/remote/coach_entities_exceptions.dart';
import 'package:powercoach_studio/core/remote/coach_entities_remote.dart';
import 'package:powercoach_studio/core/sync/offline_models.dart';

/// In-memory [CoachEntitiesRemote] for remote-first unit tests.
class FakeCoachEntitiesRemote extends CoachEntitiesRemote {
  FakeCoachEntitiesRemote() : super.none();

  final Map<String, OfflineEntity> _byKey = <String, OfflineEntity>{};
  int upsertCalls = 0;
  int upsertAllCalls = 0;
  int softDeleteCalls = 0;
  int pullCalls = 0;
  bool failNextWrite = false;
  bool failNextUpsertAll = false;
  Object writeError = CoachEntitiesRemoteException('fake write failure');

  String _key(OfflineEntityType type, String id) => '${type.name}::$id';

  List<OfflineEntity> get stored => _byKey.values.toList(growable: false);

  void seed(OfflineEntity entity) {
    _byKey[_key(entity.type, entity.id)] = entity;
  }

  @override
  Future<List<OfflineEntity>> list({
    OfflineEntityType? type,
    String? customerId,
    DateTime? updatedSince,
    bool includeDeleted = true,
  }) async {
    Iterable<OfflineEntity> rows = _byKey.values;
    if (type != null) {
      rows = rows.where((e) => e.type == type);
    }
    if (customerId != null && customerId.isNotEmpty) {
      rows = rows.where(
        (e) => e.payload['customerId']?.toString() == customerId,
      );
    }
    if (updatedSince != null) {
      rows = rows.where((e) => !e.updatedAt.isBefore(updatedSince));
    }
    if (!includeDeleted) {
      rows = rows.where((e) => !e.deleted);
    }
    return rows.toList();
  }

  @override
  Future<void> upsert(OfflineEntity entity) async {
    upsertCalls++;
    if (failNextWrite) {
      failNextWrite = false;
      final err = writeError;
      if (err is Exception) throw err;
      throw CoachEntitiesRemoteException('$err');
    }
    _byKey[_key(entity.type, entity.id)] = entity;
  }

  @override
  Future<void> softDelete({
    required OfflineEntityType type,
    required String id,
    required String scopeId,
    Map<String, dynamic>? payload,
  }) async {
    softDeleteCalls++;
    await upsert(
      OfflineEntity(
        id: id,
        type: type,
        scopeId: scopeId,
        payload: payload ?? <String, dynamic>{},
        updatedAt: DateTime.now().toUtc(),
        deleted: true,
      ),
    );
  }

  @override
  Future<List<OfflineEntity>> pullSince({DateTime? since}) async {
    pullCalls++;
    return list(updatedSince: since, includeDeleted: true);
  }

  @override
  Future<bool> isRemoteEmpty() async {
    return !_byKey.values.any((e) => !e.deleted);
  }

  @override
  Future<void> upsertAll(List<OfflineEntity> entities) async {
    upsertAllCalls++;
    if (failNextUpsertAll) {
      failNextUpsertAll = false;
      final err = writeError;
      if (err is Exception) throw err;
      throw CoachEntitiesRemoteException('$err');
    }
    for (final entity in entities) {
      await upsert(entity);
    }
  }
}
