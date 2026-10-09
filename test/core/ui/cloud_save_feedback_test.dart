import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/remote/coach_entities_exceptions.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/cloud_save_feedback.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: StitchM3Theme.light,
    darkTheme: StitchM3Theme.dark,
    themeMode: ThemeMode.dark,
    locale: const Locale('en'),
    supportedLocales: const [Locale('it'), Locale('en')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets(
    'showCloudSaveErrorSnackBar shows offline message for online-required offline',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  showCloudSaveErrorSnackBar(
                    context,
                    CoachEntitiesOnlineRequiredException(
                      CoachEntitiesOnlineRequiredReason.offline,
                    ),
                  );
                },
                child: const Text('trigger'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('trigger'));
      await tester.pump();

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(l10n.cloudSaveRequiresNetwork), findsOneWidget);
    },
  );

  testWidgets('showCloudSaveSuccessSnackBar shows succeeded text', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return TextButton(
              onPressed: () => showCloudSaveSuccessSnackBar(context),
              child: const Text('trigger'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('trigger'));
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.cloudSaveSucceeded), findsOneWidget);
  });
}
