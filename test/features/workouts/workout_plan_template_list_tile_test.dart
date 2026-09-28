import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_plan_template_list_tile.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('WorkoutPlanTemplateListTile shows title edit and assign', (
    tester,
  ) async {
    var assigned = false;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: WorkoutPlanTemplateListTile(
            title: 'Upper Blast',
            updatedAgo: 'Updated just now',
            summaryText: '2 weeks · 4 days · 12 exercises',
            phase: 'Hypertrophy',
            onTap: () {},
            onEdit: () {},
            onAssign: () => assigned = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Upper Blast'), findsOneWidget);
    expect(find.text('Hypertrophy'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('Duplicate template'), findsNothing);
    expect(find.text('Delete template'), findsNothing);
    await tester.tap(find.text('Assign to client'));
    await tester.pump();
    expect(assigned, isTrue);
  });
}
