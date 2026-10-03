/// Where a catalogued data bucket is persisted.
enum DataStorageLocus {
  /// Row in Drift `LocalEntities` (`payloadJson` + metadata columns).
  driftLocalEntities,

  /// SharedPreferences string / JSON blob.
  sharedPreferences,

  /// Device filesystem (e.g. PDF brand logo bytes on native).
  fileSystem,

  /// Nested JSON embedded inside another entity payload (e.g. `planData`).
  nestedJson,
}
