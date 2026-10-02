import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/export/export_artifact.dart';
import '../../../../core/export/export_share.dart';
import '../../../../core/export/pdf_export_delivery.dart';
import '../../../../core/pdf/pdf_brand_store.dart';
import '../../../../core/pdf/pdf_coach_header.dart';
import '../../../../core/pdf/pdf_export_labels_l10n.dart';
import '../../auth/data/local_coach_profile_repository.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_snackbar.dart';
import 'package:powercoach_studio/core/ui/widgets/pdf_export_progress_dialog.dart';

import '../data/customer_repository.dart';
import '../data/models/customer.dart';

Future<void> shareCustomerMeasurementExport({
  required BuildContext context,
  required AppLocalizations l10n,
  required Future<ExportArtifact> Function() export,
  bool showProgress = false,
  bool deliverPdfWithActionSheet = false,
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
    if (!context.mounted) return;
    if (deliverPdfWithActionSheet &&
        artifact.mimeType == 'application/pdf') {
      await presentPdfExportArtifact(
        context,
        artifact: artifact,
        l10n: l10n,
      );
      return;
    }
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
  BuildContext context, {
  String? customerId,
  Customer? customer,
}) async {
  final labels = AppLocalizations.of(context).toPdfExportLabels();
  final uid = Supabase.instance.client.auth.currentUser?.id ?? '';
  final profile = await LocalCoachProfileRepository.instance.getProfile(uid);
  final email = Supabase.instance.client.auth.currentUser?.email;
  final brand = await PdfBrandStore.instance.read(uid);
  final logoBytes = await PdfBrandStore.instance.loadLogoBytes(uid);

  Customer? resolved = customer;
  final id = customerId?.trim() ?? '';
  if (resolved == null && id.isNotEmpty) {
    try {
      resolved = await CustomerRepository().getById(id);
    } catch (_) {
      resolved = null;
    }
  }

  return buildPdfCoachHeader(
    labels: labels,
    customer: resolved,
    profile: profile,
    authEmail: email,
    brand: brand,
    logoBytes: logoBytes,
  );
}
