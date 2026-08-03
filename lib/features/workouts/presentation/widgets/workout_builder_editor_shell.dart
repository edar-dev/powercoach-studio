import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_builder_bottom_nav.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_builder_first_save_banner.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_editor_app_bar.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_lazy_tab.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_routine_name_bar.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

class WorkoutBuilderEditorShell extends StatelessWidget {
  const WorkoutBuilderEditorShell({
    super.key,
    required this.canPop,
    required this.saving,
    required this.showManualSaveButton,
    required this.saveStatusIndicator,
    required this.editorMode,
    required this.loading,
    required this.hideExportMenu,
    required this.showsMobilityTab,
    required this.sectionTabController,
    required this.routineNameController,
    required this.trainingTab,
    required this.mobilityTab,
    required this.detailsTab,
    required this.showBottomNav,
    required this.onPopInvoked,
    required this.onBack,
    required this.onOpenTemplates,
    required this.onImportJson,
    required this.onExport,
    required this.onSave,
    this.showFirstSaveBanner = false,
    this.showSandboxBanner = false,
    this.showReadOnlyBanner = false,
    this.sandboxBanner,
    this.readOnlyBanner,
    this.onboardingCard,
  });

  final bool canPop;
  final bool saving;
  final bool showManualSaveButton;
  final Widget? saveStatusIndicator;
  final bool editorMode;
  final bool loading;
  final bool hideExportMenu;
  final bool showsMobilityTab;
  final TabController sectionTabController;
  final TextEditingController routineNameController;
  final Widget trainingTab;
  final Widget mobilityTab;
  final Widget detailsTab;
  final bool showBottomNav;
  final Future<void> Function() onPopInvoked;
  final Future<void> Function() onBack;
  final VoidCallback onOpenTemplates;
  final VoidCallback onImportJson;
  final void Function(String value) onExport;
  final VoidCallback onSave;
  final bool showFirstSaveBanner;
  final bool showSandboxBanner;
  final bool showReadOnlyBanner;
  final Widget? sandboxBanner;
  final Widget? readOnlyBanner;
  final Widget? onboardingCard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await onPopInvoked();
      },
      child: Scaffold(
        appBar: WorkoutEditorAppBar(
          theme: theme,
          colorScheme: cs,
          l10n: l10n,
          editorMode: editorMode,
          loading: loading,
          hideExportMenu: hideExportMenu,
          saving: saving,
          showManualSaveButton: showManualSaveButton,
          onBack: () async {
            HapticFeedback.mediumImpact();
            await onBack();
          },
          onOpenTemplates: () {
            HapticFeedback.mediumImpact();
            navigateTo(context, '/workouts/templates');
          },
          onImportJson: onImportJson,
          onExport: onExport,
          onSave: onSave,
          saveStatusIndicator: saveStatusIndicator,
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (showSandboxBanner && sandboxBanner != null) sandboxBanner!,
                  if (showReadOnlyBanner && readOnlyBanner != null) readOnlyBanner!,
                  if (onboardingCard != null) onboardingCard!,
                  if (showFirstSaveBanner)
                    WorkoutBuilderFirstSaveBanner(onSave: onSave),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                    child: WorkoutRoutineNameBar(
                      controller: routineNameController,
                      l10n: l10n,
                      readOnly: showReadOnlyBanner,
                    ),
                  ),
                  TabBar(
                    controller: sectionTabController,
                    labelColor: StitchM3Theme.accent,
                    unselectedLabelColor: cs.onSurfaceVariant,
                    indicatorColor: StitchM3Theme.accent,
                    tabs: [
                      Tab(text: l10n.workoutBuilderTabTraining),
                      if (showsMobilityTab)
                        Tab(text: l10n.workoutBuilderTabMobility),
                      Tab(text: l10n.workoutBuilderTabDetails),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: sectionTabController,
                      children: [
                        WorkoutLazyTab(
                          tabController: sectionTabController,
                          tabIndex: 0,
                          builder: (_) =>
                              RepaintBoundary(child: trainingTab),
                        ),
                        if (showsMobilityTab)
                          WorkoutLazyTab(
                            tabController: sectionTabController,
                            tabIndex: 1,
                            builder: (_) =>
                                RepaintBoundary(child: mobilityTab),
                          ),
                        WorkoutLazyTab(
                          tabController: sectionTabController,
                          tabIndex: showsMobilityTab ? 2 : 1,
                          builder: (_) => detailsTab,
                        ),
                      ],
                    ),
                  ),
                  if (showBottomNav)
                    WorkoutBuilderBottomNav(
                      navContext: context,
                      selectedIndex: 0,
                    ),
                ],
              ),
      ),
    );
  }
}
