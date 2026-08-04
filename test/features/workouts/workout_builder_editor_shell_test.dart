import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_builder_editor_shell.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

class _ShellHarness extends StatefulWidget {
  const _ShellHarness({
    required this.showsMobilityTab,
    this.showFirstSaveBanner = false,
  });

  final bool showsMobilityTab;
  final bool showFirstSaveBanner;

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
      editorMode: false,
      loading: false,
      hideExportMenu: false,
      showsMobilityTab: widget.showsMobilityTab,
      sectionTabController: _tabController,
      routineNameController: _nameController,
      trainingTab: const Center(child: Text('Training tab body')),
      mobilityTab: const Center(child: Text('Mobility tab body')),
      detailsTab: const Center(child: Text('Details tab body')),
      showBottomNav: true,
      onPopInvoked: () async {},
      onBack: () async {},
      onOpenTemplates: () {},
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
        GoRoute(path: '/', builder: (_, __) => child),
        GoRoute(
          path: '/workouts/templates',
          builder: (_, __) => const Scaffold(body: Text('Templates')),
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
      find.textContaining('Salva la scheda per associarla al cliente'),
      findsOneWidget,
    );
  });
}
