import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/locale/app_locale_controller.dart';
import '../../../../core/notifications/calendar_reminder_scheduler.dart';
import '../../../../core/notifications/notification_scheduler_service.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_snackbar.dart';
import '../data/user_preferences_repository.dart';

/// Loaded notification-related settings for the settings screen.
class SettingsNotificationPreferences {
  const SettingsNotificationPreferences({
    required this.notificationsEnabled,
    required this.calendarRemindersEnabled,
    required this.calendarReminderLeadHours,
  });

  final bool notificationsEnabled;
  final bool calendarRemindersEnabled;
  final int calendarReminderLeadHours;
}

Future<SettingsNotificationPreferences> loadSettingsNotificationPreferences(
  UserPreferencesRepository preferences,
) async {
  var prefs = await preferences.loadAll();
  var enabled = prefs.notificationsEnabled;
  final calendarEnabled = prefs.calendarRemindersEnabled;
  final leadHours = prefs.calendarReminderLeadHours;

  if (!kIsWeb &&
      NotificationSchedulerService.instance.supportsLocalNotifications) {
    await NotificationSchedulerService.instance.ensureInitialized();
    await NotificationSchedulerService.instance.downgradePreferenceIfOsDenied();
    enabled = await preferences.getNotificationsEnabled();
    await NotificationSchedulerService.instance.syncWithNotificationPreference();
  }

  return SettingsNotificationPreferences(
    notificationsEnabled: enabled,
    calendarRemindersEnabled: calendarEnabled,
    calendarReminderLeadHours: leadHours,
  );
}

Future<void> toggleSettingsNotifications({
  required BuildContext context,
  required AppLocalizations l10n,
  required UserPreferencesRepository preferences,
  required bool value,
  required void Function(bool enabled) onChanged,
}) async {
  if (kIsWeb) {
    showAppSnackBar(context, content: Text(l10n.reminderWebNotSupported));
    return;
  }

  if (value) {
    await NotificationSchedulerService.instance.ensureInitialized();
    final granted =
        await NotificationSchedulerService.instance.requestOsPermission();
    if (!context.mounted) return;
    if (!granted) {
      showAppSnackBar(
        context,
        content: Text(l10n.settingsNotificationPermissionDenied),
      );
      return;
    }
    await preferences.setNotificationsEnabled(true);
    if (!context.mounted) return;
    onChanged(true);
    await NotificationSchedulerService.instance.syncWithNotificationPreference();
  } else {
    await preferences.setNotificationsEnabled(false);
    if (!context.mounted) return;
    onChanged(false);
    await NotificationSchedulerService.instance.cancelAllScheduled();
  }
}

Future<void> toggleSettingsCalendarReminders({
  required BuildContext context,
  required AppLocalizations l10n,
  required bool notificationsEnabled,
  required bool value,
  required void Function(bool enabled) onChanged,
}) async {
  if (kIsWeb) {
    showAppSnackBar(context, content: Text(l10n.reminderWebNotSupported));
    return;
  }
  if (value && !notificationsEnabled) {
    showAppSnackBar(
      context,
      content: Text(l10n.settingsNotificationsDescription),
    );
    return;
  }
  await CalendarReminderScheduler.instance.setEnabled(value);
  if (!context.mounted) return;
  onChanged(value);
}

Future<void> showSettingsCalendarLeadHoursPicker({
  required BuildContext context,
  required AppLocalizations l10n,
  required int currentLeadHours,
  required void Function(int hours) onSelected,
}) async {
  const options = [12, 24, 48];
  final selected = await showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map(
              (hours) => ListTile(
                title: Text(l10n.settingsCalendarReminderLeadHours(hours)),
                trailing: currentLeadHours == hours
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(ctx).pop(hours),
              ),
            )
            .toList(),
      ),
    ),
  );
  if (selected == null || !context.mounted) return;
  await CalendarReminderScheduler.instance.setLeadHours(selected);
  if (!context.mounted) return;
  onSelected(selected);
}

Future<void> showSettingsLanguagePicker({
  required BuildContext context,
  required AppLocalizations l10n,
}) async {
  final selected = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final currentCode = AppLocaleController.instance.locale.languageCode;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.settingsLanguageItalian),
                trailing: currentCode == 'it'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(ctx).pop('it'),
              ),
              ListTile(
                title: Text(l10n.settingsLanguageEnglish),
                trailing: currentCode == 'en'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(ctx).pop('en'),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (selected == null || !context.mounted) return;
  await AppLocaleController.instance.setLocale(Locale(selected));
  if (!context.mounted) return;
  showAppSnackBar(context, content: Text(l10n.settingsLanguageSaved));
}
