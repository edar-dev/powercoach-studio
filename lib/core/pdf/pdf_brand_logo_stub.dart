import 'dart:typed_data';

Future<String> writePdfBrandLogoFile({
  required String userId,
  required Uint8List bytes,
  required String extension,
}) async {
  throw UnsupportedError('Native logo files are not available on this platform');
}

Future<Uint8List?> readPdfBrandLogoFile(String relativePath) async => null;

Future<void> clearPdfBrandLogoFiles(String userId) async {}
