import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

/// Tries to decode [bytes] as a PDF [pw.MemoryImage] (PNG/JPEG).
///
/// Returns `null` when the payload is corrupt or not a supported image type,
/// so callers can skip the logo instead of failing the whole export.
pw.MemoryImage? tryPdfMemoryImage(Uint8List bytes) {
  if (bytes.isEmpty) return null;
  try {
    return pw.MemoryImage(bytes);
  } catch (_) {
    return null;
  }
}

/// True when [error] looks like a pdf-package logo/image decode failure.
bool isPdfLogoDecodeError(Object error) {
  final msg = error.toString().toLowerCase();
  return msg.contains('unable to guess the image type') ||
      msg.contains('unable decode the image') ||
      msg.contains('unable to decode the image') ||
      msg.contains('unable to decode image');
}
