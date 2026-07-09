import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/notifications/notification_scheduler_service.dart';
import '../../../../core/notifications/reminder_store.dart';
import '../../../../core/storage/offline_local_store.dart';
import '../../../../l10n/app_localizations.dart';
import 'settings_backup_handler.dart';
import 'sign_out_confirmation_dialog.dart';

/// Wipes local data, signs out of Supabase, and returns to the landing page.
Future<void> executeSignOut(BuildContext context) async {
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
  if (context.mounted) context.go('/');
}

/// Shows confirmation (with optional backup export) then signs out when confirmed.
Future<void> requestSignOut(
  BuildContext context, {
  Future<void> Function()? onPreferencesReloaded,
}) async {
  final l10n = AppLocalizations.of(context);
  final backupHandler = SettingsBackupHandler(
    context: context,
    onPreferencesReloaded: onPreferencesReloaded ?? () async {},
  );

  final confirmed = await showSignOutConfirmationDialog(
    context,
    onExportBackup: () => backupHandler.exportBackup(l10n),
  );
  if (!context.mounted || !confirmed) return;
  await executeSignOut(context);
}

/// Settings screen entry point (keeps existing call site).
Future<void> performSettingsSignOut(
  BuildContext context, {
  Future<void> Function()? onPreferencesReloaded,
}) =>
    requestSignOut(context, onPreferencesReloaded: onPreferencesReloaded);
