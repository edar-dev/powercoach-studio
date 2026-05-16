import '../../integrations/hevy/domain/exercise_catalog_source.dart';

/// Single item in the user's custom exercise library (flat or tree node).
class CustomExerciseItem {
  const CustomExerciseItem({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    this.sortOrder,
    this.isMobility = false,
    this.catalogSource = ExerciseCatalogSource.manual,
    this.hevyTemplateId,
    this.hevyStableKey,
    this.isHevyFolder = false,
    required this.createdAt,
    required this.updatedAt,
    this.rowVersion = 1,
    this.children = const [],
  });

  final String id;
  final String name;
  final String? description;
  final String? parentId;
  final int? sortOrder;
  final bool isMobility;
  final String catalogSource;
  final String? hevyTemplateId;
  final String? hevyStableKey;
  final bool isHevyFolder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int rowVersion;
  final List<CustomExerciseItem> children;

  bool get isHevyLeaf =>
      catalogSource == ExerciseCatalogSource.hevy &&
      !isHevyFolder &&
      hevyTemplateId != null &&
      hevyTemplateId!.isNotEmpty;

  factory CustomExerciseItem.fromJson(Map<String, dynamic> json) {
    final childrenJson = json['children'] as List<dynamic>?;
    return CustomExerciseItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      parentId: json['parentId']?.toString(),
      sortOrder: json['sortOrder'] as int?,
      isMobility: json['isMobility'] as bool? ?? false,
      catalogSource: json['catalogSource'] as String? ?? ExerciseCatalogSource.manual,
      hevyTemplateId: json['hevyTemplateId'] as String?,
      hevyStableKey: json['hevyStableKey'] as String?,
      isHevyFolder: json['isHevyFolder'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      rowVersion: (json['rowVersion'] as num?)?.toInt() ?? 1,
      children: childrenJson != null
          ? childrenJson
              .map((e) => CustomExerciseItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'parentId': parentId,
        'sortOrder': sortOrder,
        'isMobility': isMobility,
        'catalogSource': catalogSource,
        if (hevyTemplateId != null) 'hevyTemplateId': hevyTemplateId,
        if (hevyStableKey != null) 'hevyStableKey': hevyStableKey,
        if (isHevyFolder) 'isHevyFolder': isHevyFolder,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'rowVersion': rowVersion,
      };

  /// Flatten tree to list (depth-first).
  List<CustomExerciseItem> get flat {
    final out = <CustomExerciseItem>[];
    void visit(CustomExerciseItem node) {
      out.add(node);
      for (final c in node.children) {
        visit(c);
      }
    }
    visit(this);
    return out;
  }
}
