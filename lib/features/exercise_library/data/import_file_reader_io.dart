import 'dart:io';

Future<String> readImportFileFromPath(String path) {
  return File(path).readAsString();
}
