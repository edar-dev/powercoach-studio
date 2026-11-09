import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/app_snackbar.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

Widget _phoneApp({required Widget home}) {
  return MediaQuery(
    data: const MediaQueryData(size: Size(390, 844)),
    child: MaterialApp(
      theme: StitchM3Theme.dark,
      locale: const Locale('it'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

void main() {
  testWidgets('phone snackbar sits above NavigationBar clearance', (
    tester,
  ) async {
    await tester.pumpWidget(
      _phoneApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: FilledButton(
                  onPressed: () => showAppSnackBar(
                    context,
                    content: const Text('Salvato'),
                  ),
                  child: const Text('Show'),
                ),
              );
            },
          ),
          bottomNavigationBar: NavigationBar(
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();

    final snack = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snack.behavior, SnackBarBehavior.floating);
    expect(snack.margin, isA<EdgeInsets>());
    final margin = snack.margin! as EdgeInsets;
    expect(margin.bottom, greaterThanOrEqualTo(kAppSnackBarNavBarClearance));
  });

  testWidgets('extraBottomOffset raises snackbar further', (tester) async {
    late double resolved;
    await tester.pumpWidget(
      _phoneApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: FilledButton(
                  onPressed: () {
                    resolved = resolveAppSnackBarBottomMargin(
                      context,
                      extraBottomOffset: kAppSnackBarStickyFooterClearance,
                    );
                    showAppSnackBar(
                      context,
                      content: const Text('Con sticky'),
                      extraBottomOffset: kAppSnackBarStickyFooterClearance,
                    );
                  },
                  child: const Text('Show'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();

    expect(
      resolved,
      greaterThanOrEqualTo(
        kAppSnackBarNavBarClearance + kAppSnackBarStickyFooterClearance,
      ),
    );
    final snack = tester.widget<SnackBar>(find.byType(SnackBar));
    final margin = snack.margin! as EdgeInsets;
    expect(margin.bottom, resolved);
  });
}
