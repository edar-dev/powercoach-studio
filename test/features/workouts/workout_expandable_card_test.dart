import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_expandable_card.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: StitchM3Theme.light,
    darkTheme: StitchM3Theme.dark,
    themeMode: ThemeMode.dark,
    locale: const Locale('it'),
    supportedLocales: const [Locale('it'), Locale('en')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('WorkoutExpandableCard toggles from header, not trailing menu', (
    tester,
  ) async {
    var expanded = false;
    var menuOpened = false;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return WorkoutExpandableCard(
              title: const Text('Bench press'),
              summary: '3x10',
              expanded: expanded,
              onExpandedChanged: (value) => setState(() => expanded = value),
              trailing: IconButton(
                key: const Key('card_menu'),
                icon: const Icon(Icons.more_vert),
                onPressed: () => menuOpened = true,
              ),
              expandedChild: const Text('Set details'),
            );
          },
        ),
      ),
    );

    expect(find.text('Set details'), findsNothing);

    await tester.tap(find.byKey(const Key('card_menu')));
    await tester.pump();
    expect(menuOpened, isTrue);
    expect(expanded, isFalse);

    await tester.tap(find.text('Bench press'));
    await tester.pump();
    expect(expanded, isTrue);
    expect(find.text('Set details'), findsOneWidget);

    await tester.tap(find.text('Set details'));
    await tester.pump();
    expect(expanded, isTrue);
  });
}
