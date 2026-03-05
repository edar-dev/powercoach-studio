import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_cache.dart';

/// Wraps [ApiCache] and persists GET responses to SharedPreferences for offline use.
/// Only keys matching [persistKeyPrefix] (e.g. "/api/customers") are persisted; max [maxPersistedKeys].
class PersistentApiCache implements IApiCache {
  PersistentApiCache({
    required this.inner,
    this.persistKeyPrefix = '/api/customers',
    this.maxPersistedKeys = 30,
  });

  static const String _prefsPrefix = 'api_cache_';

  final ApiCache inner;
  final String persistKeyPrefix;
  final int maxPersistedKeys;

  bool _shouldPersist(String key) =>
      key.startsWith(persistKeyPrefix) && key.length < 200;

  /// Call at app startup to restore persisted entries into [inner] (sync get will then hit memory).
  static Future<void> restore(ApiCache inner, {String persistKeyPrefix = '/api/customers', int maxPersistedKeys = 30}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_prefsPrefix)).toList();
      for (final k in keys) {
        final raw = prefs.getString(k);
        if (raw == null) continue;
        final keyName = k.substring(_prefsPrefix.length);
        if (!keyName.startsWith(persistKeyPrefix)) continue;
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final data = map['data'];
        final expiresAt = DateTime.parse(map['expiresAt'] as String);
        if (DateTime.now().isAfter(expiresAt)) {
          await prefs.remove(k);
          continue;
        }
        inner.set(keyName, data, ttl: expiresAt.difference(DateTime.now()));
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _loadFromPrefs(String key) async {
    if (!_shouldPersist(key)) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefsPrefix$key');
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final data = map['data'];
      final expiresAt = DateTime.parse(map['expiresAt'] as String);
      if (DateTime.now().isAfter(expiresAt)) {
        await prefs.remove('$_prefsPrefix$key');
        return;
      }
      inner.set(key, data, ttl: expiresAt.difference(DateTime.now()));
    } catch (_) {
      // ignore decode/prefs errors
    }
  }

  @override
  dynamic get(String key) {
    final value = inner.get(key);
    if (value != null) return value;
    return null;
  }

  /// Returns cached data; if in-memory miss and [key] is persistable, returns null (caller can await [getAsync] for pref load).
  Future<dynamic> getAsync(String key) async {
    var value = inner.get(key);
    if (value != null) return value;
    if (_shouldPersist(key)) {
      await _loadFromPrefs(key);
      value = inner.get(key);
    }
    return value;
  }

  @override
  void set(String key, dynamic data, {Duration? ttl}) {
    inner.set(key, data, ttl: ttl);
    if (!_shouldPersist(key)) return;
    _persist(key, data, ttl ?? inner.defaultTtl);
  }

  Future<void> _persist(String key, dynamic data, Duration ttl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_prefsPrefix)).toList();
      if (keys.length >= maxPersistedKeys && !keys.contains('$_prefsPrefix$key')) {
        final toRemove = keys.take(keys.length - maxPersistedKeys + 1);
        for (final k in toRemove) {
          await prefs.remove(k);
        }
      }
      final expiresAt = DateTime.now().add(ttl);
      await prefs.setString('$_prefsPrefix$key', jsonEncode({
        'data': data,
        'expiresAt': expiresAt.toIso8601String(),
      }));
    } catch (_) {
      // ignore
    }
  }

  void invalidate(String key) {
    inner.invalidate(key);
    if (!_shouldPersist(key)) return;
    SharedPreferences.getInstance().then((prefs) => prefs.remove('$_prefsPrefix$key'));
  }

  @override
  void invalidatePrefix(String prefix) {
    inner.invalidatePrefix(prefix);
    SharedPreferences.getInstance().then((prefs) {
      final toRemove = prefs.getKeys().where((k) => k.startsWith(_prefsPrefix) && k.substring(_prefsPrefix.length).startsWith(prefix));
      for (final k in toRemove) {
        prefs.remove(k);
      }
    });
  }

  void clear() {
    inner.clear();
    SharedPreferences.getInstance().then((prefs) {
      final toRemove = prefs.getKeys().where((k) => k.startsWith(_prefsPrefix));
      for (final k in toRemove) {
        prefs.remove(k);
      }
    });
  }
}
