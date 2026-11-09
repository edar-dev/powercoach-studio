import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// Drift / OfflineLocalStore need documents + temp paths under Live binding.
class FakePathProviderPlatform extends PathProviderPlatform {
  FakePathProviderPlatform({this.prefix = 'powercoach_integration_'});

  final String prefix;

  String _createTempDir() {
    return Directory.systemTemp.createTempSync(prefix).path;
  }

  @override
  Future<String?> getTemporaryPath() async => _createTempDir();

  @override
  Future<String?> getApplicationDocumentsPath() async => _createTempDir();
}
