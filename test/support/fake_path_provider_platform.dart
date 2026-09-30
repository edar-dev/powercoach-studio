import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// Drift native storage needs both temporary and documents paths in tests.
class FakePathProviderPlatform extends PathProviderPlatform {
  FakePathProviderPlatform({this.prefix = 'powercoach_test_'});

  final String prefix;

  String _createTempDir() {
    return Directory.systemTemp.createTempSync(prefix).path;
  }

  @override
  Future<String?> getTemporaryPath() async => _createTempDir();

  @override
  Future<String?> getApplicationDocumentsPath() async => _createTempDir();
}

/// Stable docs/tmp paths for close/reopen Drift round-trip tests.
///
/// Unlike [FakePathProviderPlatform], paths do not change across calls so the
/// same SQLite file is reused after [OfflineLocalStore.debugCloseForTest].
class StableFakePathProvider extends PathProviderPlatform {
  StableFakePathProvider({String prefix = 'powercoach_stable_'})
      : temporaryPath = Directory.systemTemp.createTempSync('${prefix}tmp_').path,
        documentsPath =
            Directory.systemTemp.createTempSync('${prefix}docs_').path;

  final String temporaryPath;
  final String documentsPath;

  @override
  Future<String?> getTemporaryPath() async => temporaryPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => documentsPath;
}
