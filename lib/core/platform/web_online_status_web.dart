import 'package:web/web.dart' as web;

/// Returns [navigator.onLine] for cloud snapshot / sync gates.
bool isNavigatorOnline() => web.window.navigator.onLine;
