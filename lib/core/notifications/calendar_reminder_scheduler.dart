import '../../features/customers/data/customer_repository.dart';
import '../../features/dashboard/domain/calendar_event_loader.dart';
import '../../features/dashboard/domain/plan_calendar_event.dart';
import '../../features/settings/data/user_preferences_repository.dart';
import '../../features/workouts/data/workout_plan_repository.dart';
import '../notifications/notification_scheduler_service.dart';
import '../notifications/reminder.dart';

/// Schedules local notifications for upcoming planned calendar sessions.
class CalendarReminderScheduler {
  CalendarReminderScheduler._();

  static final CalendarReminderScheduler instance =
      CalendarReminderScheduler._();

  static const defaultLeadHours = 24;
  static const _defaultSessionHour = 9;
  static const _lookaheadDays = 7;
  static const _idPrefix = 'cal-reminder-';

  Future<bool> isEnabled() async {
    return UserPreferencesRepository.instance.getCalendarRemindersEnabled();
  }

  Future<int> leadHours() async {
    return UserPreferencesRepository.instance.getCalendarReminderLeadHours();
  }

  Future<void> setEnabled(bool enabled) async {
    await UserPreferencesRepository.instance.setCalendarRemindersEnabled(
      enabled,
    );
    if (enabled) {
      await rescheduleUpcoming();
    } else {
      await _cancelCalendarReminders();
    }
  }

  Future<void> setLeadHours(int hours) async {
    await UserPreferencesRepository.instance.setCalendarReminderLeadHours(
      hours.clamp(1, 72),
    );
    if (await isEnabled()) {
      await rescheduleUpcoming();
    }
  }

  Future<void> rescheduleUpcoming() async {
    final scheduler = NotificationSchedulerService.instance;
    if (!scheduler.supportsLocalNotifications) return;
    if (!await isEnabled()) return;

    await scheduler.ensureInitialized();
    await _cancelCalendarReminders();

    final lead = await leadHours();
    final now = DateTime.now();
    final rangeStart = DateTime(now.year, now.month, now.day);
    final rangeEnd = rangeStart.add(const Duration(days: _lookaheadDays));

    final planRepo = WorkoutPlanRepository();
    final customerRepo = CustomerRepository();
    final plans = await planRepo.getAll();
    final customers = await customerRepo.getAll();
    final names = {
      for (final c in customers) c.id: c.name.trim().isEmpty ? c.id : c.name,
    };

    final events = CalendarEventLoader.eventsForPlans(
      plans: plans,
      customerNamesById: names,
      rangeStart: rangeStart,
      rangeEndExclusive: rangeEnd,
      unknownClientLabel: 'Client',
      untitledProgramLabel: 'Workout',
    );

    for (final event in events) {
      if (event.status != PlanSessionStatus.planned) continue;
      final fireAt = fireAtForSession(event.day, lead);
      if (!fireAt.isAfter(now)) continue;

      await scheduler.scheduleReminder(
        Reminder(
          id: reminderId(event),
          title: event.customerName,
          body: '${event.programName} · ${event.sessionLabel}',
          scheduledAtUtc: fireAt.toUtc(),
          customerId: event.customerId,
        ),
      );
    }
  }

  /// Visible for tests.
  static DateTime fireAtForSession(DateTime sessionDay, int leadHours) {
    final sessionAt = DateTime(
      sessionDay.year,
      sessionDay.month,
      sessionDay.day,
      _defaultSessionHour,
    );
    return sessionAt.subtract(Duration(hours: leadHours));
  }

  static String reminderId(PlanCalendarEvent event) =>
      '$_idPrefix${event.planId}-${event.weekIndex}-${event.dayIndex}-${event.day.toIso8601String().split('T').first}';

  Future<void> _cancelCalendarReminders() async {
    final scheduler = NotificationSchedulerService.instance;
    if (!scheduler.supportsLocalNotifications) return;

    final planRepo = WorkoutPlanRepository();
    final plans = await planRepo.getAll();
    final now = DateTime.now();
    final rangeStart = now.subtract(const Duration(days: 30));
    final rangeEnd = now.add(const Duration(days: _lookaheadDays + 1));

    final events = CalendarEventLoader.eventsForPlans(
      plans: plans,
      customerNamesById: const {},
      rangeStart: rangeStart,
      rangeEndExclusive: rangeEnd,
      unknownClientLabel: '',
      untitledProgramLabel: '',
    );

    for (final event in events) {
      await scheduler.cancelReminder(
        Reminder(
          id: reminderId(event),
          title: '',
          body: '',
          scheduledAtUtc: DateTime.now().toUtc(),
        ),
      );
    }
  }
}
