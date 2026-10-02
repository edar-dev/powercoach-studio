import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'export_artifact.dart';

Future<void> downloadExportArtifactImpl(ExportArtifact artifact) async {
  // Mobile: share-first (system share sheet). Desktop: Downloads when available.
  if (Platform.isIOS || Platform.isAndroid) {
    await _shareExportArtifactViaTempFile(artifact);
    return;
  }

  final downloadsDir = await getDownloadsDirectory();
  if (downloadsDir != null) {
    final file = File(p.join(downloadsDir.path, artifact.filename));
    await file.writeAsBytes(artifact.bytes, flush: true);
    return;
  }

  // Fallback when Downloads is unavailable.
  await _shareExportArtifactViaTempFile(artifact);
}

/// Writes to the platform Downloads directory when available.
/// Reserved for explicit "Save to Downloads" flows (e.g. PR3 action sheet).
Future<void> saveExportArtifactToDownloadsImpl(ExportArtifact artifact) async {
  final downloadsDir = await getDownloadsDirectory();
  if (downloadsDir == null) {
    throw StateError('Downloads directory is unavailable on this platform');
  }
  final file = File(p.join(downloadsDir.path, artifact.filename));
  await file.writeAsBytes(artifact.bytes, flush: true);
}

Future<void> _shareExportArtifactViaTempFile(ExportArtifact artifact) async {
  final tempDir = await getTemporaryDirectory();
  final file = File(p.join(tempDir.path, artifact.filename));
  await file.writeAsBytes(artifact.bytes, flush: true);
  await Share.shareXFiles(
    [
      XFile(
        file.path,
        mimeType: artifact.mimeType,
        name: artifact.filename,
      ),
    ],
  );
}
