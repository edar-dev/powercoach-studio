import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/customers/data/models/customer.dart';

void main() {
  test('Customer.toUpdateBody includes expectedRowVersion', () {
    final t = DateTime.utc(2020);
    final c = Customer(
      id: 'a',
      userId: 'u',
      name: 'N',
      createdAt: t,
      updatedAt: t,
      rowVersion: 7,
    );
    final body = c.toUpdateBody();
    expect(body['expectedRowVersion'], 7);
  });

  test('Customer.fromJson parses rowVersion', () {
    final c = Customer.fromJson({
      'id': 'x',
      'userId': 'y',
      'name': 'Z',
      'createdAt': '2020-01-01T00:00:00Z',
      'updatedAt': '2020-01-02T00:00:00Z',
      'rowVersion': 3,
    });
    expect(c.rowVersion, 3);
  });
}
