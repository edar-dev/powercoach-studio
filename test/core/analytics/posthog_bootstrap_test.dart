import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/analytics/analytics_consent_store.dart';
import 'package:powercoach_studio/core/analytics/posthog_bootstrap.dart';
import 'package:powercoach_studio/core/analytics/product_analytics.dart';
import 'package:powercoach_studio/core/settings/settings_prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    PostHogBootstrap.debugReset();
    SharedPreferences.setMockInitialValues(<String, Object>{});
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
      PostHogBootstrap.debugSetConsent(AnalyticsConsent.granted);
      PostHogBootstrap.ensureInitialized();
      // On VM / non-web, JS bridge never loads.
      expect(PostHogBootstrap.isEnabled, isFalse);
    });

    test('needsConsentBanner is false off web even when configured', () async {
      dotenv.loadFromString(envString: '''
POSTHOG_API_KEY=phc_test_key
''');
      await PostHogBootstrap.loadConsent();
      expect(PostHogBootstrap.needsConsentBanner, isFalse);
    });

    test('sanitizePagePath redacts UUIDs and temp ids', () {
      expect(
        PostHogBootstrap.debugSanitizePagePath(
          '/customers/550e8400-e29b-41d4-a716-446655440000/notes',
        ),
        '/customers/:id/notes',
      );
      expect(
        PostHogBootstrap.debugSanitizePagePath(
          '/customers/customer_abc123',
        ),
        '/customers/:id',
      );
    });
  });

  group('AnalyticsConsentStore', () {
    test('read returns null when undecided', () async {
      final store = AnalyticsConsentStore.instance;
      expect(await store.read(), isNull);
    });

    test('persists granted and denied', () async {
      final store = AnalyticsConsentStore.instance;
      await store.set(AnalyticsConsent.granted);
      expect(await store.read(), AnalyticsConsent.granted);

      await store.set(AnalyticsConsent.denied);
      expect(await store.read(), AnalyticsConsent.denied);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(SettingsPrefsKeys.analyticsConsent),
        'denied',
      );
    });

    test('clear removes decision', () async {
      final store = AnalyticsConsentStore.instance;
      await store.set(AnalyticsConsent.granted);
      await store.clear();
      expect(await store.read(), isNull);
    });
  });

  group('ProductAnalytics', () {
    test('capture is a no-op when PostHog is disabled (VM)', () {
      dotenv.loadFromString(envString: '''
POSTHOG_API_KEY=phc_test_key
''');
      PostHogBootstrap.debugSetConsent(AnalyticsConsent.granted);
      PostHogBootstrap.ensureInitialized();
      expect(PostHogBootstrap.isEnabled, isFalse);
      // Must not throw.
      ProductAnalytics.capture('login_completed');
      ProductAnalytics.loginCompleted();
      ProductAnalytics.signupCompleted();
      ProductAnalytics.customerCreated();
      ProductAnalytics.workoutPlanCreated();
      ProductAnalytics.workoutPlanSaved();
      ProductAnalytics.pdfExported(source: 'workout_plan');
      ProductAnalytics.subscriptionCheckoutStarted(billingInterval: 'monthly');
      ProductAnalytics.subscribed();
    });

    test('event name constants are stable', () {
      expect(AnalyticsEvents.loginCompleted, 'login_completed');
      expect(AnalyticsEvents.signupCompleted, 'signup_completed');
      expect(AnalyticsEvents.customerCreated, 'customer_created');
      expect(AnalyticsEvents.workoutPlanCreated, 'workout_plan_created');
      expect(AnalyticsEvents.workoutPlanSaved, 'workout_plan_saved');
      expect(AnalyticsEvents.pdfExported, 'pdf_exported');
      expect(
        AnalyticsEvents.subscriptionCheckoutStarted,
        'subscription_checkout_started',
      );
      expect(AnalyticsEvents.subscribed, 'subscribed');
    });
  });
}
