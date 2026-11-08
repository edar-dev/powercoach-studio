import 'web_online_status.dart';

/// Fallback when neither `dart:io` nor `dart:html` is available.
Future<bool> probeNetworkReachability() async => isNavigatorOnline();
