import '../sync/offline_models.dart';
import 'data_storage_locus.dart';
import 'soft_reference.dart';

/// One bucket in the in-repo data catalog (Drift type or prefs / nested JSON).
class EntityCatalogEntry {
  const EntityCatalogEntry({
    required this.catalogId,
    required this.displayName,
    required this.locus,
    required this.summary,
    required this.payloadFields,
    this.driftType,
    this.scopeIdPattern = '',
    this.references = const <SoftReference>[],
    this.includedInBackup = false,
    this.backupKey,
    this.prefsKeyPattern,
    this.sourcePath = '',
  });

  /// Stable id used across docs, OM ingestion, and quality rules.
  final String catalogId;

  final String displayName;

  /// Matching [OfflineEntityType] when this bucket is a Drift entity row.
  final OfflineEntityType? driftType;

  final DataStorageLocus locus;

  /// Human-readable description of the bucket.
  final String summary;

  /// How `scopeId` is chosen for Drift rows (empty for non-Drift).
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        'catalogId': catalogId,
        'displayName': displayName,
        'driftType': driftType?.name,
        'locus': locus.name,
        'summary': summary,
        'scopeIdPattern': scopeIdPattern,
        'payloadFields': payloadFields,
        'references': references.map((r) => r.toJson()).toList(growable: false),
        'includedInBackup': includedInBackup,
        'backupKey': backupKey,
        'prefsKeyPattern': prefsKeyPattern,
        'sourcePath': sourcePath,
      };
}
