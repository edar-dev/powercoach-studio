import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../export/export_artifact.dart';
import '../../export/export_share.dart';
import 'pdf_export_preview_result.dart';

/// Opens [artifact] in a new browser tab as a blob URL.
Future<void> openPdfExportPreview(ExportArtifact artifact) async {
  _openPdfInNewTab(artifact);
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
      await saveExportArtifactToDownloads(artifact);
      return PdfExportPreviewResult.downloaded;
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
          onPressed: () {
            _openPdfInNewTab(artifact);
            Navigator.of(ctx).pop(_PdfPostGenerateAction.preview);
          },
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
      return PdfExportPreviewResult.previewOpened;
    case _PdfPostGenerateAction.share:
      await shareExportArtifact(artifact);
      return PdfExportPreviewResult.shared;
    case _PdfPostGenerateAction.save:
      await saveExportArtifactToDownloads(artifact);
      return PdfExportPreviewResult.downloaded;
    case _PdfPostGenerateAction.cancel:
    case null:
      return PdfExportPreviewResult.cancelled;
  }
}

enum _PdfPostGenerateAction { cancel, preview, share, save }

enum _PdfShareSaveAction { close, share, save }

void _openPdfInNewTab(ExportArtifact artifact) {
  final blobParts = <web.BlobPart>[artifact.bytes.toJS].toJS;
  final blob = web.Blob(
    blobParts,
    web.BlobPropertyBag(type: artifact.mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  web.window.open(url, '_blank');
}
