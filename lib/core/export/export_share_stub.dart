import 'package:share_plus/share_plus.dart';

import 'export_artifact.dart';

Future<void> shareExportArtifactImpl(ExportArtifact artifact) {
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

Future<void> downloadExportArtifactImpl(ExportArtifact artifact) {
  return shareExportArtifactImpl(artifact);
}

Future<void> saveExportArtifactToDownloadsImpl(ExportArtifact artifact) {
  return shareExportArtifactImpl(artifact);
}
