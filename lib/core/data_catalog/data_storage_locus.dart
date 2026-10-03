/// Where a catalogued data bucket is persisted.
enum DataStorageLocus {
  /// Cloud source of truth: Supabase `public.coach_entities` (JSONB row).
  ///
  /// Drift [driftLocalEntities] is the per-device cache for these types.
  supabaseCoachEntities,

  /// Row in Drift `LocalEntities` (`payloadJson` + metadata columns).
  ///
  /// For [OfflineEntityType] business entities this is a **cache** replaced
  /// per type on pull from [supabaseCoachEntities]. Prefs never use this.
  driftLocalEntities,

  /// SharedPreferences string / JSON blob.
  sharedPreferences,

  /// Device filesystem (e.g. PDF brand logo bytes on native).
  fileSystem,

  /// Nested JSON embedded inside another entity payload (e.g. `planData`).
  nestedJson,
}
