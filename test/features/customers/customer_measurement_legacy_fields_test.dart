import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_measurement.dart';

void main() {
  test('fromJson ignores legacy rich measurement fields', () {
    final measurement = CustomerMeasurement.fromJson(<String, dynamic>{
      'id': 'm1',
      'customerId': 'c1',
      'userId': 'u1',
      'measurementDate': '2026-06-01',
      'squat1RM': 120.0,
      'benchPress1RM': 80.0,
      'deadlift1RM': 140.0,
      'bodyFatPercent': 15.5,
      'muscleMassKg': 62.0,
      'notes': 'ok',
      // Legacy rich fields — must not crash or be re-emitted.
      'skinfolds': <String, dynamic>{'chest': 10, 'abdomen': 12},
      'bia': <String, dynamic>{'impedance': 500},
      'circumferences': <String, dynamic>{
        'waist': 80,
        'chest': 100,
        'arms': 35,
        'thighs': 55,
      },
      'waistCm': 80,
      'chestCm': 100,
      'armsCm': 35,
      'thighsCm': 55,
      'createdAt': '2026-06-01T10:00:00.000Z',
      'updatedAt': '2026-06-01T10:00:00.000Z',
      'rowVersion': 1,
    });

    expect(measurement.squat1RM, 120.0);
    expect(measurement.bodyFatPercent, 15.5);
    expect(measurement.muscleMassKg, 62.0);
    expect(measurement.notes, 'ok');

    final body = measurement.toCreateBody();
    expect(body.containsKey('skinfolds'), isFalse);
    expect(body.containsKey('bia'), isFalse);
    expect(body.containsKey('circumferences'), isFalse);
    expect(body.containsKey('waistCm'), isFalse);
    expect(body.containsKey('chestCm'), isFalse);
    expect(body.containsKey('armsCm'), isFalse);
    expect(body.containsKey('thighsCm'), isFalse);
    expect(body['squat1RM'], 120.0);
    expect(body['bodyFatPercent'], 15.5);
  });

  test('toCreateBody never writes rich measurement fields', () {
    final measurement = CustomerMeasurement(
      id: 'm2',
      customerId: 'c1',
      userId: 'u1',
      measurementDate: DateTime.utc(2026, 6, 2),
      squat1RM: 100,
      createdAt: DateTime.utc(2026, 6, 2),
      updatedAt: DateTime.utc(2026, 6, 2),
    );
    final body = measurement.toCreateBody();
    for (final key in [
      'skinfolds',
      'bia',
      'circumferences',
      'waistCm',
      'chestCm',
      'armsCm',
      'thighsCm',
    ]) {
      expect(body.containsKey(key), isFalse, reason: key);
    }
  });
}
