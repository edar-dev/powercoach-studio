/// Shared row contract for Supabase `public.coach_entities` (cloud SoT).
///
/// Aligned with `supabase/migrations/20261003200000_coach_entities.sql` and
/// Drift `LocalEntities` cache columns (camelCase locally; snake_case remote).
abstract final class CoachEntityRowContract {
  static const String remoteTable = 'public.coach_entities';

  /// Postgres / PostgREST column names (snake_case).
  static const List<String> remoteRowFields = <String>[
    'user_id',
    'type',
    'id',
    'scope_id',
    'payload',
    'updated_at',
    'deleted',
  ];

  /// Soft-delete column (boolean). Tombstones are kept so pull can replace cache.
  static const String softDeleteColumn = 'deleted';

  /// RLS: authenticated only; each policy uses `user_id = auth.uid()`.
  /// `anon` has no grants. App uses anon key + user JWT (never service role).
  static const String rlsNote =
      'authenticated; user_id = auth.uid(); anon revoked';

  /// Soft FKs live in JSONB `payload` (and nested planData); no SQL FKs.
  static const String softFkNote =
      'No SQL FKs; soft references live in payload JSONB '
      '(see SoftReference + data_quality scanner).';

  /// `type` CHECK values — must match [OfflineEntityType].name.
  /// Legacy `exerciseRecord` is excluded (removed from Drift schema v3).
  static const List<String> typeCheckValues = <String>[
    'customer',
    'workoutPlan',
    'measurement',
    'customExercise',
    'customerNote',
  ];
}
