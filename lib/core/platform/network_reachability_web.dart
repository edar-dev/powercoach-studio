import 'web_online_status.dart';

/// Web: trust [navigator.onLine] (same as sync gates).
Future<bool> probeNetworkReachability() async => isNavigatorOnline();
