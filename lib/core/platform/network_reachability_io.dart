import 'dart:io';

/// Native: best-effort DNS lookup without adding `connectivity_plus`.
///
/// Does not change sync/write gates ([isNavigatorOnline]); used only for the
/// shell offline chip UX.
///
/// Avoid [Future.timeout]: its Timer is not cancelled when the widget disposes
/// and breaks Flutter widget tests (`!timersPending`).
Future<bool> probeNetworkReachability() async {
  try {
    final results = await InternetAddress.lookup('example.com');
    return results.isNotEmpty && results.first.rawAddress.isNotEmpty;
  } on SocketException {
    return false;
  } catch (_) {
    return false;
  }
}
