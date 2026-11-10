import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_item.dart';
import 'package:powercoach_studio/features/exercise_library/presentation/widgets/exercise_parent_search_field.dart';
import 'package:powercoach_studio/features/workouts/domain/exercise_picker_index_helpers.dart';
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

Widget _harness({
  required List<CustomExerciseItem> options,
  required Map<String, int> depthById,
  required Map<String, String> parentNameById,
  required String? selectedParentId,
  required ValueChanged<String?> onChanged,
  Widget? trailing,
}) {
  return MaterialApp(
    theme: StitchM3Theme.light,
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Column(
        children: [
          ExerciseParentSearchField(
            options: options,
            depthById: depthById,
            parentNameById: parentNameById,
            selectedParentId: selectedParentId,
            onChanged: onChanged,
          ),
          if (trailing != null) trailing,
        ],
      ),
    ),
  );
}

void main() {
  late ExercisePickerIndex index;

  setUp(() {
    index = buildParentSelectionIndex([
      _item(
        id: 'squat',
        name: 'Squat',
        children: [_item(id: 'box', name: 'Box squat')],
      ),
      _item(id: 'bench', name: 'Bench press'),
    ]);
  });

  testWidgets('typing filters parent options', (tester) async {
    String? selected;
    await tester.pumpWidget(
      _harness(
        options: index.flat,
        depthById: index.depthById,
        parentNameById: index.parentNameById,
        selectedParentId: selected,
        onChanged: (id) => selected = id,
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'bench');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(ListView),
        matching: find.text('Bench press'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(ListView),
        matching: find.text('Squat'),
      ),
      findsNothing,
    );
  });

  testWidgets('selecting a parent updates selection', (tester) async {
    String? selected;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return _harness(
            options: index.flat,
            depthById: index.depthById,
            parentNameById: index.parentNameById,
            selectedParentId: selected,
            onChanged: (id) => setState(() => selected = id),
          );
        },
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(
      find.descendant(
        of: find.byType(ListView),
        matching: find.text('Bench press'),
      ),
    );
    await tester.pump();
    // Flush any debounce started when Autocomplete writes the selection text.
    await tester.pump(const Duration(milliseconds: 250));

    expect(selected, 'bench');
  });

  testWidgets('selecting None clears parent', (tester) async {
    String? selected;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return _harness(
            options: index.flat,
            depthById: index.depthById,
            parentNameById: index.parentNameById,
            selectedParentId: selected,
            onChanged: (id) => setState(() => selected = id),
          );
        },
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(
      find.descendant(
        of: find.byType(ListView),
        matching: find.text('Squat'),
      ),
    );
    await tester.pump();
    expect(selected, 'squat');
    expect(find.byIcon(Icons.clear), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'none');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();

    await tester.tap(
      find.descendant(
        of: find.byType(ListView),
        matching: find.text('None'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(selected, isNull);
  });

  testWidgets('clear button clears selected parent', (tester) async {
    String? selected = 'bench';
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return _harness(
            options: index.flat,
            depthById: index.depthById,
            parentNameById: index.parentNameById,
            selectedParentId: selected,
            onChanged: (id) => setState(() => selected = id),
          );
        },
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.clear), findsOneWidget);
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(selected, isNull);
  });

  testWidgets('prefills selected parent display name', (tester) async {
    await tester.pumpWidget(
      _harness(
        options: index.flat,
        depthById: index.depthById,
        parentNameById: index.parentNameById,
        selectedParentId: 'box',
        onChanged: (_) {},
      ),
    );
    await tester.pump();

    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.controller?.text, 'Squat › Box squat');
    expect(find.byIcon(Icons.clear), findsOneWidget);
  });

  testWidgets('syncs field text when selectedParentId is cleared', (
    tester,
  ) async {
    String? selected = 'bench';
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return _harness(
            options: index.flat,
            depthById: index.depthById,
            parentNameById: index.parentNameById,
            selectedParentId: selected,
            onChanged: (id) => setState(() => selected = id),
            trailing: TextButton(
              onPressed: () => setState(() => selected = null),
              child: const Text('external-clear'),
            ),
          );
        },
      ),
    );
    await tester.pump();

    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller?.text,
      'Bench press',
    );

    await tester.tap(find.text('external-clear'));
    await tester.pump();

    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller?.text,
      '',
    );
    expect(find.byIcon(Icons.clear), findsNothing);
  });

  testWidgets('None option follows localized label prefix only', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        options: index.flat,
        depthById: index.depthById,
        parentNameById: index.parentNameById,
        selectedParentId: null,
        onChanged: (_) {},
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'e');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(ListView),
        matching: find.text('None'),
      ),
      findsNothing,
    );

    await tester.enterText(find.byType(TextFormField), 'no');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(ListView),
        matching: find.text('None'),
      ),
      findsOneWidget,
    );
  });
}
