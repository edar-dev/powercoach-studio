import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_item.dart';
import 'package:powercoach_studio/features/exercise_library/presentation/widgets/exercise_library_list_tile.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

CustomExerciseItem _leaf({required String id, required String name}) {
  final now = DateTime(2026, 1, 1);
  return CustomExerciseItem(
    id: id,
    name: name,
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
  testWidgets('ExerciseLibraryListTile shows exercise name and menu', (
    tester,
  ) async {
    var edited = false;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ExerciseLibraryListTile(
            item: _leaf(id: '1', name: 'Back Squat'),
            isPinned: (_) => false,
            onEdit: (_) => edited = true,
            onDelete: (_) {},
            onAddVariant: (_) {},
            onTogglePin: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Back Squat'), findsOneWidget);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pump();
    expect(edited, isTrue);
  });

  testWidgets('folder tile shows name and folder icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ExerciseLibraryListTile(
            item: _folder(
              id: 'squat',
              name: 'Squat',
              children: [
                _leaf(id: 'low', name: 'Low bar'),
                _leaf(id: 'high', name: 'High bar'),
              ],
            ),
            isPinned: (_) => false,
            onEdit: (_) {},
            onDelete: (_) {},
            onAddVariant: (_) {},
            onTogglePin: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Squat'), findsOneWidget);
    expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    // Variant-count subtitle was removed; children appear when expanded.
    expect(find.text('2 variants'), findsNothing);
  });
}
