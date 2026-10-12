import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/billing/paywall_dialog.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpPaywall(
    WidgetTester tester, {
    required Locale locale,
    required PaywallFeature feature,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.light,
        darkTheme: StitchM3Theme.dark,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () => showPaywallDialog(
                  context,
                  feature: feature,
                ),
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('showPaywallDialog', () {
    testWidgets('pdfBrand shows English copy and Not now closes',
        (tester) async {
      await pumpPaywall(
        tester,
        locale: const Locale('en'),
        feature: PaywallFeature.pdfBrand,
      );

      expect(
        find.textContaining('Custom PDF brand kit'),
        findsOneWidget,
      );
      expect(find.text('Not now'), findsOneWidget);

      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Custom PDF brand kit'), findsNothing);
    });

    testWidgets('measurementExport shows Italian copy and Non ora closes',
        (tester) async {
      await pumpPaywall(
        tester,
        locale: const Locale('it'),
        feature: PaywallFeature.measurementExport,
      );

      expect(
        find.textContaining('export CSV e PDF dello storico misure'),
        findsOneWidget,
      );
      expect(find.text('Non ora'), findsOneWidget);

      await tester.tap(find.text('Non ora'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('export CSV e PDF dello storico misure'),
        findsNothing,
      );
    });

    testWidgets('pdfBrand shows Italian copy', (tester) async {
      await pumpPaywall(
        tester,
        locale: const Locale('it'),
        feature: PaywallFeature.pdfBrand,
      );

      expect(find.textContaining('brand kit PDF'), findsOneWidget);
    });

    testWidgets('measurementExport shows English copy', (tester) async {
      await pumpPaywall(
        tester,
        locale: const Locale('en'),
        feature: PaywallFeature.measurementExport,
      );

      expect(
        find.textContaining('Measurement history CSV and PDF export'),
        findsOneWidget,
      );
    });
  });
}
