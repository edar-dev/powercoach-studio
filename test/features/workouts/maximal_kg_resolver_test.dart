import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_measurement.dart';
import 'package:powercoach_studio/features/workouts/domain/maximal_kg_resolver.dart';
import 'package:powercoach_studio/features/workouts/domain/maximal_ref.dart';

CustomerMeasurement _m({
  required String id,
  required DateTime date,
  DateTime? updatedAt,
  double? squat,
  double? bench,
  double? deadlift,
}) {
  final now = updatedAt ?? date;
  return CustomerMeasurement(
    id: id,
    customerId: 'c1',
    userId: 'u1',
    measurementDate: date,
    squat1RM: squat,
    benchPress1RM: bench,
    deadlift1RM: deadlift,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('MaximalKgResolver', () {
    test('null ref returns null', () {
      expect(
        MaximalKgResolver.resolve(
          ref: null,
          measurements: [
            _m(id: '1', date: DateTime(2026, 1, 1), bench: 100),
          ],
        ),
        isNull,
      );
    });

    test('default mode is massimo storico', () {
      expect(
        MaximalKgResolver.defaultMode,
        MaximalResolveMode.massimoStorico,
      );
    });

    test('massimo storico picks max bench across history', () {
      final measurements = [
        _m(id: '1', date: DateTime(2026, 1, 1), bench: 90),
        _m(id: '2', date: DateTime(2026, 3, 1), bench: 100),
        _m(id: '3', date: DateTime(2026, 6, 1), bench: 95),
      ];
      final kg = MaximalKgResolver.resolve(
        ref: const MaximalRef.measurement(lift: MaximalLift.bench),
        measurements: measurements,
      );
      expect(kg, 100);
    });

    test('ultimo picks latest by measurementDate', () {
      final measurements = [
        _m(id: '1', date: DateTime(2026, 1, 1), bench: 90),
        _m(id: '2', date: DateTime(2026, 3, 1), bench: 100),
        _m(id: '3', date: DateTime(2026, 6, 1), bench: 95),
      ];
      final kg = MaximalKgResolver.resolve(
        ref: const MaximalRef.measurement(lift: MaximalLift.bench),
        measurements: measurements,
        mode: MaximalResolveMode.ultimo,
      );
      expect(kg, 95);
    });

    test('ultimo ties on date use updatedAt', () {
      final day = DateTime(2026, 6, 1);
      final measurements = [
        _m(
          id: '1',
          date: day,
          updatedAt: DateTime(2026, 6, 1, 8),
          squat: 140,
        ),
        _m(
          id: '2',
          date: day,
          updatedAt: DateTime(2026, 6, 1, 18),
          squat: 150,
        ),
      ];
      final kg = MaximalKgResolver.resolve(
        ref: const MaximalRef.measurement(lift: MaximalLift.squat),
        measurements: measurements,
        mode: MaximalResolveMode.ultimo,
      );
      expect(kg, 150);
    });

    test('ignores measurements with null lift value', () {
      final measurements = [
        _m(id: '1', date: DateTime(2026, 1, 1), bench: null, squat: 200),
        _m(id: '2', date: DateTime(2026, 2, 1), bench: 80),
      ];
      final kg = MaximalKgResolver.resolve(
        ref: const MaximalRef.measurement(lift: MaximalLift.bench),
        measurements: measurements,
        mode: MaximalResolveMode.ultimo,
      );
      expect(kg, 80);
    });

    test('returns null when no non-null lift values exist', () {
      final kg = MaximalKgResolver.resolve(
        ref: const MaximalRef.measurement(lift: MaximalLift.deadlift),
        measurements: [
          _m(id: '1', date: DateTime(2026, 1, 1), bench: 100),
        ],
      );
      expect(kg, isNull);
    });

    test('custom resolves by id', () {
      final kg = MaximalKgResolver.resolve(
        ref: const MaximalRef.custom(maximalId: 'm1'),
        measurements: const [],
        customs: const [
          MaximalCustomKg(id: 'm1', weightKg: 60),
          MaximalCustomKg(id: 'm2', weightKg: 70),
        ],
      );
      expect(kg, 60);
    });

    test('custom missing id returns null', () {
      final kg = MaximalKgResolver.resolve(
        ref: const MaximalRef.custom(maximalId: 'missing'),
        measurements: const [],
        customs: const [MaximalCustomKg(id: 'm1', weightKg: 60)],
      );
      expect(kg, isNull);
    });

    test('countLiftValues counts non-null history for toggle', () {
      final measurements = [
        _m(id: '1', date: DateTime(2026, 1, 1), bench: 90),
        _m(id: '2', date: DateTime(2026, 2, 1), bench: null),
        _m(id: '3', date: DateTime(2026, 3, 1), bench: 100),
      ];
      expect(
        MaximalKgResolver.countLiftValues(
          measurements: measurements,
          lift: MaximalLift.bench,
        ),
        2,
      );
      expect(
        MaximalKgResolver.countLiftValues(
          measurements: measurements,
          lift: MaximalLift.squat,
        ),
        0,
      );
    });
  });

  group('MaximalRef JSON', () {
    test('measurement round-trips', () {
      const ref = MaximalRef.measurement(lift: MaximalLift.bench);
      expect(MaximalRef.fromJson(ref.toJson()), ref);
      expect(ref.toJson(), {'type': 'measurement', 'lift': 'bench'});
    });

    test('custom round-trips', () {
      const ref = MaximalRef.custom(maximalId: 'abc');
      expect(MaximalRef.fromJson(ref.toJson()), ref);
      expect(ref.toJson(), {'type': 'custom', 'maximalId': 'abc'});
    });

    test('invalid payloads decode to null', () {
      expect(MaximalRef.fromJson(null), isNull);
      expect(MaximalRef.fromJson('x'), isNull);
      expect(MaximalRef.fromJson({'type': 'measurement'}), isNull);
      expect(MaximalRef.fromJson({'type': 'measurement', 'lift': 'foo'}), isNull);
      expect(MaximalRef.fromJson({'type': 'custom'}), isNull);
      expect(MaximalRef.fromJson({'type': 'custom', 'maximalId': ''}), isNull);
      expect(MaximalRef.fromJson({'type': 'other'}), isNull);
      // Wrong JSON value types must not throw.
      expect(
        MaximalRef.fromJson({'type': 'measurement', 'lift': 1}),
        isNull,
      );
      expect(
        MaximalRef.fromJson({'type': 'custom', 'maximalId': 42}),
        isNull,
      );
    });
  });
}
