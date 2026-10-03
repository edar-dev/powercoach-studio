import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/openmetadata/ingestion/om_catalog_payload.dart';

void main() {
  test('OM dry-run payload covers Drift types, prefs, and customer lineage', () {
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
  });
}
