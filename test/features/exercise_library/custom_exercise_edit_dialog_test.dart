import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_item.dart';
import 'package:powercoach_studio/features/exercise_library/presentation/widgets/custom_exercise_edit_dialog.dart';
import 'package:powercoach_studio/features/exercise_library/presentation/widgets/exercise_parent_search_field.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

CustomExerciseItem _item({
  required String id,
  required String name,
  List<CustomExerciseItem> children = const [],
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

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: StitchM3Theme.light,
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(child: child),
    ),
  );
}

void main() {
  final roots = [
    _item(
      id: 'squat',
      name: 'Squat',
      children: [_item(id: 'box', name: 'Box squat')],
    ),
    _item(id: 'bench', name: 'Bench press'),
  ];

  testWidgets('shows searchable parent field from tree roots', (tester) async {
    await tester.pumpWidget(
      _wrap(
        CustomExerciseEditDialog(
          title: 'Add',
          name: '',
          description: null,
          isMobility: false,
          parentId: null,
          parentTreeRoots: roots,
          onSave: (a, b, c, d) {},
          onCancel: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(ExerciseParentSearchField), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String?>), findsNothing);
  });

  testWidgets('excludeParentIds hides edited item from parent options', (
    tester,
  ) async {
    String? savedParent;
    await tester.pumpWidget(
      _wrap(
        CustomExerciseEditDialog(
          title: 'Edit',
          name: 'Box squat',
          description: null,
          isMobility: false,
          parentId: 'squat',
          parentTreeRoots: roots,
          excludeParentIds: const {'box'},
          onSave: (name, description, parentId, isMobility) {
            savedParent = parentId;
          },
          onCancel: () {},
        ),
      ),
    );
    await tester.pump();

    // Parent search is the last TextFormField; filter to bench.
    final parentField = find.byType(TextFormField).last;
    await tester.enterText(parentField, 'bench');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(ListView),
        matching: find.text('Box squat'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(ListView),
        matching: find.text('Bench press'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(ListView),
        matching: find.text('Bench press'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();

    expect(savedParent, 'bench');
  });

  testWidgets('hides parent field when tree is empty', (tester) async {
    await tester.pumpWidget(
      _wrap(
        CustomExerciseEditDialog(
          title: 'Add',
          name: '',
          description: null,
          isMobility: false,
          parentId: null,
          parentTreeRoots: const [],
          onSave: (a, b, c, d) {},
          onCancel: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(ExerciseParentSearchField), findsNothing);
  });
}
