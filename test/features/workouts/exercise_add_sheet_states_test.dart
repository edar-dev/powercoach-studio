import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/exercise_add_sheet_states.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('ExerciseAddSheetLoadErrorView shows retry and create new', (
    tester,
  ) async {
    var retried = false;
    var createdNew = false;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ExerciseAddSheetLoadErrorView(
            onRetry: () => retried = true,
            onCreateNew: () => createdNew = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(retried, isTrue);

    await tester.tap(find.text('Create new'));
    await tester.pump();
    expect(createdNew, isTrue);
  });
}
