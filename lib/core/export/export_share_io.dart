import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'export_artifact.dart';

Future<void> downloadExportArtifactImpl(ExportArtifact artifact) async {
  final downloadsDir = await getDownloadsDirectory();
  if (downloadsDir != null) {
    final file = File(p.join(downloadsDir.path, artifact.filename));
    await file.writeAsBytes(artifact.bytes, flush: true);
    return;
  }

  // Fallback when Downloads is unavailable (e.g. some iOS contexts).
  await Share.shareXFiles(
    [
      XFile.fromData(
        artifact.bytes,
        name: artifact.filename,
        mimeType: artifact.mimeType,
      ),
    ],
  );
}
