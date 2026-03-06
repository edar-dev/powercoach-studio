/// DTO for GymBlog.API workout plan (GET response).
/// planData is JSON string; decode to WorkoutRoutine via WorkoutRoutine.fromJson(jsonDecode(planData)).
class WorkoutPlanApiModel {
  const WorkoutPlanApiModel({
    required this.id,
    required this.customerId,
    required this.userId,
    required this.name,
    this.theme,
    this.initialWeekNumber = 1,
    required this.planData,
    this.pdfHeader,
    this.useCustomPdfHeader = false,
    this.phase,
    this.tags,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String customerId;
  final String userId;
  final String name;
  final String? theme;
  final int initialWeekNumber;
  final String planData;
  final String? pdfHeader;
  final bool useCustomPdfHeader;
  final String? phase;
  final String? tags;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  static WorkoutPlanApiModel fromJson(Map<String, dynamic> json) {
    return WorkoutPlanApiModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      theme: json['theme'] as String?,
      initialWeekNumber: json['initialWeekNumber'] as int? ?? 1,
      planData: json['planData'] as String? ?? '{}',
      pdfHeader: json['pdfHeader'] as String?,
      useCustomPdfHeader: json['useCustomPdfHeader'] as bool? ?? false,
      phase: json['phase'] as String?,
      tags: json['tags'] as String?,
      notes: json['notes'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }
}
