import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../export/export_artifact.dart';
import '../../export/export_share.dart';
import 'pdf_export_preview_result.dart';

/// Web: preview in new tab or download from dialog.
Future<PdfExportPreviewResult> showPdfExportPreviewDialog(
  BuildContext context, {
  required ExportArtifact artifact,
  required String title,
  required String message,
  required String openPreviewLabel,
  required String downloadLabel,
  required String cancelLabel,
}) async {
  final action = await showDialog<_PdfPreviewAction>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(_PdfPreviewAction.cancel),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () {
            _openPdfInNewTab(artifact);
            Navigator.of(ctx).pop(_PdfPreviewAction.previewOnly);
          },
          child: Text(openPreviewLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(_PdfPreviewAction.download),
          child: Text(downloadLabel),
        ),
      ],
    ),
  );

  switch (action) {
    case _PdfPreviewAction.download:
      await downloadExportArtifact(artifact);
      return PdfExportPreviewResult.downloaded;
    case _PdfPreviewAction.previewOnly:
      return PdfExportPreviewResult.previewOpened;
    case _PdfPreviewAction.cancel:
    case null:
      return PdfExportPreviewResult.cancelled;
  }
}

enum _PdfPreviewAction { cancel, previewOnly, download }

void _openPdfInNewTab(ExportArtifact artifact) {
  final blobParts = <web.BlobPart>[artifact.bytes.toJS].toJS;
  final blob = web.Blob(
    blobParts,
    web.BlobPropertyBag(type: artifact.mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  web.window.open(url, '_blank');
}
