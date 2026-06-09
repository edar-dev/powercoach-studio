import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'export_artifact.dart';

Future<void> downloadExportArtifactImpl(ExportArtifact artifact) async {
  final blobParts = <web.BlobPart>[artifact.bytes.toJS].toJS;
  final blob = web.Blob(
    blobParts,
    web.BlobPropertyBag(type: artifact.mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = artifact.filename;
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}
