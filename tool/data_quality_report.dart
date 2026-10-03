import 'dart:convert';
import 'dart:io';

import 'package:powercoach_studio/core/data_quality/data_quality.dart';

/// Print a data-quality report for a user backup JSON file.
///
/// Usage:
///   dart run tool/data_quality_report.dart path/to/backup.json
///   dart run tool/data_quality_report.dart path/to/backup.json --format markdown
///   dart run tool/data_quality_report.dart path/to/backup.json --format json
void main(List<String> args) {
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    stdout.writeln(
      'Usage: dart run tool/data_quality_report.dart <backup.json> '
      '[--format json|markdown]',
    );
    exit(args.isEmpty ? 64 : 0);
  }

  String? path;
  var format = 'markdown';
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--format' && i + 1 < args.length) {
      format = args[++i].toLowerCase();
      continue;
    }
    if (!arg.startsWith('-')) {
      path ??= arg;
    }
  }

  if (path == null) {
    stderr.writeln('Missing backup file path');
    exit(64);
  }

  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('File not found: $path');
    exit(66);
  }

  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map) {
    stderr.writeln('Backup root must be a JSON object');
    exit(65);
  }

  const scanner = DataQualityScanner();
  final report = scanner.scanBackupJson(decoded.cast<String, dynamic>());

  if (format == 'json') {
    stdout.writeln(
      const JsonEncoder.withIndent('  ').convert(report.toJson()),
    );
  } else if (format == 'markdown' || format == 'md') {
    stdout.write(report.toMarkdown());
  } else {
    stderr.writeln('Unknown format "$format" (use json or markdown)');
    exit(64);
  }

  exit(report.hasErrors ? 1 : 0);
}
