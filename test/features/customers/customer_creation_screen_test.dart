import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:powercoach_studio/features/customers/presentation/widgets/customer_creation_goal_chips.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/customer_creation_hero_banner.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('it'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('creation hero uses Italian Stitch copy (not English hardcode)',
      (tester) async {
    await tester.pumpWidget(_wrap(const CustomerCreationHeroBanner()));
    await tester.pumpAndSettle();

    expect(find.text('Inizia un nuovo percorso'), findsOneWidget);
    expect(find.textContaining('dati anagrafici'), findsOneWidget);
    expect(find.text('Start a New Journey'), findsNothing);
  });

  testWidgets('goal chips show Stitch Italian labels', (tester) async {
    await tester.pumpWidget(
      _wrap(
        CustomerCreationGoalChips(
          selectedIndex: 0,
          onSelected: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ipertrofia'), findsOneWidget);
    expect(find.text('Forza Massima'), findsOneWidget);
    expect(find.text('Ricomposizione'), findsOneWidget);
    expect(find.text('Prep. Atletica'), findsOneWidget);
  });
}
