import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/connectivity_status_chip.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('ConnectivityStatusChip hidden when online', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: ConnectivityStatusChip(isOnlineOverride: _alwaysOnline),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);
    expect(find.text('Offline'), findsNothing);
  });

  testWidgets('ConnectivityStatusChip shows when offline', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: ConnectivityStatusChip(isOnlineOverride: _alwaysOffline),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);
  });
}

bool _alwaysOnline() => true;
bool _alwaysOffline() => false;
