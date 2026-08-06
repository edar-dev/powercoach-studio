import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_item.dart';
import 'package:powercoach_studio/features/exercise_library/domain/exercise_autocomplete_filter.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/exercise_add_library_picker.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/exercise_add_set_rows_editor.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/exercise_add_sheet_save_handler.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/exercise_add_sheet_states.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/exercise_set_edit_controllers.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

CustomExerciseItem _item({
  required String id,
  required String name,
}) {
  final now = DateTime(2026, 1, 1);
  return CustomExerciseItem(
    id: id,
    name: name,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: StitchM3Theme.dark,
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('ExerciseAddSheetLoadErrorView shows retry and create new', (
    tester,
  ) async {
    var retried = false;
    var createdNew = false;
    await tester.pumpWidget(
      _wrap(
        ExerciseAddSheetLoadErrorView(
          onRetry: () => retried = true,
          onCreateNew: () => createdNew = true,
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

  group('resolveExactLibraryExerciseMatch', () {
    test('matches exact name case-insensitively', () {
      final options = [
        _item(id: '1', name: 'Bench Press'),
        _item(id: '2', name: 'Squat'),
      ];
      final match = resolveExactLibraryExerciseMatch(
        query: '  bench press ',
        options: options,
      );
      expect(match?.id, '1');
    });

    test('returns null when name is ambiguous', () {
      final options = [
        _item(id: '1', name: 'Curl'),
        _item(id: '2', name: 'Curl'),
      ];
      expect(
        resolveExactLibraryExerciseMatch(query: 'curl', options: options),
        isNull,
      );
    });

    test('matches unique display name', () {
      final options = [
        _item(id: '1', name: 'High bar'),
        _item(id: '2', name: 'Low bar'),
      ];
      final match = resolveExactLibraryExerciseMatch(
        query: 'Squat › High bar',
        options: options,
        displayName: (e) => e.id == '1' ? 'Squat › High bar' : e.name,
      );
      expect(match?.id, '1');
    });
  });

  group('resolveLibrarySelectionForSave', () {
    test('keeps chip selection while search text still matches', () {
      final squat = _item(id: '1', name: 'Squat');
      final bench = _item(id: '2', name: 'Bench');
      final resolved = resolveLibrarySelectionForSave(
        selectedExercise: squat,
        librarySearchText: 'squat',
        exerciseOptions: [squat, bench],
      );
      expect(resolved?.id, '1');
    });

    test('prefers exact typed match when search diverges from chip', () {
      final squat = _item(id: '1', name: 'Squat');
      final bench = _item(id: '2', name: 'Bench');
      final resolved = resolveLibrarySelectionForSave(
        selectedExercise: squat,
        librarySearchText: 'Bench',
        exerciseOptions: [squat, bench],
      );
      expect(resolved?.id, '2');
    });
  });

  testWidgets('library picker omits duplicate Exercise label', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ExerciseAddLibraryPicker(
          exerciseOptions: [_item(id: '1', name: 'Squat')],
          recentExercises: const [],
          pinnedExerciseIds: const {},
          depthById: const {},
          parentNameById: const {},
          selectedExercise: null,
          exerciseFilter: DebouncedExerciseAutocompleteFilter(),
          isMounted: () => true,
          onExerciseSelected: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Exercise'), findsNothing);
    expect(find.byType(TextFormField), findsOneWidget);
  });

  testWidgets('set rows hide trash when only one row remains', (tester) async {
    final controllers = [
      SetEditControllers(
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ),
    ];

    await tester.pumpWidget(
      _wrap(
        ExerciseAddSetRowsEditor(
          setControllers: controllers,
          onAddSet: () {},
          onRemoveSet: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.delete_outline), findsNothing);
    expect(find.text('Sets (Set × Reps + Load)'), findsNothing);
  });

  testWidgets('set rows show trash with 48dp target when multiple rows', (
    tester,
  ) async {
    final controllers = [
      SetEditControllers(
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ),
      SetEditControllers(
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ),
    ];

    await tester.pumpWidget(
      _wrap(
        ExerciseAddSetRowsEditor(
          setControllers: controllers,
          onAddSet: () {},
          onRemoveSet: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));
    final button = tester.widget<IconButton>(find.byType(IconButton).first);
    expect(
      button.constraints,
      const BoxConstraints(minWidth: 48, minHeight: 48),
    );
  });
}
