import '../sync/offline_models.dart';
import 'data_quality_severity.dart';

/// One issue discovered by [DataQualityScanner]. Never mutates data.
class DataQualityFinding {
  const DataQualityFinding({
    required this.ruleId,
    required this.severity,
    required this.message,
    this.entityType,
    this.entityId,
    this.details,
  });

  final String ruleId;
  final DataQualitySeverity severity;

  /// Drift type when known; null for raw backup rows with unknown type.
  final OfflineEntityType? entityType;

  final String? entityId;
  final String message;

  /// Optional structured context (field path, target id, …).
  final Map<String, dynamic>? details;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'ruleId': ruleId,
        'severity': severity.name,
        if (entityType != null) 'entityType': entityType!.name,
        if (entityId != null) 'entityId': entityId,
        'message': message,
        if (details != null && details!.isNotEmpty) 'details': details,
      };
}
