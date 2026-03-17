/// Single item in the user's custom exercise library (flat or tree node).
class CustomExerciseItem {
  const CustomExerciseItem({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    this.sortOrder,
    this.isMobility = false,
    required this.createdAt,
    required this.updatedAt,
    this.children = const [],
  });

  final String id;
  final String name;
  final String? description;
  final String? parentId;
  final int? sortOrder;
  final bool isMobility;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CustomExerciseItem> children;

  factory CustomExerciseItem.fromJson(Map<String, dynamic> json) {
    final childrenJson = json['children'] as List<dynamic>?;
    return CustomExerciseItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      parentId: json['parentId']?.toString(),
      sortOrder: json['sortOrder'] as int?,
      isMobility: json['isMobility'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      children: childrenJson != null
          ? childrenJson
              .map((e) => CustomExerciseItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

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
