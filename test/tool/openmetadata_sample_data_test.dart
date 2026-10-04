import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/openmetadata/ingestion/om_catalog_payload.dart';
import '../../tool/openmetadata/ingestion/om_sample_data.dart';

void main() {
  late Map<String, dynamic> registry;
  late Map<String, dynamic> sample;

  setUpAll(() {
    registry = jsonDecode(
      File('tool/openmetadata/fixtures/registry.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    sample = jsonDecode(
      File('tool/openmetadata/fixtures/sample_entities.json').readAsStringSync(),
    ) as Map<String, dynamic>;
  });

  test('sample data covers every registry catalog table', () {
    final byTable = buildSampleDataByTable(
      registry: registry,
      sampleEntities: sample,
    );
    final catalogIds = (registry['entries'] as List)
        .cast<Map<String, dynamic>>()
        .map((e) => e['catalogId']?.toString())
        .whereType<String>()
        .toSet();

    expect(byTable.keys.toSet(), catalogIds);

    for (final id in <String>[
      'customer',
      'workoutPlan',
      'measurement',
      'customExercise',
      'customerNote',
      'planData',
      'userProfile',
      'pdfBrand',
      'userPreferences',
    ]) {
      final tableData = byTable[id]!;
      final columns = (tableData['columns'] as List).cast<String>();
      final rows = tableData['rows'] as List;
      expect(columns, isNotEmpty, reason: id);
      expect(rows, isNotEmpty, reason: id);
      final first = rows.first as List;
      expect(first.length, columns.length, reason: id);
    }

    expect((byTable['customer']!['rows'] as List).length, greaterThanOrEqualTo(2));
    expect(
      (byTable['workoutPlan']!['rows'] as List).length,
      greaterThanOrEqualTo(2),
    );
  });

  test('dry-run catalog payload embeds sampleDataByTable', () {
    final payload = buildOpenMetadataPayload(
      registry: registry,
      sampleEntities: sample,
    );
    final sampleByTable =
        payload['sampleDataByTable'] as Map<String, dynamic>;
    expect(sampleByTable.length, greaterThanOrEqualTo(11));
    final customer = sampleByTable['customer'] as Map<String, dynamic>;
    expect(customer['columns'], contains('name'));
    expect((customer['rows'] as List).first, contains('Ada Client'));
  });

  test('buildOmTableData stringifies cells for OM 1.5.15 TableData', () {
    final data = buildOmTableData(
      columns: <String>['id', 'flag', 'n'],
      rows: <List<Object?>>[
        <Object?>['a', true, 3],
        <Object?>[null, false, 0],
      ],
    );
    expect(data['columns'], <String>['id', 'flag', 'n']);
    expect(data['rows'], <List<String>>[
      <String>['a', 'true', '3'],
      <String>['', 'false', '0'],
    ]);
  });
}
