import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/customers/presentation/screens/customer_measurement_form_screen.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('measurement form shows dark header title and today CTA', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CustomerMeasurementFormScreen(
          customerId: 'c1',
          customerName: 'Edoardo Rossi',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aggiungi misura'), findsOneWidget);
    expect(find.text('Edoardo Rossi'), findsOneWidget);
    expect(find.text('Oggi'), findsOneWidget);
    expect(find.text('Annulla'), findsOneWidget);
    expect(find.text('Salva'), findsWidgets);
  });
}
