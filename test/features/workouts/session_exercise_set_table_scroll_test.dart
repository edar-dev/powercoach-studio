import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/session_exercise_editor_card.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('narrow set table enables horizontal scroll with edge fade', (
    tester,
  ) async {
    const phone = Size(360, 800);
    await tester.binding.setSurfaceSize(phone);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const exercise = Exercise(
      id: 'e1',
      name: 'Panca',
      sets: '3',
      reps: '5',
      rpe: '80kg',
      setDetails: [
        ExerciseSet(sets: '3', reps: '5', rpe: '80kg', note: 'Controllata'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.light,
        darkTheme: StitchM3Theme.dark,
        themeMode: ThemeMode.dark,
        locale: const Locale('it'),
        supportedLocales: const [Locale('it'), Locale('en')],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(size: phone),
            child: Builder(
              builder: (context) {
                final theme = Theme.of(context);
                return SessionExerciseEditorCard(
                  theme: theme,
                  colorScheme: theme.colorScheme,
                  exercise: exercise,
                  index: 1,
                  expanded: true,
                  onExpandedChanged: (_) {},
                  onUpdateSet: (_, _, _, _, _) {},
                  onRemoveSet: (_) {},
                  onAddSet: () {},
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('session_set_table_scroll')), findsOneWidget);
    // Right-edge fade appears once layout knows content can scroll further.
    expect(
      find.byKey(const Key('session_set_table_right_fade')),
      findsOneWidget,
    );
  });
}
