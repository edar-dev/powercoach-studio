import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/mobility_session_presentation.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/session_preview_card.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/training_phase_day_card.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_mobility_tab.dart';
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
  required List<MobilityItem> allItems,
  void Function(int)? onOpenSection,
  VoidCallback? onAddSection,
  void Function(int)? onEditSection,
  void Function(int)? onDeleteSection,
}) {
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      return WorkoutMobilityTab(
        theme: theme,
        colorScheme: theme.colorScheme,
        sections: sections,
        itemsForSection: (sectionId) =>
            allItems.where((e) => e.sectionId == sectionId).toList(),
        onOpenSection: onOpenSection ?? (_) {},
        onAddSection: onAddSection ?? () {},
        onEditSection: onEditSection ?? (_) {},
        onDeleteSection: onDeleteSection ?? (_) {},
      );
    },
  );
}

void main() {
  test('empty section name displays numbered Sezione via helper', () {
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

  testWidgets('vertical section cards: empty name → Sezione N + add card', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        _tab(
          sections: const [
            MobilitySection(id: 's1', name: ''),
            MobilitySection(id: 's2', name: 'Cooldown'),
          ],
          allItems: const [],
        ),
      ),
    );

    expect(find.text('Sezione 1'), findsOneWidget);
    expect(find.text('Cooldown'), findsOneWidget);
    expect(find.byType(SessionPreviewCard), findsNWidgets(2));
    expect(find.byType(TrainingPhaseAddDayCard), findsOneWidget);
  });

  testWidgets('section card shows item preview and exercise count', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        _tab(
          sections: const [
            MobilitySection(id: 's1', name: 'Warm-up'),
          ],
          allItems: const [
            MobilityItem(
              id: 'i1',
              title: 'World Greatest Stretch',
              subtitle: '3x30s',
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

    expect(find.text('World Greatest Stretch'), findsOneWidget);
    expect(find.text('Hip opener'), findsOneWidget);
    expect(find.text('2 esercizi'), findsOneWidget);
    expect(find.text('Modifica sessione'), findsOneWidget);
  });

  testWidgets('tap section card invokes onOpenSection', (tester) async {
    var opened = -1;
    await tester.pumpWidget(
      _wrap(
        _tab(
          sections: const [
            MobilitySection(id: 's1', name: 'Warm-up'),
          ],
          allItems: const [],
          onOpenSection: (i) => opened = i,
        ),
      ),
    );

    await tester.tap(find.byType(SessionPreviewCard));
    await tester.pump();
    expect(opened, 0);
  });

  testWidgets('single section hides delete in overflow menu', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _tab(
          sections: const [
            MobilitySection(id: 's1', name: 'Warm-up'),
          ],
          allItems: const [],
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();

    expect(find.text('Modifica sezione'), findsOneWidget);
    expect(find.text('Elimina sezione'), findsNothing);
  });

  testWidgets('empty section shows no-exercises preview label', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _tab(
          sections: const [
            MobilitySection(id: 's1', name: 'Warm-up'),
          ],
          allItems: const [],
        ),
      ),
    );

    // Preview copy + footer count both use the empty plural ("Nessun esercizio").
    expect(find.text('Nessun esercizio'), findsWidgets);
    expect(find.text('Modifica sessione'), findsOneWidget);
  });

  testWidgets('add-section card invokes callback', (tester) async {
    var added = false;
    await tester.pumpWidget(
      _wrap(
        _tab(
          sections: const [
            MobilitySection(id: 's1', name: 'Warm-up'),
          ],
          allItems: const [],
          onAddSection: () => added = true,
        ),
      ),
    );

    await tester.tap(find.byType(TrainingPhaseAddDayCard));
    await tester.pump();
    expect(added, isTrue);
  });
}
