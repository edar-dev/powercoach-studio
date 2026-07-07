import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/notifications/notification_scheduler_service.dart';
import '../../../../core/notifications/reminder.dart';
import '../../../../core/notifications/reminder_store.dart';
import '../../../settings/data/user_preferences_repository.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_snackbar.dart';

/// Date + time picker → save [Reminder] and schedule OS notification.
Future<void> _composeReminderWithTitle(
  BuildContext context, {
  required String title,
  required String body,
  String? customerId,
}) async {
  final l10n = AppLocalizations.of(context);
  if (kIsWeb) {
    showAppSnackBar(context, content: Text(l10n.reminderWebNotSupported));
    return;
  }
  if (!NotificationSchedulerService.instance.supportsLocalNotifications) {
    showAppSnackBar(context, content: Text(l10n.reminderPlatformNotSupported));
    return;
  }

  final notificationsOn =
      await UserPreferencesRepository.instance.getNotificationsEnabled();
  if (!context.mounted) return;
  if (!notificationsOn) {
    showAppSnackBar(
      context,
      content: Text(l10n.reminderEnableNotificationsFirst),
    );
    return;
  }

  final now = DateTime.now();
  final firstDate = DateTime(now.year, now.month, now.day);
  if (!context.mounted) return;
  final date = await showDatePicker(
    context: context,
    initialDate: firstDate,
    firstDate: firstDate,
    lastDate: firstDate.add(const Duration(days: 365)),
  );
  if (!context.mounted || date == null) return;

  if (!context.mounted) return;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
  );
  if (!context.mounted || time == null) return;

  final atLocal = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
  final atUtc = atLocal.toUtc();
  if (!atUtc.isAfter(DateTime.now().toUtc())) {
    if (!context.mounted) return;
    showAppSnackBar(context, content: Text(l10n.reminderPastTimeError));
    return;
  }

  final reminder = Reminder(
    id: const Uuid().v4(),
    title: title,
    body: body,
    scheduledAtUtc: atUtc,
    customerId: customerId,
  );

  try {
    await ReminderStore.instance.add(reminder);
    await NotificationSchedulerService.instance.scheduleReminder(reminder);
    if (!context.mounted) return;
    showAppSnackBar(context, content: Text(l10n.reminderSaved));
  } catch (e, stackTrace) {
    await Sentry.captureException(e, stackTrace: stackTrace);
    if (!context.mounted) return;
    showAppSnackBar(context, content: Text(l10n.reminderScheduleError));
  }
}

/// Reminder tied to a customer (tap opens `/customers/{id}`).
Future<void> showCustomerReminderComposer(
  BuildContext context, {
  required String customerId,
  required String customerName,
}) {
  final l10n = AppLocalizations.of(context);
  return _composeReminderWithTitle(
    context,
    title: l10n.reminderNotificationTitle(customerName),
    body: l10n.reminderNotificationBody,
    customerId: customerId,
  );
}

/// Reminder from dashboard without a selected client (tap opens `/dashboard`).
Future<void> showDashboardReminderComposer(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return _composeReminderWithTitle(
    context,
    title: l10n.reminderDashboardSessionTitle,
    body: l10n.reminderNotificationBody,
    customerId: null,
  );
}
