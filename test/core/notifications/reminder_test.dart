import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/notifications/reminder.dart';

void main() {
  test('Reminder stableNotificationId is positive and deterministic', () {
    const id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
    final n1 = Reminder.stableNotificationId(id);
    final n2 = Reminder.stableNotificationId(id);
    expect(n1, n2);
    expect(n1, greaterThan(0));
    expect(n1, lessThan(0x80000000));
  });

  test('Reminder round-trip JSON', () {
    final r = Reminder(
      id: 'rid',
      title: 'Session',
      body: 'Body text',
      scheduledAtUtc: DateTime.utc(2031, 6, 15, 9, 30),
      customerId: 'cust-99',
    );
    final m = r.toJson();
    final back = Reminder.tryFromJson(m);
    expect(back, isNotNull);
    expect(back!.id, r.id);
    expect(back.title, r.title);
    expect(back.body, r.body);
    expect(back.scheduledAtUtc.toUtc(), r.scheduledAtUtc.toUtc());
    expect(back.customerId, r.customerId);
  });

  test('Reminder.tryFromJson rejects invalid maps', () {
    expect(Reminder.tryFromJson(<String, dynamic>{}), isNull);
    expect(
      Reminder.tryFromJson(<String, dynamic>{
        'id': '',
        'title': 'x',
        'body': 'y',
        'scheduledAtUtc': DateTime.utc(2030).toIso8601String(),
      }),
      isNull,
    );
  });
}
