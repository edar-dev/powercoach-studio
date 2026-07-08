import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/stitch_secondary_app_bar.dart';
import '../../../../core/notifications/calendar_reminder_scheduler.dart';
import '../../data/user_preferences_repository.dart';
import '../settings_backup_handler.dart';
import '../settings_notification_actions.dart';
import '../settings_sign_out.dart';
import '../widgets/settings_screen_content.dart';

/// Simplified App Settings – Stitch screen ID 8ab8a84172594c1c9911b5762e2a7257.
/// Personal info, Subscription, Notifications, Language, Sign out.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserPreferencesRepository _preferences =
      UserPreferencesRepository.instance;

  bool _notificationsEnabled = true;
  bool _calendarRemindersEnabled = false;
  int _calendarReminderLeadHours = CalendarReminderScheduler.defaultLeadHours;
  bool _loadingPrefs = true;

  SettingsBackupHandler get _backupHandler => SettingsBackupHandler(
        context: context,
        onPreferencesReloaded: _loadPreferences,
      );

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final snapshot = await loadSettingsNotificationPreferences(_preferences);
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = snapshot.notificationsEnabled;
      _calendarRemindersEnabled = snapshot.calendarRemindersEnabled;
      _calendarReminderLeadHours = snapshot.calendarReminderLeadHours;
      _loadingPrefs = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: StitchSecondaryAppBar(title: l10n.settingsTitle),
      body: _loadingPrefs
          ? const Center(child: CircularProgressIndicator())
          : SettingsScreenContent(
              l10n: l10n,
              theme: theme,
              colorScheme: colorScheme,
              notificationsEnabled: _notificationsEnabled,
              calendarRemindersEnabled: _calendarRemindersEnabled,
              calendarReminderLeadHours: _calendarReminderLeadHours,
              onNotificationsToggle: (value) => toggleSettingsNotifications(
                context: context,
                l10n: l10n,
                preferences: _preferences,
                value: value,
                onChanged: (enabled) =>
                    setState(() => _notificationsEnabled = enabled),
              ),
              onCalendarRemindersToggle: (value) =>
                  toggleSettingsCalendarReminders(
                    context: context,
                    l10n: l10n,
                    notificationsEnabled: _notificationsEnabled,
                    value: value,
                    onChanged: (enabled) =>
                        setState(() => _calendarRemindersEnabled = enabled),
                  ),
              onPickCalendarLeadHours: () => showSettingsCalendarLeadHoursPicker(
                context: context,
                l10n: l10n,
                currentLeadHours: _calendarReminderLeadHours,
                onSelected: (hours) =>
                    setState(() => _calendarReminderLeadHours = hours),
              ),
              onExportBackup: () => _backupHandler.exportBackup(l10n),
              onImportBackup: () => _backupHandler.importBackup(l10n),
              onLanguagePicker: () => showSettingsLanguagePicker(
                context: context,
                l10n: l10n,
              ),
              onSignOut: () => performSettingsSignOut(context),
            ),
    );
  }
}
