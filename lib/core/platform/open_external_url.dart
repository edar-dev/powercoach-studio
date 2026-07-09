import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Opens [url] in a new browser tab on web.
void openExternalUrl(String url) {
  if (!kIsWeb) return;
  web.window.open(url, '_blank');
}
