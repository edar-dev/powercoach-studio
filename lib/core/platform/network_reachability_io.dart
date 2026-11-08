import 'dart:async';
import 'dart:io';

/// Native: best-effort DNS lookup without adding `connectivity_plus`.
///
/// Does not change sync/write gates ([isNavigatorOnline]); used only for the
/// shell offline chip UX.
Future<bool> probeNetworkReachability() async {
  try {
    final results = await InternetAddress.lookup('example.com')
        .timeout(const Duration(seconds: 2));
    return results.isNotEmpty && results.first.rawAddress.isNotEmpty;
  } on SocketException {
    return false;
  } on TimeoutException {
    return false;
  } catch (_) {
    return false;
  }
}
