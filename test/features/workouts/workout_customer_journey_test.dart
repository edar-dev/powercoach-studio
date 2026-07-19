import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/customers/data/customer_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_draft_store.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_routine_coordinator.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_session_controller.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_editor_controller.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_builder_editor_shell.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_builder_first_save_banner.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

/// Harness for the loaded new-customer-plan editor shell (no Drift load).
class _NewCustomerPlanEditorHarness extends StatefulWidget {
  const _NewCustomerPlanEditorHarness();

  @override
  State<_NewCustomerPlanEditorHarness> createState() =>
      _NewCustomerPlanEditorHarnessState();
}

class _NewCustomerPlanEditorHarnessState extends State<_NewCustomerPlanEditorHarness>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _nameController = TextEditingController(text: 'Nuova scheda');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WorkoutBuilderEditorShell(
      canPop: true,
      saving: false,
      showManualSaveButton: true,
      showFirstSaveBanner: true,
      saveStatusIndicator: null,
      editorMode: true,
      loading: false,
      hideExportMenu: false,
      showsMobilityTab: true,
      sectionTabController: _tabController,
      routineNameController: _nameController,
      trainingTab: const Center(child: Text('Training tab body')),
      mobilityTab: const Center(child: Text('Mobility tab body')),
      detailsTab: const Center(child: Text('Details tab body')),
      showBottomNav: false,
      onPopInvoked: () async {},
      onBack: () async {},
      onOpenTemplates: () {},
      onImportJson: () {},
      onExport: (_) {},
      onSave: () {},
    );
  }
}

/// Minimal screen that saves a new customer plan via [WorkoutBuilderRoutineCoordinator].
class _SaveNewPlanHarness extends StatefulWidget {
  const _SaveNewPlanHarness({required this.coordinator});

  final WorkoutBuilderRoutineCoordinator coordinator;

  @override
  State<_SaveNewPlanHarness> createState() => _SaveNewPlanHarnessState();
}

class _SaveNewPlanHarnessState extends State<_SaveNewPlanHarness> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () async {
            await widget.coordinator.saveRoutine(
              context: context,
              editorMode: true,
              customerId: 'c1',
              initialWeekNumber: 1,
              editorCustomer: null,
              selectedWeekIndex: 0,
              selectedDayIndex: 0,
            );
          },
          child: const Text('Salva'),
        ),
      ),
    );
  }
}

void main() {
  Widget app(Widget child) {
    return MaterialApp(
      theme: StitchM3Theme.light,
      darkTheme: StitchM3Theme.dark,
      themeMode: ThemeMode.dark,
      locale: const Locale('it'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    );
  }

  testWidgets('new customer plan editor shows first-save banner', (
    tester,
  ) async {
    await tester.pumpWidget(app(const _NewCustomerPlanEditorHarness()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(WorkoutBuilderFirstSaveBanner), findsOneWidget);
    expect(find.text('Salva ora'), findsOneWidget);
    expect(
      find.textContaining('Salva la scheda per associarla al cliente'),
      findsOneWidget,
    );
  });

  testWidgets('saving new plan creates local plan and replaces route', (
    tester,
  ) async {
    final createCalls = <Map<String, dynamic>>[];
    final session = WorkoutBuilderSessionController(
      routine: WorkoutRoutine.empty().copyWith(name: 'Scheda test'),
    );
    final nameController = TextEditingController(text: 'Scheda test');
    final initialWeekController = TextEditingController(text: '1');
    final editorController = WorkoutEditorController(
      createPlan: ({
        required customerId,
        required name,
        required planDataJson,
        pdfHeader,
        useCustomPdfHeader = false,
        initialWeekNumber = 1,
        phase,
        tags,
        notes,
      }) async {
        createCalls.add({
          'customerId': customerId,
          'name': name,
        });
        final now = DateTime(2026, 1, 1);
        return WorkoutPlanApiModel(
          id: 'plan-new-1',
          customerId: customerId,
          userId: 'user-1',
          name: name,
          planData: planDataJson,
          initialWeekNumber: initialWeekNumber,
          createdAt: now,
          updatedAt: now,
        );
      },
    );
    editorController.markLoaded(
      session: WorkoutEditorSession(
        routine: session.routine,
        planName: 'Scheda test',
        initialWeekNumber: 1,
      ),
      planId: null,
    );

    final coordinator = WorkoutBuilderRoutineCoordinator(
      builderSession: session,
      editorController: editorController,
      planRepo: WorkoutPlanRepository(),
      customerRepo: CustomerRepository(),
      draftStore: const SharedPrefsWorkoutDraftStore(),
      routineNameController: nameController,
      initialWeekController: initialWeekController,
      phaseController: TextEditingController(),
      tagsController: TextEditingController(),
      notesController: TextEditingController(),
    );

    addTearDown(() {
      nameController.dispose();
      initialWeekController.dispose();
      session.dispose();
      editorController.dispose();
    });

    late String currentLocation;
    final router = GoRouter(
      initialLocation: customerWorkoutEditorPath('c1'),
      routes: [
        GoRoute(
          path: '/customers/:customerId/workouts/new',
          builder: (_, __) => _SaveNewPlanHarness(coordinator: coordinator),
        ),
        GoRoute(
          path: '/customers/:customerId/workouts/:planId',
          builder: (_, state) {
            currentLocation = state.uri.toString();
            return Scaffold(
              body: Text('Plan ${state.pathParameters['planId']}'),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: StitchM3Theme.light,
        darkTheme: StitchM3Theme.dark,
        themeMode: ThemeMode.dark,
        locale: const Locale('it'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(createCalls, hasLength(1));
    expect(createCalls.single['customerId'], 'c1');
    expect(currentLocation, startsWith('/customers/c1/workouts/plan-new-1'));
    expect(find.text('Plan plan-new-1'), findsOneWidget);
  });
}
