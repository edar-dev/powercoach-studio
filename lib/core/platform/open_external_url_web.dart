import 'package:web/web.dart' as web;

/// Opens [url] in a new browser tab on web.
void openExternalUrl(String url) {
  web.window.open(url, '_blank');
}
