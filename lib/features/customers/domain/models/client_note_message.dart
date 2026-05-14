/// Coach-authored note in a per-customer thread (offline-first).
class ClientNoteMessage {
  const ClientNoteMessage({
    required this.id,
    required this.customerId,
    required this.authorUserId,
    required this.body,
    required this.createdAt,
    this.readAt,
    this.attachmentRef,
  });

  static const int maxBodyLength = 4000;

  final String id;
  final String customerId;
  final String authorUserId;
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? attachmentRef;

  bool get isUnread => readAt == null;

  static ClientNoteMessage fromJson(Map<String, dynamic> json) {
    return ClientNoteMessage(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      authorUserId: json['authorUserId']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      readAt: _parseOptionalDateTime(json['readAt']),
      attachmentRef: json['attachmentRef']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'authorUserId': authorUserId,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        if (readAt != null) 'readAt': readAt!.toIso8601String(),
        if (attachmentRef != null && attachmentRef!.isNotEmpty)
          'attachmentRef': attachmentRef,
      };

  ClientNoteMessage copyWith({
    DateTime? readAt,
    bool clearReadAt = false,
  }) {
    return ClientNoteMessage(
      id: id,
      customerId: customerId,
      authorUserId: authorUserId,
      body: body,
      createdAt: createdAt,
      readAt: clearReadAt ? null : (readAt ?? this.readAt),
      attachmentRef: attachmentRef,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }

  static DateTime? _parseOptionalDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    return _parseDateTime(value);
  }

  static String validateBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('note_body_empty');
    }
    if (trimmed.length > maxBodyLength) {
      throw ArgumentError('note_body_too_long');
    }
    return trimmed;
  }
}
