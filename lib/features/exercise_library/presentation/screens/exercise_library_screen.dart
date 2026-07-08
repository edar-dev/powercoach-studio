import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/app_snackbar.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import '../../data/custom_exercise_item.dart';
import '../../data/import_file_reader.dart';
import '../../data/pinned_exercises_store.dart';
import '../../data/custom_exercise_repository.dart';
import '../../data/default_exercise_catalog.dart';
import '../../../integrations/hevy/data/hevy_api_models.dart';
import '../../../integrations/hevy/data/hevy_catalog_import_service.dart';
import '../../../integrations/hevy/data/hevy_settings_store.dart';
import '../../../integrations/hevy/domain/exercise_catalog_source.dart';
import '../../domain/exercise_library_tree_helpers.dart';
import 'package:powercoach_studio/features/exercise_library/presentation/widgets/custom_exercise_edit_dialog.dart';
import '../widgets/exercise_library_import_source_sheet.dart';
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

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    showAppBottomSheet<void>(
      context: context,
      title: l10n.exerciseLibraryImportSourceTitle,
      bodyBuilder: (sheetContext) => ExerciseLibraryImportSourceSheet(
        onImportDefault: () {
          Navigator.of(sheetContext).pop();
          _importDefaultCatalog();
        },
        onImportHevy: () {
          Navigator.of(sheetContext).pop();
          _importHevyCatalog();
        },
        onImportCustomFile: () {
          Navigator.of(sheetContext).pop();
          _importCustomFile();
        },
      ),
    );
  }

  Future<void> _importHevyCatalog() async {
    final l10n = AppLocalizations.of(context);
    final hasKey = await HevySettingsStore.instance.hasApiKey();
    if (!hasKey) {
      if (!mounted) return;
      showAppSnackBar(context, content: Text(l10n.hevyExportNoCatalogHint));
      return;
    }
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        var label = l10n.hevyImportInProgress;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.exerciseLibraryImportSourceHevy),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(label),
                ],
              ),
            );
          },
        );
      },
    );
    try {
      final count = await HevyCatalogImportService().importAllFromApi(
        onProgress: (current, total, progressLabel) {
          // Dialog progress label updates are best-effort
        },
      );
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      showAppSnackBar(
        context,
        content: Text(l10n.hevyImportSuccessCount(count)),
      );
      await _load();
    } on HevyApiException catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      showAppSnackBar(context, content: Text(l10n.hevyImportFailed(e.message)));
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      showAppSnackBar(
        context,
        content: Text(l10n.hevyImportFailed(e.toString())),
      );
    }
  }

  Future<void> _importDefaultCatalog() async {
    final l10n = AppLocalizations.of(context);
    final defaults = buildDefaultExerciseCatalogJson();
    await _importItems(
      defaults,
      l10n: l10n,
      fallbackMobilityWhenMissing: false,
      catalogSource: ExerciseCatalogSource.powercoach,
    );
  }

  Future<void> _importCustomFile() async {
    final isMobility = _tabController.index == 1;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    final file = result.files.single;
    List<Map<String, dynamic>> items;
    try {
      String content;
      if (file.bytes != null) {
        content = utf8.decode(file.bytes!);
      } else if (!kIsWeb && file.path != null) {
        content = await readImportFileFromPath(file.path!);
      } else {
        content = '[]';
      }
      final decoded = jsonDecode(content);
      if (decoded is! List) {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          showAppSnackBar(
            context,
            content: Text(l10n.exerciseLibraryImportInvalidFormat),
          );
        }
        return;
      }
      items = decoded
          .map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
          .toList();
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        showAppSnackBar(
          context,
          content: Text(l10n.exerciseLibraryImportInvalidFormat),
        );
      }
      return;
    }
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    await _importItems(
      items,
      l10n: l10n,
      fallbackMobilityWhenMissing: isMobility,
    );
  }

  Future<void> _importItems(
    List<Map<String, dynamic>> items, {
    required AppLocalizations l10n,
    required bool fallbackMobilityWhenMissing,
    String catalogSource = ExerciseCatalogSource.manual,
  }) async {
    final importedByLegacyId = <String, String>{};
    var importedCount = 0;
    try {
      final pending = List<Map<String, dynamic>>.from(items);
      while (pending.isNotEmpty) {
        var createdInPass = 0;
        final unresolvedForNextPass = <Map<String, dynamic>>[];
        for (final item in pending) {
          final name = item['name']?.toString().trim() ?? '';
          if (name.isEmpty) continue;

          final rawParentId = item['parentId']?.toString();
          final hasParent = rawParentId != null && rawParentId.isNotEmpty;
          if (hasParent && !importedByLegacyId.containsKey(rawParentId)) {
            unresolvedForNextPass.add(item);
            continue;
          }

          final parentId = hasParent ? importedByLegacyId[rawParentId] : null;
          final rawMobility = item['isMobility'];
          final itemIsMobility = rawMobility is bool
              ? rawMobility
              : fallbackMobilityWhenMissing;
          final created = await _exerciseRepo.create(<String, dynamic>{
            'name': name,
            'description': item['description']?.toString(),
            if (parentId != null) 'parentId': parentId,
            'sortOrder': item['sortOrder'],
            'isMobility': itemIsMobility,
            'catalogSource': catalogSource,
          });
          final legacyId = item['id']?.toString();
          if (legacyId != null && legacyId.isNotEmpty) {
            importedByLegacyId[legacyId] = created['id']?.toString() ?? '';
          }
          importedCount++;
          createdInPass++;
        }

        if (createdInPass == 0) {
          // Fallback: break potential cycles/invalid parents by importing remaining as roots.
          for (final item in unresolvedForNextPass) {
            final name = item['name']?.toString().trim() ?? '';
            if (name.isEmpty) continue;
            final rawMobility = item['isMobility'];
            final itemIsMobility = rawMobility is bool
                ? rawMobility
                : fallbackMobilityWhenMissing;
            final created = await _exerciseRepo.create(<String, dynamic>{
              'name': name,
              'description': item['description']?.toString(),
              'sortOrder': item['sortOrder'],
              'isMobility': itemIsMobility,
              'catalogSource': catalogSource,
            });
            final legacyId = item['id']?.toString();
            if (legacyId != null && legacyId.isNotEmpty) {
              importedByLegacyId[legacyId] = created['id']?.toString() ?? '';
            }
            importedCount++;
          }
          break;
        }

        pending
          ..clear()
          ..addAll(unresolvedForNextPass);
      }
      if (mounted) {
        showAppSnackBar(
          context,
          content: Text(l10n.exerciseLibraryImportSuccessCount(importedCount)),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, content: Text(e.toString()));
      }
    }
  }

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
