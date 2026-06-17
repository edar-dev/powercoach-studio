import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/notifications/calendar_reminder_scheduler.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';

void main() {
  group('CalendarReminderScheduler.fireAtForSession', () {
    test('subtracts lead hours from default session hour', () {
      final sessionDay = DateTime(2026, 6, 16);
      final fireAt = CalendarReminderScheduler.fireAtForSession(sessionDay, 24);
      expect(fireAt, DateTime(2026, 6, 15, 9));
    });

    test('uses 9:00 local as session anchor', () {
      final sessionDay = DateTime(2026, 1, 10);
      final fireAt = CalendarReminderScheduler.fireAtForSession(sessionDay, 3);
      expect(fireAt, DateTime(2026, 1, 10, 6));
    });

    test('reminderId is stable for same slot and day', () {
      final event = PlanCalendarEvent(
        day: DateTime(2026, 6, 16),
        customerId: 'c1',
        planId: 'p1',
        customerName: 'Marco',
        programName: 'Plan',
        weekIndex: 1,
        dayIndex: 2,
        sessionLabel: 'Day A',
        status: PlanSessionStatus.planned,
      );
      expect(
        CalendarReminderScheduler.reminderId(event),
        'cal-reminder-p1-1-2-2026-06-16',
      );
    });
  });
}
