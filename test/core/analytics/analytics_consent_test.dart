import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/analytics/analytics_consent_banner.dart';
import 'package:powercoach_studio/core/analytics/analytics_consent_store.dart';
import 'package:powercoach_studio/core/analytics/posthog_bootstrap.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
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

  Future<void> pumpBanner(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('it'),
        supportedLocales: const [Locale('it'), Locale('en')],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const AnalyticsConsentBannerHost(
          child: Scaffold(body: Text('app-body')),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('hides banner when PostHog is not configured', (tester) async {
    dotenv.loadFromString(envString: 'POSTHOG_API_KEY=\n');
    await pumpBanner(tester);
    expect(find.text('app-body'), findsOneWidget);
    expect(find.textContaining('PostHog'), findsNothing);
  });

  testWidgets('decline persists denied consent', (tester) async {
    dotenv.loadFromString(envString: 'POSTHOG_API_KEY=phc_test_key\n');
    // Off-web, needsConsentBanner is false even when configured — banner host
    // still settles without throwing. Persist path is covered via store + accept
    // API in unit tests; here we only assert child still renders.
    await pumpBanner(tester);
    expect(find.text('app-body'), findsOneWidget);
    expect(PostHogBootstrap.isEnabled, isFalse);

    await PostHogBootstrap.declineConsent();
    expect(await AnalyticsConsentStore.instance.read(), AnalyticsConsent.denied);
  });

  testWidgets('acceptConsent persists granted without enabling off-web',
      (tester) async {
    dotenv.loadFromString(envString: 'POSTHOG_API_KEY=phc_test_key\n');
    await pumpBanner(tester);
    await PostHogBootstrap.acceptConsent();
    expect(
      await AnalyticsConsentStore.instance.read(),
      AnalyticsConsent.granted,
    );
    expect(PostHogBootstrap.isEnabled, isFalse);
  });
}
