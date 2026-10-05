import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/analytics/posthog_bootstrap.dart';

void main() {
  setUp(() {
    PostHogBootstrap.debugReset();
  });

  tearDown(() {
    PostHogBootstrap.debugReset();
    dotenv.clean();
  });

  group('PostHogBootstrap', () {
    test('isConfigured is false when API key is empty', () {
      dotenv.loadFromString(envString: '''
POSTHOG_API_KEY=
POSTHOG_HOST=https://eu.i.posthog.com
''');
      expect(PostHogBootstrap.isConfigured, isFalse);
    });

    test('isConfigured is true when API key is set', () {
      dotenv.loadFromString(envString: '''
POSTHOG_API_KEY=phc_test_key
POSTHOG_HOST=
''');
      expect(PostHogBootstrap.isConfigured, isTrue);
    });

    test('resolvedHost defaults to EU cloud', () {
      dotenv.loadFromString(envString: '''
POSTHOG_API_KEY=phc_test_key
''');
      expect(PostHogBootstrap.resolvedHost, posthogDefaultHost);
      expect(PostHogBootstrap.resolvedHost, 'https://eu.i.posthog.com');
    });

    test('resolvedHost uses POSTHOG_HOST when set', () {
      dotenv.loadFromString(envString: '''
POSTHOG_API_KEY=phc_test_key
POSTHOG_HOST=https://us.i.posthog.com
''');
      expect(PostHogBootstrap.resolvedHost, 'https://us.i.posthog.com');
    });

    test('ensureInitialized is a no-op off web (VM tests)', () {
      dotenv.loadFromString(envString: '''
POSTHOG_API_KEY=phc_test_key
POSTHOG_HOST=https://eu.i.posthog.com
''');
      PostHogBootstrap.ensureInitialized();
      // On VM / non-web, JS bridge never loads.
      expect(PostHogBootstrap.isEnabled, isFalse);
    });
  });
}
