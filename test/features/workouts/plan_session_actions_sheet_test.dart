import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/plan_session_actions_sheet.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_plan_name_prompt_dialog.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  group('showPlanSessionActionsSheet', () {
    testWidgets('returns selected action token', (tester) async {
      String? selected;
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                selected = await showPlanSessionActionsSheet(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Skipped'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(selected, 'status_skipped');
    });
  });

  group('showWorkoutPlanNamePromptDialog', () {
    testWidgets('returns trimmed name when confirmed', (tester) async {
      String? result;
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await showWorkoutPlanNamePromptDialog(
                  context,
                  title: 'Duplicate plan',
                  nameLabel: 'Name',
                  confirmLabel: 'Duplicate',
                  initialName: 'Plan A',
                );
              },
              child: const Text('Prompt'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Prompt'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Plan B');
      await tester.tap(find.text('Duplicate'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(result, 'Plan B');
    });
  });
}
