import 'package:share_plus/share_plus.dart';

import 'export_artifact.dart';

Future<void> downloadExportArtifactImpl(ExportArtifact artifact) {
  return Share.shareXFiles(
    [
      XFile.fromData(
        artifact.bytes,
        name: artifact.filename,
        mimeType: artifact.mimeType,
      ),
    ],
  );
}
