import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_item.dart';
import 'package:powercoach_studio/features/exercise_library/presentation/widgets/exercise_library_card.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

CustomExerciseItem _leaf({required String id, required String name}) {
  final now = DateTime(2026, 1, 1);
  return CustomExerciseItem(
    id: id,
    name: name,
    description: 'A solid compound lift.',
    createdAt: now,
    updatedAt: now,
  );
}

CustomExerciseItem _folder({
  required String id,
  required String name,
  required List<CustomExerciseItem> children,
}) {
  final now = DateTime(2026, 1, 1);
  return CustomExerciseItem(
    id: id,
    name: name,
    createdAt: now,
    updatedAt: now,
    children: children,
  );
}

void main() {
  testWidgets('ExerciseLibraryCard shows title, details and add actions', (
    tester,
  ) async {
    var details = false;
    var added = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 360,
            child: ExerciseLibraryCard(
              item: _leaf(id: '1', name: 'Bench Press'),
              isPinned: false,
              onDetails: () => details = true,
              onAdd: () => added = true,
              onDelete: () {},
              onTogglePin: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('A solid compound lift.'), findsOneWidget);
    expect(find.byIcon(Icons.fitness_center), findsOneWidget);

    await tester.tap(find.text('Details'));
    await tester.pump();
    expect(details, isTrue);

    await tester.tap(find.textContaining('Add'));
    await tester.pump();
    expect(added, isTrue);
  });

  testWidgets('folder card shows variant count and folder icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 360,
            child: ExerciseLibraryCard(
              item: _folder(
                id: 'squat',
                name: 'Squat',
                children: [
                  _leaf(id: 'low', name: 'Low bar'),
                  _leaf(id: 'high', name: 'High bar'),
                ],
              ),
              isPinned: false,
              onDetails: () {},
              onAdd: () {},
              onDelete: () {},
              onTogglePin: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('2 variants'), findsOneWidget);
    expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
  });
}
