import 'package:flutter/material.dart';

import '../../../core/theme/marketing_dark_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Result of the empty-local cloud recovery prompt.
enum CloudRecoveryChoice { restore, notNow }

/// Asks whether to restore the newest cloud snapshot when local data is empty.
Future<CloudRecoveryChoice?> showCloudRecoveryDialog(BuildContext context) {
  return showDialog<CloudRecoveryChoice>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => const CloudRecoveryDialog(),
  );
}

class CloudRecoveryDialog extends StatelessWidget {
  const CloudRecoveryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: MarketingDarkColors.stitchCard,
      title: Text(
        l10n.cloudRecoveryTitle,
        style: theme.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        l10n.cloudRecoveryMessage,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: MarketingDarkColors.slate300,
          height: 1.45,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(CloudRecoveryChoice.notNow),
          child: Text(l10n.cloudRecoveryNotNow),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(CloudRecoveryChoice.restore),
          child: Text(l10n.cloudRecoveryRestore),
        ),
      ],
    );
  }
}
