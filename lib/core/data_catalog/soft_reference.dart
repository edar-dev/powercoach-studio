/// Soft (application-level) foreign key declared in catalog metadata.
///
/// These are **not** SQL FKs. Data-quality scanners use [fieldPath] /
/// [targetCatalogId] to decide which orphan checks apply.
class SoftReference {
  const SoftReference({
    required this.fieldPath,
    required this.targetCatalogId,
    this.optional = true,
    this.description = '',
  });

  /// Dot / bracket path relative to the entity payload or nested JSON.
  ///
  /// Examples: `customerId`, `parentId`,
  /// `planData.exercises[].customExerciseId`.
  final String fieldPath;

  /// [EntityCatalogEntry.catalogId] of the referenced bucket.
  final String targetCatalogId;

  /// When true, a missing/null value is allowed; only non-empty orphans fail.
  final bool optional;

  final String description;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'fieldPath': fieldPath,
        'targetCatalogId': targetCatalogId,
        'optional': optional,
        if (description.isNotEmpty) 'description': description,
      };
}
