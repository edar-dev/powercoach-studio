import 'dart:io';

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
