import 'export_artifact.dart';
import 'export_share_stub.dart'
    if (dart.library.html) 'export_share_web.dart'
    if (dart.library.io) 'export_share_io.dart';

Future<void> downloadExportArtifact(ExportArtifact artifact) {
  return downloadExportArtifactImpl(artifact);
}
