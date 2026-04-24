import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../../../widgets/app_snackbar.dart';
import '../../../../widgets/app_sheet.dart';
import '../../data/custom_exercise_item.dart';
import '../../data/custom_exercise_repository.dart';
import '../widgets/custom_exercise_edit_dialog.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen>
    with SingleTickerProviderStateMixin {
  final CustomExerciseRepository _exerciseRepo = CustomExerciseRepository();
  List<CustomExerciseItem> _items = [];
  bool _loading = true;
  String? _error;
  late final TabController _tabController;

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
      if (mounted) {
        setState(() {
          _items = items;
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
      final data = _flattenTree(roots)
          .map((e) => <String, dynamic>{
                'id': e.id,
                'name': e.name,
                'description': e.description,
                'parentId': e.parentId,
                'sortOrder': e.sortOrder,
                'isMobility': e.isMobility,
              })
          .toList();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      if (data.isEmpty) {
        showAppSnackBar(context, content: Text(l10n.exerciseLibraryExportEmpty));
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
        showAppSnackBar(
          context,
          content: Text(e.toString()),
        );
      }
    }
  }

  Future<void> _import() async {
    final isMobility = _tabController.index == 1;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    final l10n = AppLocalizations.of(context);
    final file = result.files.single;
    List<Map<String, dynamic>> items;
    try {
      String content;
      if (file.bytes != null) {
        content = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
      } else {
        content = '[]';
      }
      final decoded = jsonDecode(content);
      if (decoded is! List) {
        if (mounted) {
          showAppSnackBar(context, content: Text(l10n.exerciseLibraryImportInvalidFormat));
        }
        return;
      }
      items = decoded
          .map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
          .where((e) {
            final value = e['isMobility'];
            if (value is bool) return value == isMobility;
            // Backward compatibility: if missing, assume current tab type.
            return true;
          })
          .toList();
    } catch (_) {
      if (mounted) {
        showAppSnackBar(context, content: Text(l10n.exerciseLibraryImportInvalidFormat));
      }
      return;
    }
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
          final created = await _exerciseRepo.create(<String, dynamic>{
            'name': name,
            'description': item['description']?.toString(),
            if (parentId != null) 'parentId': parentId,
            'sortOrder': item['sortOrder'],
            'isMobility': isMobility,
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
            final created = await _exerciseRepo.create(<String, dynamic>{
              'name': name,
              'description': item['description']?.toString(),
              'sortOrder': item['sortOrder'],
              'isMobility': isMobility,
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

  static List<CustomExerciseItem> _flattenTree(List<CustomExerciseItem> roots) {
    final out = <CustomExerciseItem>[];
    void visit(CustomExerciseItem node) {
      out.add(node);
      for (final c in node.children) {
        visit(c);
      }
    }
    for (final r in roots) {
      visit(r);
    }
    return out;
  }

  /// Filters the tree so that the tab shows only exercises matching [isMobility].
  ///
  /// If a node doesn't match but some descendants do, we "lift" matching descendants
  /// to the current level. This avoids showing the wrong category while keeping
  /// the list readable.
  List<CustomExerciseItem> _filterRootsByMobility(bool isMobility) {
    final out = <CustomExerciseItem>[];
    for (final r in _items) {
      out.addAll(_filterNodeByMobility(r, isMobility));
    }
    return out;
  }

  List<CustomExerciseItem> _filterNodeByMobility(CustomExerciseItem node, bool isMobility) {
    final filteredChildren = <CustomExerciseItem>[];
    for (final c in node.children) {
      filteredChildren.addAll(_filterNodeByMobility(c, isMobility));
    }

    if (node.isMobility == isMobility) {
      return [
        CustomExerciseItem(
          id: node.id,
          name: node.name,
          description: node.description,
          parentId: node.parentId,
          sortOrder: node.sortOrder,
          isMobility: node.isMobility,
          createdAt: node.createdAt,
          updatedAt: node.updatedAt,
          rowVersion: node.rowVersion,
          children: filteredChildren,
        )
      ];
    }

    return filteredChildren;
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

  void _showAddDialogWithParent(String? parentId, {int? sortOrder, required bool isMobility}) {
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
        parentCandidates: _flattenTree(_items),
        onSave: (name, description, selectedParentId, isMobility) async {
          try {
            await _exerciseRepo.create({
              'name': name,
              if (description != null && description.isNotEmpty) 'description': description,
              if (selectedParentId != null && selectedParentId.isNotEmpty) 'parentId': selectedParentId,
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
    final parentCandidates =
        _flattenTree(_items).where((e) => !excludeIds.contains(e.id)).toList();
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
          _ExerciseLibraryTabView(
            isMobility: false,
            loading: _loading,
            error: _error,
            allItemsEmpty: _items.isEmpty,
            onRefresh: _load,
            buildList: () => _filterRootsByMobility(false),
            onEdit: _showEditDialog,
            onDelete: _confirmDelete,
            onAddVariant: _showAddVariantDialog,
          ),
          _ExerciseLibraryTabView(
            isMobility: true,
            loading: _loading,
            error: _error,
            allItemsEmpty: _items.isEmpty,
            onRefresh: _load,
            buildList: () => _filterRootsByMobility(true),
            onEdit: _showEditDialog,
            onDelete: _confirmDelete,
            onAddVariant: _showAddVariantDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : () => _showAddDialog(isMobility: _tabController.index == 1),
        icon: const Icon(Icons.add),
        label: Text(l10n.exerciseLibraryAddExercise),
        backgroundColor: StitchM3Theme.accent,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onAddVariant,
  });

  final CustomExerciseItem item;
  final void Function(CustomExerciseItem item) onEdit;
  final void Function(CustomExerciseItem item) onDelete;
  final void Function(CustomExerciseItem item) onAddVariant;

  @override
  Widget build(BuildContext context) {
    final hasChildren = item.children.isNotEmpty;
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(
          hasChildren ? Icons.folder_outlined : Icons.fitness_center_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(item.name),
        subtitle: item.description != null && item.description!.isNotEmpty
            ? Text(
                item.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'addVariant',
              child: Text(l10n.exerciseLibraryAddVariant),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Text(l10n.exerciseLibraryEdit),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(l10n.exerciseLibraryDelete),
            ),
          ],
          onSelected: (value) {
            if (value == 'addVariant') onAddVariant(item);
            if (value == 'edit') onEdit(item);
            if (value == 'delete') onDelete(item);
          },
        ),
        children: item.children
            .map(
              (child) => Padding(
                padding: const EdgeInsets.only(left: 24, right: 8, bottom: 4),
                child: _ExerciseTile(
                  item: child,
                  onEdit: onEdit,
                  onDelete: onDelete,
                  onAddVariant: onAddVariant,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ExerciseLibraryTabView extends StatelessWidget {
  const _ExerciseLibraryTabView({
    required this.isMobility,
    required this.loading,
    required this.error,
    required this.allItemsEmpty,
    required this.onRefresh,
    required this.buildList,
    required this.onEdit,
    required this.onDelete,
    required this.onAddVariant,
  });

  final bool isMobility;
  final bool loading;
  final String? error;
  final bool allItemsEmpty;

  final Future<void> Function() onRefresh;
  final List<CustomExerciseItem> Function() buildList;

  final void Function(CustomExerciseItem item) onEdit;
  final void Function(CustomExerciseItem item) onDelete;
  final void Function(CustomExerciseItem item) onAddVariant;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: onRefresh,
                      child: Text(l10n.exerciseLibraryRetry),
                    ),
                  ],
                ),
              ),
            )
          : loading && allItemsEmpty
              ? const Center(child: CircularProgressIndicator())
              : Builder(
                  builder: (context) {
                    final list = buildList();
                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fitness_center_outlined,
                              size: 64,
                              color: cs.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isMobility ? l10n.exerciseLibraryEmptyMobility : l10n.exerciseLibraryEmpty,
                              style: theme.textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isMobility ? l10n.exerciseLibraryEmptyMobilityHint : l10n.exerciseLibraryEmptyHint,
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ).copyWith(
                        bottom: 112,
                      ),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final it = list[index];
                        return _ExerciseTile(
                          item: it,
                          onEdit: onEdit,
                          onDelete: onDelete,
                          onAddVariant: onAddVariant,
                        );
                      },
                    );
                  },
                ),
    );
  }
}
