import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/locale/app_locale_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/backup/backup_path_reader.dart';
import '../../../../core/backup/user_data_backup_codec.dart';
import '../../../../core/backup/user_data_backup_service.dart';
import '../../../../core/notifications/notification_scheduler_service.dart';
import '../../../../core/notifications/reminder_store.dart';
import '../../../../core/settings/settings_prefs_keys.dart';
import '../../../../core/storage/offline_local_store.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/app_snackbar.dart';
import '../../../../widgets/stitch_secondary_app_bar.dart';
import '../../../integrations/hevy/presentation/hevy_settings_section.dart';

/// Simplified App Settings – Stitch screen ID 8ab8a84172594c1c9911b5762e2a7257.
/// Personal info, Subscription, Notifications, Language, Sign out.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    var enabled = prefs.getBool(SettingsPrefsKeys.notificationsEnabled) ?? true;

    if (!kIsWeb &&
        NotificationSchedulerService.instance.supportsLocalNotifications) {
      await NotificationSchedulerService.instance.ensureInitialized();
      await NotificationSchedulerService.instance.downgradePreferenceIfOsDenied();
      final prefs2 = await SharedPreferences.getInstance();
      enabled =
          prefs2.getBool(SettingsPrefsKeys.notificationsEnabled) ?? true;
      await NotificationSchedulerService.instance
          .syncWithNotificationPreference();
    }

    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled;
      _loadingPrefs = false;
    });
  }

  Future<void> _onNotificationsToggle(bool value) async {
    final l10n = AppLocalizations.of(context);
    if (kIsWeb) {
      showAppSnackBar(context, content: Text(l10n.reminderWebNotSupported));
      return;
    }

    if (value) {
      await NotificationSchedulerService.instance.ensureInitialized();
      final granted =
          await NotificationSchedulerService.instance.requestOsPermission();
      if (!granted) {
        if (!mounted) return;
        showAppSnackBar(
          context,
          content: Text(l10n.settingsNotificationPermissionDenied),
        );
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(SettingsPrefsKeys.notificationsEnabled, true);
      if (!mounted) return;
      setState(() => _notificationsEnabled = true);
      await NotificationSchedulerService.instance
          .syncWithNotificationPreference();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(SettingsPrefsKeys.notificationsEnabled, false);
      if (!mounted) return;
      setState(() => _notificationsEnabled = false);
      await NotificationSchedulerService.instance.cancelAllScheduled();
    }
  }

  Future<void> _showLanguagePicker(AppLocalizations l10n) async {
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
    if (selected == null || !mounted) return;
    await AppLocaleController.instance.setLocale(Locale(selected));
    if (!mounted) return;
    showAppSnackBar(context, content: Text(l10n.settingsLanguageSaved));
  }

  void _signOut() async {
    if (!kIsWeb &&
        NotificationSchedulerService.instance.supportsLocalNotifications) {
      await NotificationSchedulerService.instance.cancelAllScheduled();
      await ReminderStore.instance.clear();
    }
    final uid = SupabaseBootstrap.currentUser?.id;
    if (uid != null) {
      await OfflineLocalStore.instance.wipeForUser(uid);
    }
    await Supabase.instance.client.auth.signOut();
    if (mounted) context.go('/');
  }

  String _backupImportErrorMessage(AppLocalizations l10n, Object error) {
    if (error is UserBackupImportException) {
      switch (error.message) {
        case 'wrong_account':
          return l10n.settingsBackupErrorWrongAccount;
        case 'unsupported_schema':
          return l10n.settingsBackupErrorUnsupportedSchema;
        default:
          return l10n.settingsBackupErrorInvalidFile;
      }
    }
    return l10n.settingsBackupErrorGeneric;
  }

  Future<void> _exportBackup(AppLocalizations l10n) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      showAppSnackBar(context, content: Text(l10n.settingsBackupErrorNotSignedIn));
      return;
    }
    try {
      final json =
          await UserDataBackupService.instance.buildExportJsonPretty(uid);
      final name =
          'powercoach-user-backup-${DateTime.now().toUtc().toIso8601String().split('T').first}.json';
      await Share.share(
        json,
        subject: name,
        sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
      );
      if (!mounted) return;
      showAppSnackBar(context, content: Text(l10n.settingsBackupExportSuccess));
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(context, content: Text(l10n.settingsBackupErrorGeneric));
    }
  }

  Future<void> _importBackup(AppLocalizations l10n) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      showAppSnackBar(context, content: Text(l10n.settingsBackupErrorNotSignedIn));
      return;
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    final file = result.files.single;
    late final String content;
    try {
      if (file.bytes != null) {
        content = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        content = await readBackupPathUtf8(file.path!);
      } else {
        if (!mounted) return;
        showAppSnackBar(context, content: Text(l10n.settingsBackupErrorInvalidFile));
        return;
      }
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(context, content: Text(l10n.settingsBackupErrorInvalidFile));
      return;
    }

    if (!mounted) return;

    ParsedUserBackup parsed;
    try {
      parsed = parseUserBackupJson(content, uid);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        content: Text(_backupImportErrorMessage(l10n, e)),
      );
      return;
    }

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsBackupImportConfirmTitle),
        content: Text(l10n.settingsBackupImportConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.exerciseLibraryCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.settingsBackupImportConfirmReplace),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await UserDataBackupService.instance.restoreParsed(parsed, uid);
      await _loadPreferences();
      if (!mounted) return;
      showAppSnackBar(context, content: Text(l10n.settingsBackupImportSuccess));
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        content: Text(_backupImportErrorMessage(l10n, e)),
      );
    }
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
          : ListView(
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
                SwitchListTile(
                  title: Text(l10n.settingsNotifications),
                  subtitle: Text(
                    l10n.settingsNotificationsDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: _notificationsEnabled,
                  onChanged: kIsWeb ? null : _onNotificationsToggle,
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
                  l10n.settingsBackupSectionSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: Text(l10n.settingsBackupExport),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _exportBackup(l10n),
                ),
                ListTile(
                  leading: const Icon(Icons.restore_outlined),
                  title: Text(l10n.settingsBackupImport),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _importBackup(l10n),
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
                  onTap: () => _showLanguagePicker(l10n),
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
                  onTap: _signOut,
                ),
              ],
            ),
    );
  }
}
