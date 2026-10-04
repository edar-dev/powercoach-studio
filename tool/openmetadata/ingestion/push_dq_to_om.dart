import 'dart:io';

/// Thin CLI wrapper: run DQ bridge against fixture (or `--backup`) and
/// optionally `--live` push to local OpenMetadata.
///
/// Prefer `tool/openmetadata/scripts/dq_to_om.sh` from the repo root.
///
/// Usage:
///   dart run tool/openmetadata/ingestion/push_dq_to_om.dart
///   dart run tool/openmetadata/ingestion/push_dq_to_om.dart --live
///   dart run tool/openmetadata/ingestion/push_dq_to_om.dart --live --backup path.json
Future<void> main(List<String> args) async {
  final forwarded = <String>['--with-dq', ...args];
  final process = await Process.start(
    Platform.resolvedExecutable,
    [
      'run',
      'tool/openmetadata/ingestion/ingest_from_registry.dart',
      ...forwarded,
    ],
    mode: ProcessStartMode.inheritStdio,
    workingDirectory: _findRepoRoot().path,
  );
  exitCode = await process.exitCode;
}

Directory _findRepoRoot() {
  var dir = Directory.current;
  while (true) {
    if (File('${dir.path}/pubspec.yaml').existsSync() &&
        Directory('${dir.path}/tool/openmetadata').existsSync()) {
      return dir;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('Run from powercoach-studio repo root');
    }
    dir = parent;
  }
}
