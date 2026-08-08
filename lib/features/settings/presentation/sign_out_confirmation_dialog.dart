import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

/// Asks the coach to export a backup before wiping local data on sign-out.
Future<bool> showSignOutConfirmationDialog(
  BuildContext context, {
  required Future<void> Function() onExportBackup,
  required Future<void> Function() onUploadCloudBackup,
}) async {
  final l10n = AppLocalizations.of(context);
  final theme = Theme.of(context);
  final cs = theme.colorScheme;

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.signOutConfirmTitle),
      content: Text(
        l10n.signOutConfirmMessage,
        style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.signOutConfirmCancel),
        ),
        OutlinedButton(
          onPressed: () async {
            Navigator.of(dialogContext).pop(false);
            await onExportBackup();
          },
          child: Text(l10n.signOutConfirmExportFirst),
        ),
        OutlinedButton(
          onPressed: () async {
            Navigator.of(dialogContext).pop(false);
            await onUploadCloudBackup();
          },
          child: Text(l10n.signOutConfirmUploadCloud),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: cs.error,
            foregroundColor: cs.onError,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
            ),
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.signOutConfirmProceed),
        ),
      ],
    ),
  );

  return result ?? false;
}
