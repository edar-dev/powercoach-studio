import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/auth/access_waitlist.dart';

void main() {
  group('AccessWaitlist.isValidEmail', () {
    test('accepts common addresses', () {
      expect(AccessWaitlist.isValidEmail('coach@studio.it'), isTrue);
      expect(AccessWaitlist.isValidEmail('  Coach.Name+beta@Example.com '), isTrue);
    });

    test('rejects empty and malformed', () {
      expect(AccessWaitlist.isValidEmail(''), isFalse);
      expect(AccessWaitlist.isValidEmail('   '), isFalse);
      expect(AccessWaitlist.isValidEmail('not-an-email'), isFalse);
      expect(AccessWaitlist.isValidEmail('a@b'), isFalse);
      expect(AccessWaitlist.isValidEmail('@studio.it'), isFalse);
    });
  });

  group('AccessWaitlistResult', () {
    test('defaults alreadyPending to false', () {
      expect(const AccessWaitlistResult().alreadyPending, isFalse);
      expect(
        const AccessWaitlistResult(alreadyPending: true).alreadyPending,
        isTrue,
      );
    });
  });
}
