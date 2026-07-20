import 'package:flutter/material.dart';

import '../../export/export_artifact.dart';
import 'pdf_export_preview_result.dart';

/// Non-web: skip preview; caller performs download.
Future<PdfExportPreviewResult> showPdfExportPreviewDialog(
  BuildContext context, {
  required ExportArtifact artifact,
  required String title,
  required String message,
  required String openPreviewLabel,
  required String downloadLabel,
  required String cancelLabel,
}) async {
  return PdfExportPreviewResult.downloaded;
}
