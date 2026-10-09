import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_builder_sandbox_banner.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  Widget app(Widget child) {
    return MaterialApp(
      theme: StitchM3Theme.light,
      darkTheme: StitchM3Theme.dark,
      themeMode: ThemeMode.dark,
      locale: const Locale('it'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: child),
    );
  }

  testWidgets('shows clarified IT copy and FilledButton CTA', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      app(
        WorkoutBuilderSandboxBanner(
          onAssignToCustomer: () => tapped = true,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text('Bozza locale su questo dispositivo — non è sul cliente'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Salva tiene la bozza solo qui'),
      findsOneWidget,
    );
    expect(find.textContaining('Assegna a cliente'), findsWidgets);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(TextButton), findsNothing);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
