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

/// Reads the created routine id from `POST /v1/routines` JSON (shape varies).
String? parseHevyCreatedRoutineId(Map<String, dynamic> response) {
  final routine = response['routine'];
  if (routine is Map) {
    final map = routine is Map<String, dynamic>
        ? routine
        : Map<String, dynamic>.from(routine);
    final id = map['id'];
    if (id != null) return id.toString();
  }
  if (routine is List && routine.isNotEmpty) {
    final first = routine.first;
    if (first is Map) {
      final map = first is Map<String, dynamic>
          ? first
          : Map<String, dynamic>.from(first);
      final id = map['id'];
      if (id != null) return id.toString();
    }
  }
  if (response['id'] != null &&
      (response.containsKey('title') || response.containsKey('exercises'))) {
    return response['id']?.toString();
  }
  return null;
}
