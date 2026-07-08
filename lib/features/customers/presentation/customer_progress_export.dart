import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../core/export/export_artifact.dart';
import '../../../core/export/export_share.dart';
import '../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_snackbar.dart';

Future<void> shareCustomerProgressExport({
  required BuildContext context,
  required AppLocalizations l10n,
  required Future<ExportArtifact> Function() export,
}) async {
  try {
    final artifact = await export();
    await downloadExportArtifact(artifact);
    if (!context.mounted) return;
    showAppSnackBar(context, content: Text(l10n.customerProgressExportSuccess));
  } catch (error, stackTrace) {
    await Sentry.captureException(error, stackTrace: stackTrace);
    if (!context.mounted) return;
    showAppSnackBar(
      context,
      content: Text(l10n.customerProgressExportFailed),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
    );
  }
}
