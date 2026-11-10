import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_item.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/exercise_picker_tree_list.dart';
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
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('shows leaf name only and picks on title tap', (tester) async {
    CustomExerciseItem? picked;
    final roots = [
      _item(
        id: 'squat',
        name: 'Squat',
        children: [_item(id: 'box', name: 'Box squat')],
      ),
    ];

    await tester.pumpWidget(
      _wrap(
        ExercisePickerTreeList(
          roots: roots,
          pinnedIds: const {},
          onPick: (item) => picked = item,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('Box squat'), findsNothing);
    expect(find.textContaining('›'), findsNothing);

    await tester.tap(find.text('Squat'));
    await tester.pump();
    expect(picked?.id, 'squat');
  });

  testWidgets('chevron expands children without selecting parent', (
    tester,
  ) async {
    CustomExerciseItem? picked;
    final roots = [
      _item(
        id: 'squat',
        name: 'Squat',
        children: [_item(id: 'box', name: 'Box squat')],
      ),
    ];

    await tester.pumpWidget(
      _wrap(
        ExercisePickerTreeList(
          roots: roots,
          pinnedIds: const {},
          onPick: (item) => picked = item,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    expect(picked, isNull);
    expect(find.text('Box squat'), findsOneWidget);

    await tester.tap(find.text('Box squat'));
    await tester.pump();
    expect(picked?.id, 'box');
  });

  testWidgets('forceExpandAll shows children immediately', (tester) async {
    final roots = [
      _item(
        id: 'squat',
        name: 'Squat',
        children: [_item(id: 'box', name: 'Box squat')],
      ),
    ];

    await tester.pumpWidget(
      _wrap(
        ExercisePickerTreeList(
          roots: roots,
          pinnedIds: const {'squat'},
          forceExpandAll: true,
          onPick: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Box squat'), findsOneWidget);
    expect(find.byIcon(Icons.push_pin), findsOneWidget);
  });
}
