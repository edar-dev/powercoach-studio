import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/landing/presentation/widgets/landing_pricing_section.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('LandingPricingSection shows Free and Pro tiers', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.light,
        locale: const Locale('it'),
        supportedLocales: const [Locale('it'), Locale('en')],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Builder(
              builder: (context) {
                return LandingPricingSection(
                  l10n: AppLocalizations.of(context),
                  isLoggedIn: false,
                  onStartFree: () {},
                  onUpgradePro: () {},
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Gratuito'), findsOneWidget);
    expect(find.text('Pro'), findsOneWidget);
    expect(find.text('12 €/mese'), findsOneWidget);
    expect(find.text('Crea account gratis'), findsOneWidget);
  });
}
