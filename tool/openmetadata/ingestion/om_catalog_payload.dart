/// Builds an OpenMetadata-oriented payload from the in-repo catalog registry.
///
/// Used by [ingest_from_registry.dart] (CLI) and unit tests. No network I/O.
Map<String, dynamic> buildOpenMetadataPayload({
  required Map<String, dynamic> registry,
  required Map<String, dynamic> sampleEntities,
}) {
  final entries = (registry['entries'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  final tables = <Map<String, dynamic>>[];
  for (final entry in entries) {
    final catalogId = entry['catalogId']?.toString() ?? '';
    final fields = (entry['payloadFields'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();
    tables.add(<String, dynamic>{
      'name': catalogId,
      'displayName': entry['displayName'],
      'description': entry['summary'],
      'locus': entry['locus'],
      'cacheLocus': entry['cacheLocus'],
      'driftType': entry['driftType'],
      'remoteTable': entry['remoteTable'],
      'remoteRowFields': entry['remoteRowFields'],
      'softDelete': entry['softDelete'],
      'rlsNote': entry['rlsNote'],
      'includedInBackup': entry['includedInBackup'],
      'columns': fields
          .map(
            (f) => <String, dynamic>{
              'name': f,
              'dataType': 'STRING',
              'description': 'Catalog field summary for $catalogId.$f',
            },
          )
          .toList(),
      'references': entry['references'] ?? const <dynamic>[],
    });
  }

  final lineageEdges = <Map<String, dynamic>>[];
  for (final entry in entries) {
    final fromId = entry['catalogId']?.toString() ?? '';
    final refs = (entry['references'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    for (final ref in refs) {
      // Soft FK: child.field → parent. OM edge: upstream parent → downstream child.
      lineageEdges.add(<String, dynamic>{
        'fromEntity': ref['targetCatalogId'],
        'toEntity': fromId,
        'fieldPath': ref['fieldPath'],
        'description': ref['description'] ?? '',
        'source': 'registry.softReference',
      });
    }
  }

  void ensureEdge(String from, String to, String fieldPath) {
    final exists = lineageEdges.any(
      (e) => e['fromEntity'] == from && e['toEntity'] == to,
    );
    if (!exists) {
      lineageEdges.add(<String, dynamic>{
        'fromEntity': from,
        'toEntity': to,
        'fieldPath': fieldPath,
        'description': 'Required spike lineage edge',
        'source': 'spike.acceptance',
      });
    }
  }

  ensureEdge('customer', 'workoutPlan', 'customerId');
  ensureEdge('customer', 'measurement', 'customerId');

  final expected = (sampleEntities['expectedLineageEdges'] as List<dynamic>? ??
          const [])
      .cast<Map<String, dynamic>>();

  final coachEntities = registry['coachEntities'] as Map<String, dynamic>? ??
      const <String, dynamic>{};

  return <String, dynamic>{
    'schemaVersion': 2,
    'exportFormat': 'powercoach_om_catalog_payload_v2',
    'service': <String, dynamic>{
      'name': 'powercoach_cloud',
      'displayName': 'PowerCoach Cloud SoT (spike)',
      'serviceType': 'CustomDatabase',
      'description':
          'Document-oriented catalog: Supabase coach_entities (SoT) + '
          'Drift cache + SharedPreferences, mirrored from Dart registry.',
    },
    'database': <String, dynamic>{
      'name': 'powercoach_studio',
      'description':
          'Logical DB for public.coach_entities (SoT), Drift LocalEntities '
          'cache, and prefs buckets',
    },
    'schema': <String, dynamic>{
      'name': 'cloud_sot',
      'description':
          'Soft-FK coach entity types (cloud SoT) and local prefs buckets',
    },
    'coachEntities': coachEntities,
    'tables': tables,
    'lineageEdges': lineageEdges,
    'sampleEntities': sampleEntities['entities'] ?? const <dynamic>[],
    'expectedLineageEdges': expected,
    'acceptance': <String, dynamic>{
      'requiresCoachEntityTypes': <String>[
        'customer',
        'workoutPlan',
        'measurement',
        'customExercise',
        'customerNote',
      ],
      // Backward-compatible alias for older spike checks.
      'requiresDriftTypes': <String>[
        'customer',
        'workoutPlan',
        'measurement',
        'customExercise',
        'customerNote',
      ],
      'requiresPrefsBuckets': <String>[
        'userProfile',
        'pdfBrand',
        'userPreferences',
      ],
      'requiresLineage': <List<String>>[
        <String>['customer', 'workoutPlan'],
        <String>['customer', 'measurement'],
      ],
      'requiresCloudSotLocus': 'supabaseCoachEntities',
      'requiresCacheLocus': 'driftLocalEntities',
    },
  };
}
