/// Non-web: persistent storage is not an issue for IndexedDB eviction.
Future<bool> requestPersistentStorage() async => false;

/// Non-web: treat storage as already persisted (no browser eviction risk).
Future<bool> isStoragePersisted() async => true;
