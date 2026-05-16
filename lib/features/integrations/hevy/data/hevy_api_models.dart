/// Flat exercise template from Hevy API.
class HevyExerciseTemplateDto {
  const HevyExerciseTemplateDto({
    required this.id,
    required this.title,
    this.primaryMuscleGroup,
    this.type,
    this.isCustom = false,
  });

  final String id;
  final String title;
  final String? primaryMuscleGroup;
  final String? type;
  final bool isCustom;

  factory HevyExerciseTemplateDto.fromJson(Map<String, dynamic> json) {
    return HevyExerciseTemplateDto(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      primaryMuscleGroup: json['primary_muscle_group'] as String?,
      type: json['type'] as String?,
      isCustom: json['is_custom'] as bool? ?? false,
    );
  }
}

/// Node produced by [HevyCatalogHierarchyBuilder] for library import.
class HevyCatalogImportNode {
  const HevyCatalogImportNode({
    required this.stableKey,
    required this.name,
    this.parentStableKey,
    this.hevyTemplateId,
    this.sortOrder = 0,
    this.isMobility = false,
    this.isFolder = false,
  });

  /// Stable id for folders (`hevy_grp_*`, `hevy_fam_*`) or template id for leaves.
  final String stableKey;
  final String name;
  final String? parentStableKey;
  final String? hevyTemplateId;
  final int sortOrder;
  final bool isMobility;
  final bool isFolder;
}

class HevyApiException implements Exception {
  HevyApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'HevyApiException($statusCode): $message';
}
