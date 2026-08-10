import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/legal_urls.dart';
import '../../../../core/platform/open_external_url.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

/// First-run dialog explaining local-first storage and encouraging JSON backup.
Future<void> showBackupOnboardingDialog(
  BuildContext context, {
  required VoidCallback onOpenSettings,
  required Future<void> Function() onExportBackup,
}) async {
  final l10n = AppLocalizations.of(context);
  final theme = Theme.of(context);
  final cs = theme.colorScheme;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.backupOnboardingTitle),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.backupOnboardingMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.backupOnboardingDeskGymHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            if (kIsWeb) ...[
              const SizedBox(height: 16),
              Text(
                l10n.backupOnboardingWebHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onOpenSettings();
          },
          child: Text(l10n.backupOnboardingOpenSettings),
        ),
        OutlinedButton(
          onPressed: () async {
            Navigator.of(dialogContext).pop();
            await onExportBackup();
          },
          child: Text(l10n.backupOnboardingExportNow),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
            ),
          ),
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.backupOnboardingGotIt),
        ),
      ],
    ),
  );
}

void openPrivacyPolicy() => openExternalUrl(LegalUrls.privacyPolicy);

void openTermsOfService() => openExternalUrl(LegalUrls.termsOfService);

void openAccountDeletionInfo() => openExternalUrl(LegalUrls.accountDeletion);
