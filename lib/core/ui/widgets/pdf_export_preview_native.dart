import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../l10n/app_localizations.dart';
import '../../export/export_artifact.dart';
import '../../export/export_share.dart';
import 'pdf_export_preview_result.dart';

/// Opens the system PDF preview for [artifact] (Printing.layoutPdf).
Future<void> openPdfExportPreview(ExportArtifact artifact) async {
  await Printing.layoutPdf(
    onLayout: (_) async => artifact.bytes,
    name: artifact.filename,
  );
}

/// Dialog with Close / Share / Save only (no Preview button).
Future<PdfExportPreviewResult> showPdfExportShareSaveDialog(
  BuildContext context, {
  required ExportArtifact artifact,
  required String title,
  required String message,
  required String shareLabel,
  required String saveLabel,
  required String closeLabel,
}) async {
  final action = await showDialog<_PdfShareSaveAction>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(_PdfShareSaveAction.close),
          child: Text(closeLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(_PdfShareSaveAction.share),
          child: Text(shareLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(_PdfShareSaveAction.save),
          child: Text(saveLabel),
        ),
      ],
    ),
  );

  switch (action) {
    case _PdfShareSaveAction.share:
      await shareExportArtifact(artifact);
      return PdfExportPreviewResult.shared;
    case _PdfShareSaveAction.save:
      try {
        await saveExportArtifactToDownloads(artifact);
        return PdfExportPreviewResult.downloaded;
      } on StateError {
        if (context.mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.pdfExportSaveUnavailable),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return PdfExportPreviewResult.cancelled;
      }
    case _PdfShareSaveAction.close:
    case null:
      return PdfExportPreviewResult.cancelled;
  }
}

Future<PdfExportPreviewResult> showPdfExportPreviewDialog(
  BuildContext context, {
  required ExportArtifact artifact,
  required String title,
  required String message,
  required String previewLabel,
  required String shareLabel,
  required String saveLabel,
  required String cancelLabel,
}) async {
  final action = await showDialog<_PdfPostGenerateAction>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(_PdfPostGenerateAction.cancel),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(ctx).pop(_PdfPostGenerateAction.preview),
          child: Text(previewLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(_PdfPostGenerateAction.share),
          child: Text(shareLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(_PdfPostGenerateAction.save),
          child: Text(saveLabel),
        ),
      ],
    ),
  );

  switch (action) {
    case _PdfPostGenerateAction.preview:
      await openPdfExportPreview(artifact);
      return PdfExportPreviewResult.previewOpened;
    case _PdfPostGenerateAction.share:
      await shareExportArtifact(artifact);
      return PdfExportPreviewResult.shared;
    case _PdfPostGenerateAction.save:
      try {
        await saveExportArtifactToDownloads(artifact);
        return PdfExportPreviewResult.downloaded;
      } on StateError {
        if (context.mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.pdfExportSaveUnavailable),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return PdfExportPreviewResult.cancelled;
      }
    case _PdfPostGenerateAction.cancel:
    case null:
      return PdfExportPreviewResult.cancelled;
  }
}

enum _PdfPostGenerateAction { cancel, preview, share, save }

enum _PdfShareSaveAction { close, share, save }
