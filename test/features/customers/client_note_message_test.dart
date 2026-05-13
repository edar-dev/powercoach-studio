import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/customers/domain/models/client_note_message.dart';

void main() {
  group('ClientNoteMessage', () {
    test('round-trips JSON payload', () {
      final createdAt = DateTime.utc(2026, 5, 1, 9, 30);
      final message = ClientNoteMessage(
        id: 'note-1',
        customerId: 'c1',
        authorUserId: 'coach-1',
        body: 'Check squat depth',
        createdAt: createdAt,
      );
      final restored = ClientNoteMessage.fromJson(message.toJson());
      expect(restored.id, message.id);
      expect(restored.body, message.body);
      expect(restored.createdAt.toUtc(), createdAt);
    });

    test('validateBody rejects empty input', () {
      expect(
        () => ClientNoteMessage.validateBody('   '),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
