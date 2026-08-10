import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/landing/presentation/widgets/landing_faq_section.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'LandingFaqSection shows the local-data and desk-to-gym questions',
    (tester) async {
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
                  return LandingFaqSection(l10n: AppLocalizations.of(context));
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Dove sono salvati i dati?'), findsOneWidget);
      expect(
        find.text('Posso programmare da desktop e allenarmi in sala?'),
        findsOneWidget,
      );
    },
  );
}
