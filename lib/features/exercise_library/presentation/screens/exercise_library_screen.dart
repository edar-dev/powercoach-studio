import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/routing/app_paths.dart';
import '../../../../core/routing/hub_chrome.dart';
import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../core/ui/widgets/stitch_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/custom_exercise_item.dart';
import '../../data/pinned_exercises_store.dart';
import '../../data/custom_exercise_repository.dart';
import '../../domain/exercise_library_muscle_filter.dart';
import '../../domain/exercise_library_tree_helpers.dart';
import '../exercise_library_clear_handler.dart';
import '../exercise_library_crud_handler.dart';
import '../exercise_library_export_handler.dart';
import '../exercise_library_import_handler.dart';
import '../widgets/exercise_library_page_header.dart';
import '../widgets/exercise_library_tab_view.dart';
import '../widgets/exercise_library_toolbar.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen>
    with SingleTickerProviderStateMixin {
  final CustomExerciseRepository _exerciseRepo = CustomExerciseRepository();
  final PinnedExercisesStore _pinnedStore = PinnedExercisesStore.instance;
  List<CustomExerciseItem> _items = [];
  Set<String> _pinnedIds = <String>{};
  bool _loading = true;
  String? _error;
  late final TabController _tabController;

  String _searchQuery = '';
  String? _lastRouteSearchQ;
  ExerciseLibraryMuscleGroup _muscleFilter = ExerciseLibraryMuscleGroup.all;
  ExerciseLibrarySortMode _sortMode = ExerciseLibrarySortMode.alphabetical;
  ExerciseLibraryViewMode _viewMode = ExerciseLibraryViewMode.grid;

  ExerciseLibraryImportHandler get _importHandler => ExerciseLibraryImportHandler(
        context: context,
        onReload: _load,
        isMobilityTab: () => _tabController.index == 1,
      );

  ExerciseLibraryCrudHandler get _crudHandler => ExerciseLibraryCrudHandler(
        context: context,
        exerciseRepo: _exerciseRepo,
        items: () => _items,
        onReload: _load,
      );

  ExerciseLibraryExportHandler get _exportHandler => ExerciseLibraryExportHandler(
        context: context,
        exerciseRepo: _exerciseRepo,
      );

  ExerciseLibraryClearHandler get _clearHandler => ExerciseLibraryClearHandler(
        context: context,
        exerciseRepo: _exerciseRepo,
        pinnedStore: _pinnedStore,
        onReload: _load,
      );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _load();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Shell global search seeds the local filter via `?q=` (no backend index).
    final q = GoRouterState.of(context).uri.queryParameters['q'] ?? '';
    if (q == _lastRouteSearchQ) return;
    _lastRouteSearchQ = q;
    if (q != _searchQuery) {
      _searchQuery = q;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _exerciseRepo.getTree();
      final pinned = await _pinnedStore.getPinnedIds();
      if (mounted) {
        setState(() {
          _items = items;
          _pinnedIds = pinned;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
          _items = [];
        });
      }
    }
  }

  Future<void> _export() => _exportHandler.export(
        isMobility: _tabController.index == 1,
      );

  Future<void> _import() => _importHandler.showImportSheet();

  Future<void> _togglePin(CustomExerciseItem item) async {
    await _pinnedStore.toggle(item.id);
    if (!mounted) return;
    final latest = await _pinnedStore.getPinnedIds();
    if (!mounted) return;
    setState(() => _pinnedIds = latest);
  }

  void _openNewExercise() {
    HapticFeedback.mediumImpact();
    _crudHandler.showAddDialog(isMobility: _tabController.index == 1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final slimHub = primaryShellUsesRail(context);
    final showToolbar = !_loading && _error == null;

    return Scaffold(
      backgroundColor: hubPageBackground(context),
      appBar: StitchAppBar(
        title: l10n.exerciseLibraryTitle,
        showLogo: !slimHub,
        showTitle: !slimHub,
        actions: [
          if (!slimHub)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: l10n.settingsTitle,
              onPressed: () {
                HapticFeedback.mediumImpact();
                navigateTo(context, AppPaths.settings);
              },
            ),
          PopupMenuButton<String>(
            enabled: !_loading,
            icon: const Icon(Icons.more_vert),
            color: MarketingDarkColors.surface800,
            onSelected: (value) {
              if (value == 'import') {
                _import();
              } else if (value == 'export') {
                _export();
              } else if (value == 'clear') {
                _clearHandler.confirmAndClear();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'import',
                child: Text(
                  l10n.exerciseLibraryImport,
                  style: const TextStyle(color: MarketingDarkColors.text),
                ),
              ),
              PopupMenuItem(
                value: 'export',
                child: Text(
                  l10n.exerciseLibraryExport,
                  style: const TextStyle(color: MarketingDarkColors.text),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'clear',
                child: Text(
                  l10n.exerciseLibraryClearAll,
                  style: const TextStyle(color: StitchM3Theme.danger),
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: l10n.exerciseLibraryTabExercises),
                  Tab(text: l10n.exerciseLibraryTabMobilityExercises),
                ],
              ),
              Container(color: cs.outline, height: 1),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (slimHub)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: ExerciseLibraryPageHeader(
                onNewExercise: _loading ? null : _openNewExercise,
              ),
            ),
          if (showToolbar)
            ExerciseLibraryToolbar(
              searchQuery: _searchQuery,
              muscleFilter: _muscleFilter,
              sortMode: _sortMode,
              viewMode: _viewMode,
              onSearchChanged: (v) => setState(() => _searchQuery = v),
              onMuscleFilterSelected: (f) =>
                  setState(() => _muscleFilter = f),
              onSortChanged: (s) => setState(() => _sortMode = s),
              onViewModeChanged: (m) => setState(() => _viewMode = m),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ExerciseLibraryTabView(
                  isMobility: false,
                  loading: _loading,
                  error: _error,
                  allItemsEmpty: _items.isEmpty,
                  onRefresh: _load,
                  buildList: () => filterExerciseRootsByMobility(_items, false),
                  searchQuery: _searchQuery,
                  muscleFilter: _muscleFilter,
                  sortMode: _sortMode,
                  viewMode: _viewMode,
                  onEdit: _crudHandler.showEditDialog,
                  onDelete: _crudHandler.confirmDelete,
                  onAddVariant: _crudHandler.showAddVariantDialog,
                  onTogglePin: _togglePin,
                  isPinned: (item) => _pinnedIds.contains(item.id),
                ),
                ExerciseLibraryTabView(
                  isMobility: true,
                  loading: _loading,
                  error: _error,
                  allItemsEmpty: _items.isEmpty,
                  onRefresh: _load,
                  buildList: () => filterExerciseRootsByMobility(_items, true),
                  searchQuery: _searchQuery,
                  muscleFilter: _muscleFilter,
                  sortMode: _sortMode,
                  viewMode: _viewMode,
                  onEdit: _crudHandler.showEditDialog,
                  onDelete: _crudHandler.confirmDelete,
                  onAddVariant: _crudHandler.showAddVariantDialog,
                  onTogglePin: _togglePin,
                  isPinned: (item) => _pinnedIds.contains(item.id),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: slimHub
          ? null
          : FloatingActionButton.extended(
              onPressed: _loading ? null : _openNewExercise,
              icon: const Icon(Icons.add),
              label: Text(l10n.exerciseLibraryAddExercise),
              backgroundColor: StitchM3Theme.accent,
              foregroundColor: Colors.white,
            ),
    );
  }
}
