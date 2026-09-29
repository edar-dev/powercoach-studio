import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Requests [navigator.storage.persist] so the browser is less likely to
/// evict IndexedDB / Cache Storage under pressure.
Future<bool> requestPersistentStorage() async {
  try {
    final granted =
        (await web.window.navigator.storage.persist().toDart).toDart;
    debugPrint('web_storage_persistence: persist() => $granted');
    return granted;
  } catch (e, stack) {
    debugPrint('web_storage_persistence: persist() failed: $e\n$stack');
    return false;
  }
}

/// Returns whether the origin currently has persistent storage.
Future<bool> isStoragePersisted() async {
  try {
    final persisted =
        (await web.window.navigator.storage.persisted().toDart).toDart;
    debugPrint('web_storage_persistence: persisted() => $persisted');
    return persisted;
  } catch (e, stack) {
    debugPrint('web_storage_persistence: persisted() failed: $e\n$stack');
    return false;
  }
}
