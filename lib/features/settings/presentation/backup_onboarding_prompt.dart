import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/settings/backup_onboarding_store.dart';

import '../../../../l10n/app_localizations.dart';
import 'backup_onboarding_dialog.dart';
import 'settings_backup_handler.dart';

/// Shows backup guidance once per signed-in user on this device.
Future<void> maybeShowBackupOnboardingIfNeeded(
  BuildContext context, {
  Future<void> Function()? onPreferencesReloaded,
}) async {
  final user = SupabaseBootstrap.currentUser;
  if (user == null) return;

  final seen = await BackupOnboardingStore.instance.hasSeen(user.id);
  if (!context.mounted || seen) return;

  final l10n = AppLocalizations.of(context);
  final backupHandler = SettingsBackupHandler(
    context: context,
    onPreferencesReloaded: onPreferencesReloaded ?? () async {},
  );

  await showBackupOnboardingDialog(
    context,
    onOpenSettings: () => navigateTo(context, '/settings'),
    onExportBackup: () => backupHandler.exportBackup(l10n),
  );

  if (!context.mounted) return;
  await BackupOnboardingStore.instance.markSeen(user.id);
}
