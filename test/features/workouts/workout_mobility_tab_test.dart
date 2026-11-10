import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_mobility_tab.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_mobility_tab_widgets.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_session_card_chrome.dart';
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

Widget _tab({
  required List<MobilitySection> sections,
  required List<MobilityItem> items,
  int selectedSectionIndex = 0,
  List<MobilityItem>? allItems,
}) {
  final countsSource = allItems ?? items;
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      return WorkoutMobilityTab(
        theme: theme,
        colorScheme: theme.colorScheme,
        sections: sections,
        selectedSectionIndex: selectedSectionIndex,
        itemsForSelectedSection: items,
        itemCountForSection: (sectionId) =>
            countsSource.where((e) => e.sectionId == sectionId).length,
        onAddItem: () {},
        onAddSection: () {},
        onEditSection: (_) {},
        onDeleteSection: (_) {},
        onSelectSection: (_) {},
        onReorderItems: (_, _) {},
        onUpdateItem: (_, _, _, _) {},
        onDeleteItem: (_) {},
      );
    },
  );
}

void main() {
  test('empty section name displays numbered Sezione via helper', () {
    // Lightweight unit check; widget test below also asserts rendered text.
    final l10n = lookupAppLocalizations(const Locale('it'));
    expect(
      mobilitySectionDisplayName(name: '', index: 0, l10n: l10n),
      'Sezione 1',
    );
    expect(
      mobilitySectionDisplayName(name: '  ', index: 2, l10n: l10n),
      'Sezione 3',
    );
    expect(
      mobilitySectionDisplayName(name: 'Sezione 1', index: 0, l10n: l10n),
      'Sezione 1',
    );
    expect(
      mobilitySectionDisplayName(name: 'Warm-up', index: 0, l10n: l10n),
      'Warm-up',
    );
  });

  testWidgets('empty section name renders numbered Sezione card', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        _tab(
          sections: const [
            MobilitySection(id: 's1', name: ''),
          ],
          items: const [],
        ),
      ),
    );

    expect(find.text('Sezione 1'), findsOneWidget);
    expect(find.byType(MobilitySectionCard), findsOneWidget);
    expect(find.byType(MobilityAddSectionCard), findsOneWidget);
  });

  testWidgets('empty items shows mobility empty CTA', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _tab(
          sections: const [
            MobilitySection(id: 's1', name: 'Warm-up'),
          ],
          items: const [],
        ),
      ),
    );

    expect(find.text('Nessun esercizio in questa sezione'), findsOneWidget);
    expect(
      find.text('Aggiungi un esercizio di mobilità per iniziare.'),
      findsOneWidget,
    );
    expect(find.text('Aggiungi esercizio'), findsOneWidget);
    // FilledButton.icon builds _FilledButtonWithIcon, not FilledButton.
    expect(find.byIcon(Icons.add), findsWidgets);
    expect(find.byType(MobilityItemCard), findsNothing);
    expect(find.byType(WorkoutSessionCardShell), findsNothing);
  });

  testWidgets('populated section shows session-chrome item title', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        _tab(
          sections: const [
            MobilitySection(id: 's1', name: 'Warm-up'),
          ],
          items: const [
            MobilityItem(
              id: 'i1',
              title: 'World Greatest Stretch',
              subtitle: '3x30s',
              sectionId: 's1',
              shortTitle: 'WGS',
            ),
          ],
        ),
      ),
    );

    expect(find.byType(MobilityItemCard), findsOneWidget);
    expect(find.byType(WorkoutSessionCardShell), findsOneWidget);
    expect(find.text('World Greatest Stretch'), findsOneWidget);
    expect(find.text('3x30s'), findsOneWidget);
    expect(find.text('Aggiungi esercizio'), findsOneWidget);
    // OutlinedButton.icon builds _OutlinedButtonWithIcon, not OutlinedButton.
    expect(find.byIcon(Icons.add), findsWidgets);
    expect(find.text('Nessun esercizio in questa sezione'), findsNothing);
  });

  testWidgets('single section hides delete in overflow menu', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _tab(
          sections: const [
            MobilitySection(id: 's1', name: 'Warm-up'),
          ],
          items: const [],
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();

    expect(find.text('Modifica sezione'), findsOneWidget);
    expect(find.text('Elimina sezione'), findsNothing);
  });

  testWidgets('section card shows exercise count label', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _tab(
          sections: const [
            MobilitySection(id: 's1', name: 'Warm-up'),
          ],
          items: const [
            MobilityItem(
              id: 'i1',
              title: 'WGS',
              subtitle: '',
              sectionId: 's1',
            ),
            MobilityItem(
              id: 'i2',
              title: 'Hip opener',
              subtitle: '',
              sectionId: 's1',
            ),
          ],
        ),
      ),
    );

    expect(find.text('2 esercizi'), findsOneWidget);
  });
}
