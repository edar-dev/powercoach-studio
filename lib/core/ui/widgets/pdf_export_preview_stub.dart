import 'package:flutter/material.dart';

import '../../export/export_artifact.dart';
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
  return PdfExportPreviewResult.cancelled;
}
