/// In-memory cache for API GET responses with TTL and prefix invalidation.
class ApiCache {
  ApiCache({
    this.defaultTtl = const Duration(minutes: 5),
    this.maxEntries = 100,
  });

  final Duration defaultTtl;
  final int maxEntries;

  final Map<String, _Entry> _store = {};

  /// Returns cached data if present and not expired; otherwise null.
  dynamic get(String key) {
    final entry = _store[key];
    if (entry == null) {
      return null;
    }
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _store.remove(key);
      return null;
    }
    return entry.data;
  }

  void set(String key, dynamic data, {Duration? ttl}) {
    if (_store.length >= maxEntries && !_store.containsKey(key)) {
      _evictOldest();
    }
    final expiresAt = DateTime.now().add(ttl ?? defaultTtl);
    _store[key] = _Entry(data: data, expiresAt: expiresAt);
  }

  void invalidate(String key) {
    _store.remove(key);
  }

  /// Removes all entries whose key starts with [prefix] (e.g. "/api/customers").
  void invalidatePrefix(String prefix) {
    final toRemove = _store.keys.where((k) => k.startsWith(prefix)).toList();
    for (final k in toRemove) {
      _store.remove(k);
    }
  }

  void clear() {
    _store.clear();
  }

  void _evictOldest() {
    if (_store.isEmpty) {
      return;
    }
    String? oldestKey;
    DateTime? oldest;
    for (final e in _store.entries) {
      if (oldest == null || e.value.expiresAt.isBefore(oldest)) {
        oldest = e.value.expiresAt;
        oldestKey = e.key;
      }
    }
    if (oldestKey != null) {
      _store.remove(oldestKey);
    }
  }
}

class _Entry {
  _Entry({required this.data, required this.expiresAt});
  final dynamic data;
  final DateTime expiresAt;
}
