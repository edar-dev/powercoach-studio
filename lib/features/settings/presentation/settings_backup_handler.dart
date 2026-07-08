import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/backup/backup_path_reader.dart';
import '../../../../core/backup/user_data_backup_codec.dart';
import '../../../../core/backup/user_data_backup_service.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_snackbar.dart';
import 'widgets/backup_import_preview_dialog.dart';

/// Export/import orchestration for settings backup actions.
class SettingsBackupHandler {
  SettingsBackupHandler({
    required this.context,
    required this.onPreferencesReloaded,
  });

  final BuildContext context;
  final Future<void> Function() onPreferencesReloaded;

  String importErrorMessage(AppLocalizations l10n, Object error) {
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

  Future<void> exportBackup(AppLocalizations l10n) async {
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
      if (!context.mounted) return;
      showAppSnackBar(context, content: Text(l10n.settingsBackupExportSuccess));
    } catch (_) {
      if (!context.mounted) return;
      showAppSnackBar(context, content: Text(l10n.settingsBackupErrorGeneric));
    }
  }

  Future<void> importBackup(AppLocalizations l10n) async {
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
    if (result == null || result.files.isEmpty || !context.mounted) return;
    final file = result.files.single;
    late final String content;
    try {
      if (file.bytes != null) {
        content = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        content = await readBackupPathUtf8(file.path!);
      } else {
        if (!context.mounted) return;
        showAppSnackBar(context, content: Text(l10n.settingsBackupErrorInvalidFile));
        return;
      }
    } catch (_) {
      if (!context.mounted) return;
      showAppSnackBar(context, content: Text(l10n.settingsBackupErrorInvalidFile));
      return;
    }

    if (!context.mounted) return;

    ParsedUserBackup parsed;
    try {
      parsed = parseUserBackupJson(content, uid);
    } catch (e) {
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        content: Text(importErrorMessage(l10n, e)),
      );
      return;
    }

    if (!context.mounted) return;
    final counts = UserDataBackupService.instance.previewCounts(parsed);
    final decision = await showDialog<BackupImportDecision>(
      context: context,
      builder: (ctx) => BackupImportPreviewDialog(
        l10n: l10n,
        counts: counts,
      ),
    );
    if (decision == null || !context.mounted) return;

    if (decision.replaceAll) {
      final typed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final controller = TextEditingController();
          return AlertDialog(
            title: Text(l10n.backupImportPreviewTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.backupImportTypeConfirm),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: l10n.backupImportTypeConfirmHint,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n.exerciseLibraryCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(
                  controller.text.trim().toUpperCase() ==
                      l10n.backupImportTypeConfirmHint,
                ),
                child: Text(l10n.backupImportConfirm),
              ),
            ],
          );
        },
      );
      if (typed != true || !context.mounted) return;
    }

    try {
      if (decision.replaceAll) {
        await UserDataBackupService.instance.restoreParsed(parsed, uid);
      } else {
        await UserDataBackupService.instance.mergeRestore(parsed, uid);
      }
      await onPreferencesReloaded();
      if (!context.mounted) return;
      showAppSnackBar(context, content: Text(l10n.settingsBackupImportSuccess));
    } catch (e) {
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        content: Text(importErrorMessage(l10n, e)),
      );
    }
  }
}
