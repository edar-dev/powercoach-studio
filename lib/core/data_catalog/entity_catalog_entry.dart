import '../sync/offline_models.dart';
import 'coach_entity_row_contract.dart';
import 'data_storage_locus.dart';
import 'soft_reference.dart';

/// One bucket in the in-repo data catalog (cloud entity, prefs, or nested JSON).
class EntityCatalogEntry {
  const EntityCatalogEntry({
    required this.catalogId,
    required this.displayName,
    required this.locus,
    required this.summary,
    required this.payloadFields,
    this.driftType,
    this.cacheLocus,
    this.scopeIdPattern = '',
    this.references = const <SoftReference>[],
    this.includedInBackup = false,
    this.backupKey,
    this.prefsKeyPattern,
    this.sourcePath = '',
    this.remoteTable,
    this.remoteRowFields = const <String>[],
    this.softDelete = false,
    this.softDeleteColumn,
    this.rlsNote,
    this.softFkNote,
  });

  /// Factory for [OfflineEntityType] rows: cloud SoT + Drift cache.
  factory EntityCatalogEntry.coachEntity({
    required String catalogId,
    required String displayName,
    required OfflineEntityType driftType,
    required String summary,
    required String scopeIdPattern,
    required List<String> payloadFields,
    List<SoftReference> references = const <SoftReference>[],
    required String sourcePath,
  }) {
    return EntityCatalogEntry(
      catalogId: catalogId,
      displayName: displayName,
      driftType: driftType,
      locus: DataStorageLocus.supabaseCoachEntities,
      cacheLocus: DataStorageLocus.driftLocalEntities,
      summary: summary,
      scopeIdPattern: scopeIdPattern,
      payloadFields: payloadFields,
      references: references,
      includedInBackup: true,
      backupKey: 'entities',
      sourcePath: sourcePath,
      remoteTable: CoachEntityRowContract.remoteTable,
      remoteRowFields: CoachEntityRowContract.remoteRowFields,
      softDelete: true,
      softDeleteColumn: CoachEntityRowContract.softDeleteColumn,
      rlsNote: CoachEntityRowContract.rlsNote,
      softFkNote: CoachEntityRowContract.softFkNote,
    );
  }

  /// Stable id used across docs, OM ingestion, and quality rules.
  final String catalogId;

  final String displayName;

  /// Matching [OfflineEntityType] when this bucket is a coach entity row.
  final OfflineEntityType? driftType;

  /// Primary persistence locus (cloud SoT for business entities).
  final DataStorageLocus locus;

  /// Local cache locus when [locus] is [DataStorageLocus.supabaseCoachEntities].
  final DataStorageLocus? cacheLocus;

  /// Human-readable description of the bucket.
  final String summary;

  /// How `scope_id` / `scopeId` is chosen for coach entity rows.
  final String scopeIdPattern;

  /// Field names commonly present in the JSON payload / prefs blob.
  final List<String> payloadFields;

  final List<SoftReference> references;

  final bool includedInBackup;

  /// Backup envelope key: `entities`, `localUserProfile`, `preferences`, …
  final String? backupKey;

  /// SharedPreferences key pattern when [locus] is prefs / file-backed.
  final String? prefsKeyPattern;

  /// Primary code path for readers of this shape.
  final String sourcePath;

  /// Qualified remote table when [locus] is Supabase (e.g. `public.coach_entities`).
  final String? remoteTable;

  /// Remote row columns (snake_case) for cloud SoT entities.
  final List<String> remoteRowFields;

  /// Whether soft-delete is used (`deleted` column) instead of hard DELETE.
  final bool softDelete;

  /// Soft-delete column name when [softDelete] is true.
  final String? softDeleteColumn;

  /// RLS summary for cloud tables.
  final String? rlsNote;

  /// Note that FKs are soft ids inside JSON payload (no SQL FKs).
  final String? softFkNote;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'catalogId': catalogId,
        'displayName': displayName,
        'driftType': driftType?.name,
        'locus': locus.name,
        if (cacheLocus != null) 'cacheLocus': cacheLocus!.name,
        'summary': summary,
        'scopeIdPattern': scopeIdPattern,
        'payloadFields': payloadFields,
        'references': references.map((r) => r.toJson()).toList(growable: false),
        'includedInBackup': includedInBackup,
        'backupKey': backupKey,
        'prefsKeyPattern': prefsKeyPattern,
        'sourcePath': sourcePath,
        if (remoteTable != null) 'remoteTable': remoteTable,
        if (remoteRowFields.isNotEmpty) 'remoteRowFields': remoteRowFields,
        'softDelete': softDelete,
        if (softDeleteColumn != null) 'softDeleteColumn': softDeleteColumn,
        if (rlsNote != null) 'rlsNote': rlsNote,
        if (softFkNote != null) 'softFkNote': softFkNote,
      };
}
