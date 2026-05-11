import 'dart:io' show File;

Future<String> readBackupPathUtf8(String path) =>
    File(path).readAsString();
