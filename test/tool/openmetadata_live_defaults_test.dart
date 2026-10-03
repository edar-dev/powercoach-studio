import 'package:flutter_test/flutter_test.dart';

import '../../tool/openmetadata/ingestion/om_live_defaults.dart';

void main() {
  test('OM 1.5.15 quickstart defaults use email login identity', () {
    expect(kOmDefaultEmail, 'admin@open-metadata.org');
    expect(kOmDefaultPassword, 'admin');
    expect(kOmDefaultBaseUrl, 'http://localhost:8585');
  });

  test('login API password is Base64 of plaintext', () {
    expect(encodeOmLoginPassword('admin'), 'YWRtaW4=');
    expect(encodeOmLoginPassword(''), '');
  });

  test('lineage PUT body uses entity UUIDs (not FQNs)', () {
    const fromId = '11111111-1111-1111-1111-111111111111';
    const toId = '22222222-2222-2222-2222-222222222222';
    final body = buildOmLineagePutBody(
      fromId: fromId,
      toId: toId,
      description: 'customerId: soft FK',
    );

    final edge = body['edge'] as Map<String, dynamic>;
    final from = edge['fromEntity'] as Map<String, dynamic>;
    final to = edge['toEntity'] as Map<String, dynamic>;
    expect(from['id'], fromId);
    expect(to['id'], toId);
    expect(from['type'], 'table');
    expect(to['type'], 'table');
    expect(from.containsKey('fqn'), isFalse);
    expect(to.containsKey('fqn'), isFalse);

    final details = edge['lineageDetails'] as Map<String, dynamic>;
    expect(details['source'], 'Manual');
    expect(details['description'], 'customerId: soft FK');
  });
}
