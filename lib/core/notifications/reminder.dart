/// Local reminder shown via [flutter_local_notifications] at [scheduledAtUtc].
class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAtUtc,
    this.customerId,
  });

  final String id;
  final String title;
  final String body;

  /// Fire time in UTC (ISO-8601 in JSON).
  final DateTime scheduledAtUtc;

  /// When set, notification tap navigates to `/customers/{customerId}`.
  final String? customerId;

  /// GoRouter path used as notification payload (tap → navigate).
  String get routePayload =>
      customerId != null && customerId!.isNotEmpty ? '/customers/$customerId' : '/dashboard';

  /// Stable positive int for OS notification id (collision risk documented in plan).
  static int stableNotificationId(String reminderId) {
    var h = 0x811c9dc5;
    for (final cu in reminderId.codeUnits) {
      h = (h ^ cu) * 0x01000193;
      h &= 0x7fffffff;
    }
    if (h == 0) return 1;
    return h;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
        'scheduledAtUtc': scheduledAtUtc.toUtc().toIso8601String(),
        if (customerId != null) 'customerId': customerId,
      };

  static Reminder? tryFromJson(Map<String, dynamic> m) {
    try {
      final id = m['id']?.toString() ?? '';
      final title = m['title']?.toString() ?? '';
      final body = m['body']?.toString() ?? '';
      final raw = m['scheduledAtUtc']?.toString();
      if (id.isEmpty || title.isEmpty || raw == null || raw.isEmpty) return null;
      final at = DateTime.tryParse(raw);
      if (at == null) return null;
      final cid = m['customerId']?.toString();
      return Reminder(
        id: id,
        title: title,
        body: body,
        scheduledAtUtc: at.toUtc(),
        customerId: (cid != null && cid.isNotEmpty) ? cid : null,
      );
    } catch (_) {
      return null;
    }
  }
}
