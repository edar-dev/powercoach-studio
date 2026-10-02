import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../l10n/app_localizations.dart';
import '../../export/export_artifact.dart';
import '../../export/export_share.dart';
import 'pdf_export_preview_result.dart';

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
      await Printing.layoutPdf(
        onLayout: (_) async => artifact.bytes,
        name: artifact.filename,
      );
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
