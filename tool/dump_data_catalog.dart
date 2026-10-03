import 'dart:convert';
import 'dart:io';

import 'package:powercoach_studio/core/data_catalog/data_catalog.dart';

/// Dump the in-repo data catalog as JSON for OpenMetadata / tooling.
///
/// Usage:
///   dart run tool/dump_data_catalog.dart
///   dart run tool/dump_data_catalog.dart --out path/to/registry.json
void main(List<String> args) {
  String? outPath;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--out' && i + 1 < args.length) {
      outPath = args[i + 1];
      i++;
    }
  }

  final json = const JsonEncoder.withIndent('  ')
      .convert(DataCatalogRegistry.toJsonDocument());

  if (outPath != null) {
    final file = File(outPath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync('$json\n');
    stdout.writeln('Wrote ${file.path}');
  } else {
    stdout.writeln(json);
  }
}
