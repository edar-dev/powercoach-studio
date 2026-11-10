import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/mobility_section_exercise_list.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_day_exercise_list.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_mobility_tab_widgets.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

MobilityItem _item(
  String id,
  String title, {
  String subtitle = '',
  String shortTitle = '',
}) {
  return MobilityItem(
    id: id,
    title: title,
    subtitle: subtitle,
    shortTitle: shortTitle,
    sectionId: 's1',
  );
}

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

MobilitySectionExerciseList _list({
  required List<MobilityItem> items,
  void Function(String, String, String, String)? onUpdateItem,
  VoidCallback? onAddItem,
  bool expandFirstOnOpen = true,
}) {
  return MobilitySectionExerciseList(
    theme: StitchM3Theme.dark,
    colorScheme: StitchM3Theme.dark.colorScheme,
    items: items,
    expandFirstOnOpen: expandFirstOnOpen,
    onUpdateItem: onUpdateItem ?? (_, _, _, _) {},
    onDeleteItem: (_) {},
    onReorderItems: (_, _) {},
    onAddItem: onAddItem,
  );
}

void main() {
  testWidgets('expands first item on open and shows inline TextFields', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        _list(
          items: [
            _item('i1', 'WGS', subtitle: '3x30s', shortTitle: 'WGS'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cards = tester
        .widgetList<MobilityItemCard>(find.byType(MobilityItemCard))
        .toList();
    expect(cards, hasLength(1));
    expect(cards.single.expanded, isTrue);
    expect(find.byType(TextField), findsNWidgets(3));
  });

  testWidgets('single expand: expanding second collapses first', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        _list(
          items: [
            _item('i1', 'First'),
            _item('i2', 'Second'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    var cards = tester
        .widgetList<MobilityItemCard>(find.byType(MobilityItemCard))
        .toList();
    expect(cards[0].expanded, isTrue);
    expect(cards[1].expanded, isFalse);

    // Tap the second card header title area to expand it.
    await tester.tap(find.text('Second'));
    await tester.pumpAndSettle();

    cards = tester
        .widgetList<MobilityItemCard>(find.byType(MobilityItemCard))
        .toList();
    expect(cards[0].expanded, isFalse);
    expect(cards[1].expanded, isTrue);
  });

  testWidgets('editing title updates via onUpdateItem callback', (tester) async {
    String? updatedId;
    String? updatedTitle;
    await tester.pumpWidget(
      _wrap(
        _list(
          items: [_item('i1', 'WGS')],
          onUpdateItem: (id, title, subtitle, shortTitle) {
            updatedId = id;
            updatedTitle = title;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Updated WGS');
    await tester.pump(const Duration(milliseconds: 500));

    expect(updatedId, 'i1');
    expect(updatedTitle, 'Updated WGS');
  });

  testWidgets('auto-expands newly added item and collapses prior', (
    tester,
  ) async {
    var items = [_item('i1', 'First')];
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                Expanded(child: _list(items: items)),
                TextButton(
                  onPressed: () {
                    setState(() {
                      items = [...items, _item('i2', 'Second')];
                    });
                  },
                  child: const Text('add-item'),
                ),
              ],
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    var cards = tester
        .widgetList<MobilityItemCard>(find.byType(MobilityItemCard))
        .toList();
    expect(cards, hasLength(1));
    expect(cards.single.expanded, isTrue);

    await tester.tap(find.text('add-item'));
    await tester.pumpAndSettle();

    cards = tester
        .widgetList<MobilityItemCard>(find.byType(MobilityItemCard))
        .toList();
    expect(cards, hasLength(2));
    expect(cards[0].expanded, isFalse);
    expect(cards[1].expanded, isTrue);
  });

  testWidgets('empty state Add CTA invokes onAddItem', (tester) async {
    var added = false;
    await tester.pumpWidget(
      _wrap(
        _list(
          items: const [],
          onAddItem: () => added = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SessionDayBottomCtas), findsOneWidget);
    await tester.tap(find.text('Aggiungi esercizio da libreria'));
    await tester.pump();
    expect(added, isTrue);
  });

  testWidgets('populated list shows library CTA that invokes onAddItem', (
    tester,
  ) async {
    var added = false;
    await tester.pumpWidget(
      _wrap(
        _list(
          items: [_item('i1', 'WGS')],
          onAddItem: () => added = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SessionDayBottomCtas), findsOneWidget);
    await tester.tap(find.text('Aggiungi esercizio da libreria'));
    await tester.pump();
    expect(added, isTrue);
  });
}
