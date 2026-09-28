import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/sync/offline_models.dart';

void main() {
  group('tryParseOfflineEntityType', () {
    test('accepts current type names', () {
      expect(
        tryParseOfflineEntityType('customer'),
        OfflineEntityType.customer,
      );
      expect(
        tryParseOfflineEntityType('customExercise'),
        OfflineEntityType.customExercise,
      );
      expect(
        tryParseOfflineEntityType('customerNote'),
        OfflineEntityType.customerNote,
      );
    });

    test('rejects removed exerciseRecord name', () {
      expect(tryParseOfflineEntityType('exerciseRecord'), isNull);
      expect(isKnownOfflineEntityTypeName('exerciseRecord'), isFalse);
    });

    test('remaps pre-v3 SharedPreferences indexes', () {
      expect(tryParseOfflineEntityType(0), OfflineEntityType.customer);
      expect(tryParseOfflineEntityType(1), OfflineEntityType.workoutPlan);
      expect(tryParseOfflineEntityType(2), OfflineEntityType.measurement);
      expect(tryParseOfflineEntityType(3), isNull); // former exerciseRecord
      expect(tryParseOfflineEntityType(4), OfflineEntityType.customExercise);
      expect(tryParseOfflineEntityType(5), OfflineEntityType.customerNote);
      expect(tryParseOfflineEntityType('4'), OfflineEntityType.customExercise);
      expect(tryParseOfflineEntityType('5'), OfflineEntityType.customerNote);
    });
  });

  test('OfflineEntity.fromJson throws on unknown type', () {
    expect(
      () => OfflineEntity.fromJson(<String, dynamic>{
        'id': 'x',
        'type': 'exerciseRecord',
        'scopeId': 's',
        'payload': <String, dynamic>{},
        'updatedAt': DateTime(2026, 1, 1).toIso8601String(),
      }),
      throwsFormatException,
    );
  });
}
