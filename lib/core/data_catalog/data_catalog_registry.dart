import '../sync/offline_models.dart';
import 'data_storage_locus.dart';
import 'entity_catalog_entry.dart';
import 'soft_reference.dart';

/// In-repo source of truth for local-first entity shapes and soft FKs.
///
/// OpenMetadata ingestion and data-quality scanners consume this registry;
/// they must not invent relationship rules outside of these entries.
abstract final class DataCatalogRegistry {
  static const String customer = 'customer';
  static const String workoutPlan = 'workoutPlan';
  static const String measurement = 'measurement';
  static const String customExercise = 'customExercise';
  static const String customerNote = 'customerNote';
  static const String planData = 'planData';
  static const String userProfile = 'userProfile';
  static const String pdfBrand = 'pdfBrand';
  static const String userPreferences = 'userPreferences';
  static const String workoutDraft = 'workoutDraft';
  static const String cloudBackupMeta = 'cloudBackupMeta';

  /// All catalogued buckets (Drift + prefs + nested JSON).
  static final List<EntityCatalogEntry> entries = List.unmodifiable(<EntityCatalogEntry>[
    const EntityCatalogEntry(
      catalogId: customer,
      displayName: 'Customer',
      driftType: OfflineEntityType.customer,
      locus: DataStorageLocus.driftLocalEntities,
      summary:
          'Coach client record. scopeId is the authenticated coach userId.',
      scopeIdPattern: 'userId',
      payloadFields: <String>[
        'id',
        'userId',
        'name',
        'email',
        'phone',
        'dateOfBirth',
        'heightCm',
        'weightKg',
        'notes',
        'goals',
        'pdfHeader',
        'useCustomPdfHeader',
        'isFavorite',
        'isArchived',
        'lastPlanUpdateDate',
        'createdAt',
        'updatedAt',
        'rowVersion',
      ],
      includedInBackup: true,
      backupKey: 'entities',
      sourcePath: 'lib/features/customers/data/models/customer.dart',
    ),
    const EntityCatalogEntry(
      catalogId: workoutPlan,
      displayName: 'Workout plan',
      driftType: OfflineEntityType.workoutPlan,
      locus: DataStorageLocus.driftLocalEntities,
      summary:
          'Client workout plan. scopeId is customerId. Nested planData holds '
          'weeks/days/exercises and session diary.',
      scopeIdPattern: 'customerId',
      payloadFields: <String>[
        'id',
        'customerId',
        'userId',
        'name',
        'theme',
        'initialWeekNumber',
        'planData',
        'pdfHeader',
        'useCustomPdfHeader',
        'phase',
        'tags',
        'notes',
        'createdAt',
        'updatedAt',
        'rowVersion',
      ],
      references: <SoftReference>[
        SoftReference(
          fieldPath: 'customerId',
          targetCatalogId: customer,
          optional: false,
          description: 'Owning customer id (also mirrored in scopeId).',
        ),
      ],
      includedInBackup: true,
      backupKey: 'entities',
      sourcePath: 'lib/features/workouts/data/workout_plan_api_model.dart',
    ),
    const EntityCatalogEntry(
      catalogId: measurement,
      displayName: 'Measurement',
      driftType: OfflineEntityType.measurement,
      locus: DataStorageLocus.driftLocalEntities,
      summary: 'Client body / strength measurement. scopeId is customerId.',
      scopeIdPattern: 'customerId',
      payloadFields: <String>[
        'id',
        'customerId',
        'userId',
        'measurementDate',
        'squat1RM',
        'benchPress1RM',
        'deadlift1RM',
        'bodyFatPercent',
        'muscleMassKg',
        'notes',
        'createdAt',
        'updatedAt',
        'rowVersion',
      ],
      references: <SoftReference>[
        SoftReference(
          fieldPath: 'customerId',
          targetCatalogId: customer,
          optional: false,
          description: 'Owning customer id (also mirrored in scopeId).',
        ),
      ],
      includedInBackup: true,
      backupKey: 'entities',
      sourcePath: 'lib/features/customers/data/models/customer_measurement.dart',
    ),
    const EntityCatalogEntry(
      catalogId: customExercise,
      displayName: 'Custom exercise',
      driftType: OfflineEntityType.customExercise,
      locus: DataStorageLocus.driftLocalEntities,
      summary:
          'Coach exercise library node. scopeId is the constant "library". '
          'Optional parentId builds a folder tree.',
      scopeIdPattern: 'library',
      payloadFields: <String>[
        'id',
        'userId',
        'name',
        'description',
        'parentId',
        'sortOrder',
        'isMobility',
        'catalogSource',
        'createdAt',
        'updatedAt',
        'rowVersion',
      ],
      references: <SoftReference>[
        SoftReference(
          fieldPath: 'parentId',
          targetCatalogId: customExercise,
          optional: true,
          description: 'Self-referential library parent (orphan / cycle checks).',
        ),
      ],
      includedInBackup: true,
      backupKey: 'entities',
      sourcePath: 'lib/features/exercise_library/data/custom_exercise_item.dart',
    ),
    const EntityCatalogEntry(
      catalogId: customerNote,
      displayName: 'Customer note',
      driftType: OfflineEntityType.customerNote,
      locus: DataStorageLocus.driftLocalEntities,
      summary: 'Per-message coaching note for a client. scopeId is customerId.',
      scopeIdPattern: 'customerId',
      payloadFields: <String>[
        'id',
        'customerId',
        'authorUserId',
        'body',
        'createdAt',
        'readAt',
        'attachmentRef',
      ],
      references: <SoftReference>[
        SoftReference(
          fieldPath: 'customerId',
          targetCatalogId: customer,
          optional: false,
          description: 'Owning customer id (also mirrored in scopeId).',
        ),
      ],
      includedInBackup: true,
      backupKey: 'entities',
      sourcePath: 'lib/features/customers/domain/models/client_note_message.dart',
    ),
    const EntityCatalogEntry(
      catalogId: planData,
      displayName: 'Plan data (nested)',
      locus: DataStorageLocus.nestedJson,
      summary:
          'JSON string embedded in workoutPlan.planData: phases/weeks/days/'
          'exercises, mobility, and sessionExecutions diary.',
      payloadFields: <String>[
        'name',
        'mobilitySections',
        'mobilityItems',
        'phases',
        'weeks',
        'startDate',
        'endDate',
        'currentWeek',
        'includesMobilityTab',
        'sessionCompletionByKey',
        'sessionSkippedByKey',
        'sessionOverrides',
        'sessionExecutions',
        'archivedAt',
        'completedAt',
      ],
      references: <SoftReference>[
        SoftReference(
          fieldPath: 'mobilityItems[].customExerciseId',
          targetCatalogId: customExercise,
          optional: true,
          description: 'Mobility item → library exercise.',
        ),
        SoftReference(
          fieldPath: 'exercises[].customExerciseId',
          targetCatalogId: customExercise,
          optional: true,
          description: 'Training block exercise → library exercise.',
        ),
        SoftReference(
          fieldPath: 'sessionExecutions[].exercises[].customExerciseId',
          targetCatalogId: customExercise,
          optional: true,
          description: 'Executed log exercise → library exercise.',
        ),
      ],
      includedInBackup: true,
      backupKey: 'entities',
      sourcePath: 'lib/features/workouts/domain/workout_routine_json_codec.dart',
    ),
    const EntityCatalogEntry(
      catalogId: userProfile,
      displayName: 'Coach user profile',
      locus: DataStorageLocus.sharedPreferences,
      summary: 'Local coach profile fields (not Supabase profiles table CRUD).',
      payloadFields: <String>[
        'displayName',
        'phone',
        'bio',
        'avatarUrl',
        'website',
        'subscriptionPlan',
      ],
      includedInBackup: true,
      backupKey: 'localUserProfile',
      prefsKeyPattern: 'local_user_profile_v1:\$userId',
      sourcePath: 'lib/core/storage/local_user_profile_store.dart',
    ),
    const EntityCatalogEntry(
      catalogId: pdfBrand,
      displayName: 'PDF brand kit',
      locus: DataStorageLocus.sharedPreferences,
      summary:
          'PDF studio branding + logo path/bytes. Device-local; not included '
          'in the user backup envelope.',
      payloadFields: <String>[
        'studioName',
        'accentColorArgb',
        'disclaimer',
        'hidePowerCoachBranding',
        'logoRelativePath',
      ],
      includedInBackup: false,
      prefsKeyPattern: 'pdf_brand_v1:\$userId',
      sourcePath: 'lib/core/pdf/pdf_brand_store.dart',
    ),
    const EntityCatalogEntry(
      catalogId: userPreferences,
      displayName: 'User preferences',
      locus: DataStorageLocus.sharedPreferences,
      summary:
          'Settings + pinned/recent exercise ids exported under backup '
          '`preferences`.',
      payloadFields: <String>[
        'settings_notifications_enabled',
        'app_locale_code',
        'settings_calendar_reminders_enabled',
        'settings_calendar_reminder_lead_hours',
        'workout_builder_compact_add_v1',
        'workout_builder_include_mobility_default_v1',
        'pinned_exercise_ids_json_v1',
        'recent_exercise_ids_json_v1',
      ],
      references: <SoftReference>[
        SoftReference(
          fieldPath: 'pinned_exercise_ids_json_v1[]',
          targetCatalogId: customExercise,
          optional: true,
          description: 'Pinned library exercise ids.',
        ),
        SoftReference(
          fieldPath: 'recent_exercise_ids_json_v1[]',
          targetCatalogId: customExercise,
          optional: true,
          description: 'Recent library exercise ids.',
        ),
      ],
      includedInBackup: true,
      backupKey: 'preferences',
      prefsKeyPattern: 'see SettingsPrefsKeys + pin/recent stores',
      sourcePath: 'lib/features/settings/data/user_preferences_repository.dart',
    ),
    const EntityCatalogEntry(
      catalogId: workoutDraft,
      displayName: 'Workout builder draft',
      locus: DataStorageLocus.sharedPreferences,
      summary: 'In-progress workout builder draft. Not part of backup export.',
      payloadFields: <String>['workout_routine_draft'],
      includedInBackup: false,
      prefsKeyPattern: 'workout_routine_draft',
      sourcePath: 'lib/features/workouts/data/workout_draft_store.dart',
    ),
    const EntityCatalogEntry(
      catalogId: cloudBackupMeta,
      displayName: 'Cloud backup metadata',
      locus: DataStorageLocus.sharedPreferences,
      summary:
          'Auto-snapshot / last-sync timestamps for cloud backup UX. Not part '
          'of the backup entity envelope.',
      payloadFields: <String>[
        'auto_cloud_snapshot_*',
        'last_cloud_sync_at_v1_\$userId',
        'backup_last_successful_at_v1_\$userId',
      ],
      includedInBackup: false,
      prefsKeyPattern: 'auto_cloud_snapshot_* / backup_last_successful_at_v1_*',
      sourcePath: 'lib/core/backup/auto_cloud_snapshot_store.dart',
    ),
  ]);

  /// Drift entity entries only (one per [OfflineEntityType]).
  static Iterable<EntityCatalogEntry> get driftEntries =>
      entries.where((e) => e.driftType != null);

  /// Lookup by [EntityCatalogEntry.catalogId].
  static EntityCatalogEntry? byCatalogId(String catalogId) {
    for (final entry in entries) {
      if (entry.catalogId == catalogId) return entry;
    }
    return null;
  }

  /// Lookup by Drift [OfflineEntityType].
  static EntityCatalogEntry? byDriftType(OfflineEntityType type) {
    for (final entry in entries) {
      if (entry.driftType == type) return entry;
    }
    return null;
  }

  /// Soft references whose [SoftReference.targetCatalogId] matches [catalogId],
  /// or all references when [catalogId] is null.
  static List<SoftReference> softReferences({String? fromCatalogId}) {
    final out = <SoftReference>[];
    for (final entry in entries) {
      if (fromCatalogId != null && entry.catalogId != fromCatalogId) continue;
      out.addAll(entry.references);
    }
    return List.unmodifiable(out);
  }

  /// JSON document for OpenMetadata / tooling ingestion.
  static Map<String, dynamic> toJsonDocument() => <String, dynamic>{
        'schemaVersion': 1,
        'exportFormat': 'powercoach_data_catalog_v1',
        'entries': entries.map((e) => e.toJson()).toList(growable: false),
      };
}
