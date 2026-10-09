import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_builder_editor_shell.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_builder_sandbox_banner.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

class _ShellHarness extends StatefulWidget {
  const _ShellHarness({
    required this.showsMobilityTab,
    this.showFirstSaveBanner = false,
    this.showSandboxBanner = false,
    this.editorMode = false,
    this.editorCustomerName,
    this.hasLoadedPlan = false,
    this.onAssignToCustomer,
  });

  final bool showsMobilityTab;
  final bool showFirstSaveBanner;
  final bool showSandboxBanner;
  final bool editorMode;
  final String? editorCustomerName;
  final bool hasLoadedPlan;
  final VoidCallback? onAssignToCustomer;

  @override
  State<_ShellHarness> createState() => _ShellHarnessState();
}

class _ShellHarnessState extends State<_ShellHarness>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.showsMobilityTab ? 3 : 2,
      vsync: this,
    );
    _nameController = TextEditingController(text: 'Programma test');
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
      showFirstSaveBanner: widget.showFirstSaveBanner,
      saveStatusIndicator: null,
      editorMode: widget.editorMode,
      loading: false,
      hideExportMenu: false,
      showsMobilityTab: widget.showsMobilityTab,
      sectionTabController: _tabController,
      routineNameController: _nameController,
      trainingTab: const Center(child: Text('Training tab body')),
      mobilityTab: const Center(child: Text('Mobility tab body')),
      detailsTab: const Center(child: Text('Details tab body')),
      showBottomNav: !widget.editorMode,
      editorCustomerName: widget.editorCustomerName,
      hasLoadedPlan: widget.hasLoadedPlan,
      sandboxBanner: widget.showSandboxBanner
          ? WorkoutBuilderSandboxBanner(
              onAssignToCustomer: widget.onAssignToCustomer ?? () {},
            )
          : null,
      onPopInvoked: () async {},
      onBack: () async {},
      onImportJson: () {},
      onExport: (_) {},
      onSave: () {},
    );
  }
}

void main() {
  Widget app(Widget child) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => child),
        GoRoute(
          path: '/workouts/builder',
          builder: (_, _) => const Scaffold(body: Text('Builder')),
        ),
        GoRoute(
          path: '/exercise-library',
          builder: (_, _) => const Scaffold(body: Text('Library')),
        ),
        GoRoute(
          path: '/settings/personal-info',
          builder: (_, _) => const Scaffold(body: Text('Profile')),
        ),
      ],
    );
    return MaterialApp.router(
      theme: StitchM3Theme.light,
      darkTheme: StitchM3Theme.dark,
      themeMode: ThemeMode.dark,
      locale: const Locale('it'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
    );
  }

  testWidgets('WorkoutBuilderEditorShell shows training and mobility tabs', (
    tester,
  ) async {
    await tester.pumpWidget(app(const _ShellHarness(showsMobilityTab: true)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Programma test'), findsOneWidget);
    expect(find.text('Allenamento'), findsOneWidget);
    expect(find.text('Mobilità'), findsOneWidget);
    expect(find.text('Dettagli'), findsOneWidget);
    expect(find.text('Training tab body'), findsOneWidget);
  });

  testWidgets('WorkoutBuilderEditorShell hides mobility tab when disabled', (
    tester,
  ) async {
    await tester.pumpWidget(app(const _ShellHarness(showsMobilityTab: false)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Allenamento'), findsOneWidget);
    expect(find.text('Mobilità'), findsNothing);
    expect(find.text('Dettagli'), findsOneWidget);
  });

  testWidgets('WorkoutBuilderEditorShell shows first-save banner when enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const _ShellHarness(
          showsMobilityTab: true,
          showFirstSaveBanner: true,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Salva ora'), findsOneWidget);
    expect(
      find.textContaining(
        'Salva ora per collegare la scheda al cliente',
      ),
      findsOneWidget,
    );
  });

  testWidgets('sandbox mode shows distinct draft builder title', (tester) async {
    await tester.pumpWidget(app(const _ShellHarness(showsMobilityTab: true)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Builder bozza'), findsOneWidget);
    expect(find.text('Editor scheda'), findsNothing);
  });

  testWidgets('editor mode shows assigned badge only after plan is loaded', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const _ShellHarness(
          showsMobilityTab: true,
          editorMode: true,
          editorCustomerName: 'Mario Rossi',
          hasLoadedPlan: true,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Editor scheda'), findsOneWidget);
    expect(find.text('Builder bozza'), findsNothing);
    expect(find.text('Piano assegnato · Mario Rossi'), findsOneWidget);
  });

  testWidgets('new customer plan hides assigned badge while first-save shows', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const _ShellHarness(
          showsMobilityTab: true,
          editorMode: true,
          editorCustomerName: 'Mario Rossi',
          hasLoadedPlan: false,
          showFirstSaveBanner: true,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Editor scheda'), findsOneWidget);
    expect(find.text('Piano assegnato · Mario Rossi'), findsNothing);
    expect(find.text('Salva ora'), findsOneWidget);
  });

  testWidgets('sandbox shell wires banner and assign CTA', (tester) async {
    var assigned = false;
    await tester.pumpWidget(
      app(
        _ShellHarness(
          showsMobilityTab: true,
          showSandboxBanner: true,
          onAssignToCustomer: () => assigned = true,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.text('Bozza locale su questo dispositivo — non è sul cliente'),
      findsOneWidget,
    );
    expect(find.byType(FilledButton), findsWidgets);
    await tester.tap(find.widgetWithText(FilledButton, 'Assegna a cliente'));
    await tester.pump();
    expect(assigned, isTrue);
  });
}
