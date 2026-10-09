import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:powercoach_studio/features/customers/presentation/widgets/customer_list_empty_body.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('it')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('empty body shows Stitch IT title, CTA and step cards',
      (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return CustomerListEmptyBody(
              l10n: l10n,
              onImportFromContacts: () {},
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nessun cliente ancora'), findsOneWidget);
    expect(
      find.textContaining('impostare i mesocicli'),
      findsOneWidget,
    );
    expect(find.text('Aggiungi il tuo primo cliente'), findsOneWidget);
    expect(find.text('Anagrafica & Target'), findsOneWidget);
    expect(find.text('Assegna Scheda'), findsOneWidget);
    expect(find.text('Monitora Carichi & RPE'), findsOneWidget);
    expect(find.textContaining('sincronizzano sul cloud'), findsOneWidget);
  });
}
