import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/export/export_artifact.dart';
import '../../../../core/export/export_share.dart';
import '../../../../core/pdf/pdf_coach_header.dart';
import '../../../../core/pdf/pdf_export_labels_l10n.dart';
import '../../auth/data/local_coach_profile_repository.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_snackbar.dart';
import 'package:powercoach_studio/core/ui/widgets/pdf_export_progress_dialog.dart';

Future<void> shareCustomerMeasurementExport({
  required BuildContext context,
  required AppLocalizations l10n,
  required Future<ExportArtifact> Function() export,
  bool showProgress = false,
}) async {
  final labels = l10n.toPdfExportLabels();
  if (showProgress) {
    showPdfExportProgressDialog(
      context,
      message: labels.exportGenerating,
    );
  }
  try {
    final artifact = await export();
    await downloadExportArtifact(artifact);
    if (!context.mounted) return;
    showAppSnackBar(context, content: Text(l10n.measurementExportSuccess));
  } catch (error, stackTrace) {
    await Sentry.captureException(error, stackTrace: stackTrace);
    if (!context.mounted) return;
    showAppSnackBar(
      context,
      content: Text(l10n.measurementExportError),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
    );
  } finally {
    if (showProgress && context.mounted) {
      hidePdfExportProgressDialog(context);
    }
  }
}

Future<PdfCoachHeaderInfo> resolveCustomerMeasurementPdfCoachHeader(
  BuildContext context,
) async {
  final labels = AppLocalizations.of(context).toPdfExportLabels();
  final uid = Supabase.instance.client.auth.currentUser?.id ?? '';
  final profile = await LocalCoachProfileRepository.instance.getProfile(uid);
  final email = Supabase.instance.client.auth.currentUser?.email;
  return buildPdfCoachHeader(
    labels: labels,
    profile: profile,
    authEmail: email,
  );
}
