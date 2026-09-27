import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/customers/data/models/customer.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_exercise_record.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/customer_detail_overview_tab.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('overview hero shows name, back-facing CTAs, and journey chip', (
    tester,
  ) async {
    final customer = Customer(
      id: 'cust-abc12345',
      userId: 'u1',
      name: 'Edoardo Moretti',
      email: 'edo@example.com',
      goals: 'Prep. Atletica',
      dateOfBirth: '1999-05-14',
      createdAt: DateTime(2023, 9, 12),
      updatedAt: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CustomerDetailOverviewTab(
            customer: customer,
            customerId: customer.id,
            goalLabel: customer.goals!,
            measurements: const [],
            measurementsLoading: false,
            exerciseRecords: const <CustomerExerciseRecord>[],
            progressSnapshot: null,
            progressLoading: false,
            workoutPlans: const [],
            workoutPlansLoading: false,
            onAssignWorkout: ({String? planId}) {},
            onOpenMeasurementHistory: () {},
            onReloadMeasurements: () {},
            onReloadWorkoutPlans: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edoardo Moretti'), findsOneWidget);
    expect(find.textContaining('Obiettivo'), findsOneWidget);
    expect(find.text('Assegna workout'), findsWidgets);
    expect(find.text('Modifica profilo'), findsOneWidget);
    expect(find.textContaining('Inizio percorso'), findsOneWidget);
    expect(find.textContaining('PARAMETRI BIOMETRICI'), findsOneWidget);
  });
}
