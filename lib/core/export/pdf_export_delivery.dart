import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/stitch_m3_theme.dart';
import '../ui/widgets/pdf_export_preview_dialog.dart';
import 'export_artifact.dart';

/// Presents preview / share / save actions after a PDF artifact is generated.
Future<void> presentPdfExportArtifact(
  BuildContext context, {
  required ExportArtifact artifact,
  required AppLocalizations l10n,
}) async {
  final result = await showPdfExportPreviewDialog(
    context,
    artifact: artifact,
    title: l10n.pdfExportPostGenerateTitle,
    message: l10n.pdfExportPostGenerateMessage,
    previewLabel: l10n.pdfExportActionPreview,
    shareLabel: l10n.pdfExportActionShare,
    saveLabel: l10n.pdfExportActionSave,
    cancelLabel: l10n.customerCancel,
  );
  if (!context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  switch (result) {
    case PdfExportPreviewResult.cancelled:
      return;
    case PdfExportPreviewResult.previewOpened:
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.pdfExportPreviewOpened),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    case PdfExportPreviewResult.shared:
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.pdfExportSharedSuccess),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    case PdfExportPreviewResult.downloaded:
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.pdfExportSavedSuccess),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
  }
}

/// Workout-builder path: auto-open preview, then Share / Save / Close.
///
/// Skips the auto-preview snackbar; share/save still show success snackbars.
Future<void> presentPdfExportArtifactPreviewFirst(
  BuildContext context, {
  required ExportArtifact artifact,
  required AppLocalizations l10n,
}) async {
  await openPdfExportPreview(artifact);
  if (!context.mounted) return;

  final result = await showPdfExportShareSaveDialog(
    context,
    artifact: artifact,
    title: l10n.pdfExportPreviewThenShareTitle,
    message: l10n.pdfExportPreviewThenShareMessage,
    shareLabel: l10n.pdfExportActionShare,
    saveLabel: l10n.pdfExportActionSave,
    closeLabel: l10n.pdfExportActionClose,
  );
  if (!context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  switch (result) {
    case PdfExportPreviewResult.cancelled:
    case PdfExportPreviewResult.previewOpened:
      return;
    case PdfExportPreviewResult.shared:
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.pdfExportSharedSuccess),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    case PdfExportPreviewResult.downloaded:
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.pdfExportSavedSuccess),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
  }
}
