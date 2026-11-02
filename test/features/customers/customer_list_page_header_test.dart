import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/customer_list_page_header.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('page header shows title, subtitle, and new-customer CTA', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CustomerListPageHeader(onNewCustomer: () => tapped = true),
        ),
      ),
    );

    expect(find.text('Clienti'), findsOneWidget);
    expect(
      find.text(
        'Gestisci il roster atleti, monitora le schede attive e lo stato.',
      ),
      findsOneWidget,
    );
    expect(find.text('Nuovo cliente'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(find.text('Nuovo cliente'));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
