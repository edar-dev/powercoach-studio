import 'dart:js_interop';

import 'package:web/web.dart' as web;

final Map<void Function(), JSFunction> _listeners = {};

/// Registers [onUnload] for the browser `beforeunload` / `pagehide` events.
void registerWebUnloadHook(void Function() onUnload) {
  if (_listeners.containsKey(onUnload)) return;
  void handler(web.Event _) => onUnload();
  final jsHandler = handler.toJS;
  _listeners[onUnload] = jsHandler;
  web.window.addEventListener('beforeunload', jsHandler);
  web.window.addEventListener('pagehide', jsHandler);
}

/// Removes a previously registered unload hook.
void unregisterWebUnloadHook(void Function() onUnload) {
  final jsHandler = _listeners.remove(onUnload);
  if (jsHandler == null) return;
  web.window.removeEventListener('beforeunload', jsHandler);
  web.window.removeEventListener('pagehide', jsHandler);
}
