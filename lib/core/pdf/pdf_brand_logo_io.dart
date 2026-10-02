import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Relative path under application documents, e.g. `pdf_brand/<userId>/logo.png`.
Future<String> writePdfBrandLogoFile({
  required String userId,
  required Uint8List bytes,
  required String extension,
}) async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(docs.path, 'pdf_brand', userId));
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  // Remove prior logo variants so only one file remains.
  await for (final entity in dir.list()) {
    if (entity is File && p.basename(entity.path).startsWith('logo.')) {
      await entity.delete();
    }
  }
  final relative = p.join('pdf_brand', userId, 'logo.$extension');
  final file = File(p.join(docs.path, relative));
  await file.writeAsBytes(bytes, flush: true);
  return relative.replaceAll('\\', '/');
}

Future<Uint8List?> readPdfBrandLogoFile(String relativePath) async {
  final trimmed = relativePath.trim();
  if (trimmed.isEmpty || trimmed.startsWith('web/')) return null;
  final docs = await getApplicationDocumentsDirectory();
  final file = File(p.join(docs.path, trimmed));
  if (!await file.exists()) return null;
  return file.readAsBytes();
}

Future<void> clearPdfBrandLogoFiles(String userId) async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(docs.path, 'pdf_brand', userId));
  if (!await dir.exists()) return;
  await for (final entity in dir.list()) {
    if (entity is File) {
      await entity.delete();
    }
  }
}
