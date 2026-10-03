import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../sync/offline_models.dart';
import 'coach_entities_exceptions.dart';

/// Supabase CRUD for [public.coach_entities] (cloud source of truth).
///
/// Uses the anon key + user JWT via [SupabaseClient] only — never a service role.
class CoachEntitiesRemote {
  CoachEntitiesRemote({SupabaseClient? client})
      : _clientOverride = client,
        _allowMissingClient = false;

  /// Test double constructor that does not touch [Supabase.instance].
  @visibleForTesting
  CoachEntitiesRemote.none()
      : _clientOverride = null,
        _allowMissingClient = true;

  static const tableName = 'coach_entities';
  static const upsertChunkSize = 100;

  final SupabaseClient? _clientOverride;
  final bool _allowMissingClient;

  SupabaseClient get _client {
    final override = _clientOverride;
    if (override != null) return override;
    if (_allowMissingClient) {
      throw CoachEntitiesRemoteException(
        'Supabase client unavailable (test double must override remote methods)',
      );
    }
    return Supabase.instance.client;
  }

  String _requireUserId() {
    try {
      final id = _client.auth.currentUser?.id;
      if (id != null && id.isNotEmpty) return id;
    } catch (e) {
      throw CoachEntitiesRemoteException('No authenticated user', e);
    }
    throw CoachEntitiesRemoteException('No authenticated user');
  }

  /// Maps a PostgREST row to [OfflineEntity].
  @visibleForTesting
  static OfflineEntity entityFromRow(Map<String, dynamic> row) {
    final typeName = row['type']?.toString() ?? '';
    final parsed = tryParseOfflineEntityType(typeName);
    if (parsed == null) {
      throw FormatException('Unknown coach_entities type: $typeName');
    }
    final payloadRaw = row['payload'];
    final Map<String, dynamic> payload;
    if (payloadRaw is Map) {
      payload = payloadRaw.cast<String, dynamic>();
    } else {
      payload = <String, dynamic>{};
    }
    return OfflineEntity(
      id: row['id']?.toString() ?? '',
      type: parsed,
      scopeId: row['scope_id']?.toString() ?? '',
      payload: payload,
      updatedAt: DateTime.tryParse(row['updated_at']?.toString() ?? '') ??
          DateTime.now().toUtc(),
      deleted: row['deleted'] as bool? ?? false,
      localOnly: false,
    );
  }

  /// Maps [OfflineEntity] to a `coach_entities` upsert row for [userId].
  @visibleForTesting
  static Map<String, dynamic> rowFromEntity(
    OfflineEntity entity,
    String userId,
  ) {
    return <String, dynamic>{
      'user_id': userId,
      'type': entity.type.name,
      'id': entity.id,
      'scope_id': entity.scopeId,
      'payload': entity.payload,
      'updated_at': entity.updatedAt.toUtc().toIso8601String(),
      'deleted': entity.deleted,
    };
  }

  Future<List<OfflineEntity>> list({
    OfflineEntityType? type,
    String? customerId,
    DateTime? updatedSince,
    bool includeDeleted = true,
  }) async {
    _requireUserId();
    try {
      var query = _client.from(tableName).select();
      if (type != null) {
        query = query.eq('type', type.name);
      }
      if (customerId != null && customerId.isNotEmpty) {
        query = query.eq('payload->>customerId', customerId);
      }
      if (updatedSince != null) {
        query = query.gte(
          'updated_at',
          updatedSince.toUtc().toIso8601String(),
        );
      }
      if (!includeDeleted) {
        query = query.eq('deleted', false);
      }
      final rows = await query.order('updated_at', ascending: false);
      return _mapRows(rows);
    } catch (e) {
      if (e is CoachEntitiesRemoteException || e is FormatException) rethrow;
      throw CoachEntitiesRemoteException('list failed', e);
    }
  }

  Future<void> upsert(OfflineEntity entity) async {
    final userId = _requireUserId();
    try {
      await _client.from(tableName).upsert(
            rowFromEntity(entity, userId),
            onConflict: 'user_id,type,id',
          );
    } catch (e) {
      if (e is CoachEntitiesRemoteException) rethrow;
      throw CoachEntitiesRemoteException('upsert failed', e);
    }
  }

  Future<void> softDelete({
    required OfflineEntityType type,
    required String id,
    required String scopeId,
    Map<String, dynamic>? payload,
  }) {
    return upsert(
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

  Future<List<OfflineEntity>> pullSince({DateTime? since}) {
    return list(updatedSince: since, includeDeleted: true);
  }

  /// True when the current user has no non-deleted rows (or no rows at all).
  Future<bool> isRemoteEmpty() async {
    _requireUserId();
    try {
      final rows = await _client
          .from(tableName)
          .select('id')
          .eq('deleted', false)
          .limit(1);
      return _asList(rows).isEmpty;
    } catch (e) {
      if (e is CoachEntitiesRemoteException) rethrow;
      throw CoachEntitiesRemoteException('isRemoteEmpty failed', e);
    }
  }

  Future<void> upsertAll(List<OfflineEntity> entities) async {
    if (entities.isEmpty) return;
    final userId = _requireUserId();
    try {
      for (var i = 0; i < entities.length; i += upsertChunkSize) {
        final end = (i + upsertChunkSize < entities.length)
            ? i + upsertChunkSize
            : entities.length;
        final chunk = entities.sublist(i, end);
        final rows = chunk.map((e) => rowFromEntity(e, userId)).toList();
        await _client.from(tableName).upsert(
              rows,
              onConflict: 'user_id,type,id',
            );
      }
    } catch (e) {
      if (e is CoachEntitiesRemoteException) rethrow;
      throw CoachEntitiesRemoteException('upsertAll failed', e);
    }
  }

  List<OfflineEntity> _mapRows(dynamic rows) {
    final list = _asList(rows);
    final out = <OfflineEntity>[];
    for (final raw in list) {
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final typeName = map['type']?.toString();
      if (!isKnownOfflineEntityTypeName(typeName)) continue;
      out.add(entityFromRow(map));
    }
    return out;
  }

  List<dynamic> _asList(dynamic rows) {
    if (rows is List) return rows;
    return const [];
  }
}
