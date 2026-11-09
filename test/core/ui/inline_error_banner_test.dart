import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/inline_error_banner.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('InlineErrorBanner shows message detail and retry', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: InlineErrorBanner(
            message: 'Errore di caricamento',
            detail: 'Dettaglio',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('Errore di caricamento'), findsOneWidget);
    expect(find.text('Dettaglio'), findsOneWidget);
    expect(find.text('Riprova'), findsOneWidget);

    expect(
      tester.getSemantics(find.text('Errore di caricamento')).flagsCollection.isLiveRegion,
      isTrue,
    );

    await tester.tap(find.text('Riprova'));
    await tester.pump();
    expect(retried, isTrue);
  });
}
