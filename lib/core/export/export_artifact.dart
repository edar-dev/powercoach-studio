import 'dart:typed_data';

/// In-memory export payload for cross-platform sharing (including web).
class ExportArtifact {
  const ExportArtifact({
    required this.bytes,
    required this.filename,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String filename;
  final String mimeType;
}
