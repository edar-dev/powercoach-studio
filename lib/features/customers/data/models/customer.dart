/// Customer model aligned with GymBlog.API GET /api/customers response.
class Customer {
  const Customer({
    required this.id,
    required this.userId,
    required this.name,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.heightCm,
    this.weightKg,
    this.notes,
    this.goals,
    this.pdfHeader,
    this.useCustomPdfHeader = false,
    this.isFavorite = false,
    this.isArchived = false,
    this.lastPlanUpdateDate,
    required this.createdAt,
    required this.updatedAt,
    this.rowVersion = 1,
  });

  final String id;
  final String userId;
  final String name;
  final String? email;
  final String? phone;
  final String? dateOfBirth;
  final double? heightCm;
  final double? weightKg;
  final String? notes;
  final String? goals;
  final String? pdfHeader;
  final bool useCustomPdfHeader;
  final bool isFavorite;
  final bool isArchived;
  final String? lastPlanUpdateDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int rowVersion;

  static Customer fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      heightCm: json['heightCm'] != null ? (json['heightCm'] as num).toDouble() : null,
      weightKg: json['weightKg'] != null ? (json['weightKg'] as num).toDouble() : null,
      notes: json['notes'] as String?,
      goals: json['goals'] as String?,
      pdfHeader: json['pdfHeader'] as String?,
      useCustomPdfHeader: json['useCustomPdfHeader'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      lastPlanUpdateDate: json['lastPlanUpdateDate'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      rowVersion: (json['rowVersion'] as num?)?.toInt() ?? 1,
    );
  }

  static DateTime _parseDateTime(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }

  Map<String, dynamic> toCreateBody() {
    return {
      'name': name.trim(),
      'email': (email?.trim() ?? '').isEmpty ? null : email?.trim(),
      'phone': (phone?.trim() ?? '').isEmpty ? null : phone?.trim(),
      'dateOfBirth': (dateOfBirth ?? '').isEmpty ? null : dateOfBirth,
      'heightCm': heightCm?.round(),
      'weightKg': weightKg,
      'notes': (notes?.trim() ?? '').isEmpty ? null : notes?.trim(),
      'goals': (goals?.trim() ?? '').isEmpty ? null : goals?.trim(),
      'pdfHeader': (pdfHeader?.trim() ?? '').isEmpty ? null : pdfHeader,
      'useCustomPdfHeader': useCustomPdfHeader,
    };
  }

  Map<String, dynamic> toUpdateBody() => {
        ...toCreateBody(),
        'expectedRowVersion': rowVersion,
      };
}
