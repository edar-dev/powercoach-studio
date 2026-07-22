import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/auth/auth_redirect_urls.dart';

void main() {
  group('AuthRedirectUrls', () {
    test('emailConfirmation uses production origin when not on web', () {
      expect(
        AuthRedirectUrls.emailConfirmation,
        'https://powercoach-studio.vercel.app/login',
      );
    });

    test('passwordRecovery matches email confirmation target', () {
      expect(
        AuthRedirectUrls.passwordRecovery,
        AuthRedirectUrls.emailConfirmation,
      );
    });
  });
}
