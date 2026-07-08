import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/app_snackbar.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import '../../data/custom_exercise_item.dart';
import '../../data/pinned_exercises_store.dart';
import '../../data/custom_exercise_repository.dart';
import '../../domain/exercise_library_tree_helpers.dart';
import '../exercise_library_import_handler.dart';
import 'package:powercoach_studio/features/exercise_library/presentation/widgets/custom_exercise_edit_dialog.dart';
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

  Future<void> _export() async {
    try {
      final isMobility = _tabController.index == 1;
      final roots = await _exerciseRepo.getTree(mobility: isMobility);
      final data = flattenExerciseTree(roots)
          .map(
            (e) => <String, dynamic>{
              'id': e.id,
              'name': e.name,
              'description': e.description,
              'parentId': e.parentId,
              'sortOrder': e.sortOrder,
              'isMobility': e.isMobility,
            },
          )
          .toList();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      if (data.isEmpty) {
        showAppSnackBar(
          context,
          content: Text(l10n.exerciseLibraryExportEmpty),
        );
        return;
      }
      final json = const JsonEncoder.withIndent('  ').convert(data);
      final name =
          'custom-exercises-${isMobility ? 'mobility' : 'standard'}-${DateTime.now().toIso8601String().split('T').first}.json';
      await Share.share(
        json,
        subject: name,
        sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
      );
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, content: Text(e.toString()));
      }
    }
  }

  Future<void> _import() => _importHandler.showImportSheet();

  void _showAddDialog({required bool isMobility}) {
    _showAddDialogWithParent(null, isMobility: isMobility);
  }

  void _showAddVariantDialog(CustomExerciseItem parent) {
    _showAddDialogWithParent(
      parent.id,
      sortOrder: parent.children.length,
      isMobility: parent.isMobility,
    );
  }

  void _showAddDialogWithParent(
    String? parentId, {
    int? sortOrder,
    required bool isMobility,
  }) {
    final l10n = AppLocalizations.of(context);
    showAppBottomSheet<void>(
      context: context,
      title: l10n.exerciseLibraryAddExercise,
      fullScreen: false,
      bodyBuilder: (sheetContext) => CustomExerciseEditDialog(
        title: l10n.exerciseLibraryAddExercise,
        name: '',
        description: null,
        isMobility: isMobility,
        parentId: parentId,
        parentCandidates: flattenExerciseTree(_items),
        onSave: (name, description, selectedParentId, isMobility) async {
          try {
            await _exerciseRepo.create({
              'name': name,
              if (description != null && description.isNotEmpty)
                'description': description,
              if (selectedParentId != null && selectedParentId.isNotEmpty)
                'parentId': selectedParentId,
              if (sortOrder != null) 'sortOrder': sortOrder,
              'isMobility': isMobility,
            });
            if (sheetContext.mounted) {
              Navigator.of(sheetContext).pop();
              _load();
            }
          } catch (e) {
            if (sheetContext.mounted) {
              ScaffoldMessenger.of(sheetContext).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        onCancel: () => Navigator.of(sheetContext).pop(),
      ),
    );
  }

  void _showEditDialog(CustomExerciseItem item) {
    final l10n = AppLocalizations.of(context);
    final excludeIds = {item.id, ...item.flat.map((e) => e.id)};
    final parentCandidates = flattenExerciseTree(
      _items,
    ).where((e) => !excludeIds.contains(e.id)).toList();
    showAppBottomSheet<void>(
      context: context,
      title: l10n.exerciseLibraryEditExercise,
      fullScreen: false,
      bodyBuilder: (sheetContext) => CustomExerciseEditDialog(
        title: l10n.exerciseLibraryEditExercise,
        name: item.name,
        description: item.description,
        isMobility: item.isMobility,
        parentId: item.parentId,
        parentCandidates: parentCandidates,
        onSave: (name, description, parentId, isMobility) async {
          try {
            await _exerciseRepo.update(item.id, {
              'name': name,
              'description': description?.isEmpty == true ? null : description,
              'parentId': parentId?.isEmpty == true ? null : parentId,
              'isMobility': isMobility,
              'expectedRowVersion': item.rowVersion,
            });
            if (sheetContext.mounted) {
              Navigator.of(sheetContext).pop();
              _load();
            }
          } catch (e) {
            if (sheetContext.mounted) {
              ScaffoldMessenger.of(sheetContext).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        onCancel: () => Navigator.of(sheetContext).pop(),
      ),
    );
  }

  void _confirmDelete(CustomExerciseItem item) {
    final l10n = AppLocalizations.of(context);
    final hasChildren = item.children.isNotEmpty;
    final message = hasChildren
        ? l10n.exerciseLibraryDeleteHasChildren
        : l10n.exerciseLibraryDeleteConfirm(item.name);
    if (hasChildren) {
      showAppBottomSheet<void>(
        context: context,
        title: l10n.exerciseLibraryDeleteTitle,
        bodyBuilder: (_) => Text(message),
        primaryActionLabel: l10n.exerciseLibraryCancel,
        onPrimaryAction: () => Navigator.of(context).pop(),
      );
      return;
    }

    showAppConfirmDialog(
      context: context,
      title: l10n.exerciseLibraryDeleteTitle,
      message: message,
      confirmLabel: l10n.exerciseLibraryDelete,
      cancelLabel: l10n.exerciseLibraryCancel,
      destructive: true,
    ).then((confirmed) async {
      if (!confirmed) return;
      try {
        await _exerciseRepo.delete(item.id);
        if (mounted) _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
  }

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
            onEdit: _showEditDialog,
            onDelete: _confirmDelete,
            onAddVariant: _showAddVariantDialog,
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
            onEdit: _showEditDialog,
            onDelete: _confirmDelete,
            onAddVariant: _showAddVariantDialog,
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
            onEdit: _showEditDialog,
            onDelete: _confirmDelete,
            onAddVariant: _showAddVariantDialog,
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
                  : () => _showAddDialog(isMobility: _tabController.index == 1),
              icon: const Icon(Icons.add),
              label: Text(l10n.exerciseLibraryAddExercise),
              backgroundColor: StitchM3Theme.accent,
              foregroundColor: Colors.white,
            ),
    );
  }
}
