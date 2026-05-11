import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/backup/backup_path_reader.dart';
import '../../../../core/backup/user_data_backup_codec.dart';
import '../../../../core/backup/user_data_backup_service.dart';
import '../../../../core/settings/settings_prefs_keys.dart';
import '../../../../core/storage/offline_local_store.dart';
import '../../../../core/utils/not_implemented.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/app_snackbar.dart';
import '../../../../widgets/stitch_secondary_app_bar.dart';

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
    setState(() {
      _notificationsEnabled =
          prefs.getBool(SettingsPrefsKeys.notificationsEnabled) ?? true;
      _loadingPrefs = false;
    });
  }

  Future<void> _setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SettingsPrefsKeys.notificationsEnabled, value);
    if (mounted) setState(() => _notificationsEnabled = value);
  }

  void _signOut() async {
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
                  onChanged: _setNotificationsEnabled,
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
                ListTile(
                  title: Text(l10n.settingsLanguage),
                  subtitle: Text(
                    l10n.settingsLanguageDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showNotImplementedAlert(context),
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
