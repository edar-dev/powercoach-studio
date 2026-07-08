import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../data/custom_exercise_item.dart';
import '../../data/pinned_exercises_store.dart';
import '../../data/custom_exercise_repository.dart';
import '../../domain/exercise_library_tree_helpers.dart';
import '../exercise_library_crud_handler.dart';
import '../exercise_library_export_handler.dart';
import '../exercise_library_import_handler.dart';
import '../widgets/exercise_library_tab_view.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _load();
    });
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerHighest,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: cs.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: Text(
          l10n.exerciseLibraryTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _loading ? null : _import,
            tooltip: l10n.exerciseLibraryImport,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _loading ? null : _export,
            tooltip: l10n.exerciseLibraryExport,
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
                  Tab(text: l10n.exerciseLibraryTabHevy),
                ],
              ),
              Container(color: cs.outline, height: 1),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ExerciseLibraryTabView(
            isMobility: false,
            loading: _loading,
            error: _error,
            allItemsEmpty: _items.isEmpty,
            onRefresh: _load,
            buildList: () => filterExerciseRootsByMobility(_items, false),
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
            onEdit: _crudHandler.showEditDialog,
            onDelete: _crudHandler.confirmDelete,
            onAddVariant: _crudHandler.showAddVariantDialog,
            onTogglePin: _togglePin,
            isPinned: (item) => _pinnedIds.contains(item.id),
          ),
          ExerciseLibraryTabView(
            isMobility: false,
            loading: _loading,
            error: _error,
            allItemsEmpty: filterHevyExerciseRoots(_items).isEmpty,
            onRefresh: _load,
            buildList: () => filterHevyExerciseRoots(_items),
            onEdit: _crudHandler.showEditDialog,
            onDelete: _crudHandler.confirmDelete,
            onAddVariant: _crudHandler.showAddVariantDialog,
            onTogglePin: _togglePin,
            isPinned: (item) => _pinnedIds.contains(item.id),
            readOnlyFolders: true,
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 2
          ? null
          : FloatingActionButton.extended(
              onPressed: _loading
                  ? null
                  : () => _crudHandler.showAddDialog(
                        isMobility: _tabController.index == 1,
                      ),
              icon: const Icon(Icons.add),
              label: Text(l10n.exerciseLibraryAddExercise),
              backgroundColor: StitchM3Theme.accent,
              foregroundColor: Colors.white,
            ),
    );
  }
}
