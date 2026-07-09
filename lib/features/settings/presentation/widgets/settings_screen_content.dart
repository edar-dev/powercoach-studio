import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/constants/app_info.dart';

import '../../../../l10n/app_localizations.dart';
import '../backup_onboarding_dialog.dart';
import '../../../integrations/hevy/presentation/hevy_settings_section.dart';

/// Main settings list body (personal info, notifications, backup, language).
class SettingsScreenContent extends StatelessWidget {
  const SettingsScreenContent({
    super.key,
    required this.l10n,
    required this.theme,
    required this.colorScheme,
    required this.notificationsEnabled,
    required this.calendarRemindersEnabled,
    required this.calendarReminderLeadHours,
    required this.onNotificationsToggle,
    required this.onCalendarRemindersToggle,
    required this.onPickCalendarLeadHours,
    required this.onExportBackup,
    required this.onImportBackup,
    required this.onLanguagePicker,
    required this.onSignOut,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final bool notificationsEnabled;
  final bool calendarRemindersEnabled;
  final int calendarReminderLeadHours;
  final ValueChanged<bool> onNotificationsToggle;
  final ValueChanged<bool> onCalendarRemindersToggle;
  final VoidCallback onPickCalendarLeadHours;
  final VoidCallback onExportBackup;
  final VoidCallback onImportBackup;
  final VoidCallback onLanguagePicker;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      children: [
        ListTile(
          title: Text(l10n.settingsPersonalInfo),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/settings/personal-info'),
        ),
        ListTile(
          title: Text(l10n.settingsSubscription),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/settings/subscription'),
        ),
        ListTile(
          leading: const Icon(Icons.new_releases_outlined),
          title: Text(l10n.releaseNotesTitle),
          subtitle: Text(
            l10n.releaseNotesSettingsSubtitle(kAppVersionLabel),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/settings/release-notes'),
        ),
        SwitchListTile(
          title: Text(l10n.settingsNotifications),
          subtitle: Text(
            l10n.settingsNotificationsDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          value: notificationsEnabled,
          onChanged: kIsWeb ? null : onNotificationsToggle,
        ),
        SwitchListTile(
          title: Text(l10n.settingsCalendarRemindersTitle),
          subtitle: Text(
            l10n.settingsCalendarRemindersSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          value: calendarRemindersEnabled,
          onChanged: kIsWeb || !notificationsEnabled
              ? null
              : onCalendarRemindersToggle,
        ),
        if (calendarRemindersEnabled)
          ListTile(
            title: Text(l10n.settingsCalendarReminderLead),
            subtitle: Text(
              l10n.settingsCalendarReminderLeadHours(calendarReminderLeadHours),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: kIsWeb ? null : onPickCalendarLeadHours,
          ),
        const Divider(height: 32),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            l10n.settingsBackupSectionTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          kIsWeb
              ? l10n.settingsBackupSectionSubtitleWeb
              : l10n.settingsBackupSectionSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.backup_outlined),
          title: Text(l10n.settingsBackupExport),
          trailing: const Icon(Icons.chevron_right),
          onTap: onExportBackup,
        ),
        ListTile(
          leading: const Icon(Icons.restore_outlined),
          title: Text(l10n.settingsBackupImport),
          trailing: const Icon(Icons.chevron_right),
          onTap: onImportBackup,
        ),
        const Divider(height: 32),
        const HevySettingsSection(),
        const SizedBox(height: 24),
        const Divider(height: 32),
        ListTile(
          title: Text(l10n.settingsLanguage),
          subtitle: Text(
            l10n.settingsLanguageDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onLanguagePicker,
        ),
        const Divider(height: 32),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            l10n.settingsLegalSectionTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: Text(l10n.settingsLegalPrivacy),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: openPrivacyPolicy,
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: Text(l10n.settingsLegalTerms),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: openTermsOfService,
        ),
        ListTile(
          leading: const Icon(Icons.person_off_outlined),
          title: Text(l10n.settingsLegalAccountDeletion),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: openAccountDeletionInfo,
        ),
        const Divider(height: 32),
        ListTile(
          title: Text(
            l10n.profileSignOut,
            style: TextStyle(
              color: colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: onSignOut,
        ),
      ],
    );
  }
}
