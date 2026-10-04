import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/openmetadata/ingestion/om_catalog_payload.dart';

void main() {
  test('OM dry-run payload covers cloud SoT types, prefs, and customer lineage',
      () {
    final registry = jsonDecode(
      File('tool/openmetadata/fixtures/registry.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final sample = jsonDecode(
      File('tool/openmetadata/fixtures/sample_entities.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    final payload = buildOpenMetadataPayload(
      registry: registry,
      sampleEntities: sample,
    );

    expect(payload['schemaVersion'], 2);
    expect(payload['exportFormat'], 'powercoach_om_catalog_payload_v2');
    expect(payload['schema'], isA<Map<String, dynamic>>());
    expect(
      (payload['schema'] as Map)['name'],
      'cloud_sot',
    );

    final tableNames = (payload['tables'] as List)
        .cast<Map<String, dynamic>>()
        .map((t) => t['name']?.toString())
        .whereType<String>()
        .toSet();

    expect(
      tableNames,
      containsAll(<String>[
        'customer',
        'workoutPlan',
        'measurement',
        'customExercise',
        'customerNote',
        'userProfile',
        'pdfBrand',
        'userPreferences',
        'planData',
      ]),
    );

    final cloudTables = (payload['tables'] as List)
        .cast<Map<String, dynamic>>()
        .where((t) => t['locus'] == 'supabaseCoachEntities');
    expect(cloudTables.length, 5);
    expect(
      cloudTables.every((t) => t['cacheLocus'] == 'driftLocalEntities'),
      isTrue,
    );
    expect(
      cloudTables.every((t) => t['remoteTable'] == 'public.coach_entities'),
      isTrue,
    );

    final acceptance = payload['acceptance'] as Map<String, dynamic>;
    expect(acceptance['requiresCloudSotLocus'], 'supabaseCoachEntities');
    expect(acceptance['requiresCacheLocus'], 'driftLocalEntities');

    final edges =
        (payload['lineageEdges'] as List).cast<Map<String, dynamic>>();
    expect(
      edges.any(
        (e) =>
            e['fromEntity'] == 'customer' && e['toEntity'] == 'workoutPlan',
      ),
      isTrue,
      reason: 'Need customer → workoutPlan lineage',
    );
    expect(
      edges.any(
        (e) =>
            e['fromEntity'] == 'customer' && e['toEntity'] == 'measurement',
      ),
      isTrue,
      reason: 'Need customer → measurement lineage',
    );

    final sampleByTable =
        payload['sampleDataByTable'] as Map<String, dynamic>;
    expect(sampleByTable.keys, containsAll(tableNames));
    expect(
      ((sampleByTable['customer'] as Map)['rows'] as List),
      isNotEmpty,
    );
  });
}
