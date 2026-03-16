import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/network/gymblog_api_client.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../data/custom_exercise_item.dart';
import '../widgets/custom_exercise_edit_dialog.dart';

const _basePath = '/api/custom-exercises';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final GymBlogApiClient _api = GymBlogApiClient();
  List<CustomExerciseItem> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!GymBlogApiClient.isConfigured) {
      setState(() {
        _loading = false;
        _error = null;
        _items = [];
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _api.getList(
        _basePath,
        queryParameters: {'tree': 'true'},
      );
      final items = list
          .whereType<Map<String, dynamic>>()
          .map((e) => CustomExerciseItem.fromJson(e))
          .toList();
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
          _error = e is GymBlogApiException ? e.message : e.toString();
          _items = [];
        });
      }
    }
  }

  Future<void> _export() async {
    if (!GymBlogApiClient.isConfigured) return;
    try {
      final list = await _api.getList('$_basePath/export');
      final data = list.whereType<Map<String, dynamic>>().toList();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      if (data.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exerciseLibraryExportEmpty)),
        );
        return;
      }
      final json = const JsonEncoder.withIndent('  ').convert(data);
      final name =
          'custom-exercises-${DateTime.now().toIso8601String().split('T').first}.json';
      await Share.share(
        json,
        subject: name,
        sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is GymBlogApiException ? e.message : e.toString()),
          ),
        );
      }
    }
  }

  Future<void> _import() async {
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
      final content = file.bytes != null ? utf8.decode(file.bytes!) : '[]';
      final decoded = jsonDecode(content);
      if (decoded is! List) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.exerciseLibraryImportInvalidFormat)),
          );
        }
        return;
      }
      items = decoded
          .map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
          .toList();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exerciseLibraryImportInvalidFormat)),
        );
      }
      return;
    }
    if (!GymBlogApiClient.isConfigured) return;
    try {
      await _api.post('$_basePath/import', items);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exerciseLibraryImportSuccess)),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is GymBlogApiException ? e.message : e.toString()),
          ),
        );
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

  void _showAddDialog() {
    _showAddDialogWithParent(null);
  }

  void _showAddVariantDialog(CustomExerciseItem parent) {
    _showAddDialogWithParent(parent.id, sortOrder: parent.children.length);
  }

  void _showAddDialogWithParent(String? parentId, {int? sortOrder}) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => CustomExerciseEditDialog(
        title: l10n.exerciseLibraryAddExercise,
        name: '',
        description: null,
        parentId: parentId,
        parentCandidates: _flattenTree(_items),
        onSave: (name, description, selectedParentId) async {
          try {
            await _api.post(_basePath, {
              'name': name,
              if (description != null && description.isNotEmpty) 'description': description,
              if (selectedParentId != null && selectedParentId.isNotEmpty) 'parentId': selectedParentId,
              if (sortOrder != null) 'sortOrder': sortOrder,
            });
            if (ctx.mounted) {
              Navigator.of(ctx).pop();
              _load();
            }
          } catch (e) {
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(
                    e is GymBlogApiException ? e.message : e.toString(),
                  ),
                ),
              );
            }
          }
        },
        onCancel: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _showEditDialog(CustomExerciseItem item) {
    final l10n = AppLocalizations.of(context);
    final excludeIds = {item.id, ...item.flat.map((e) => e.id)};
    final parentCandidates =
        _flattenTree(_items).where((e) => !excludeIds.contains(e.id)).toList();
    showDialog<void>(
      context: context,
      builder: (ctx) => CustomExerciseEditDialog(
        title: l10n.exerciseLibraryEditExercise,
        name: item.name,
        description: item.description,
        parentId: item.parentId,
        parentCandidates: parentCandidates,
        onSave: (name, description, parentId) async {
          try {
            await _api.put('$_basePath/${item.id}', {
              'name': name,
              'description': description?.isEmpty == true ? null : description,
              'parentId': parentId?.isEmpty == true ? null : parentId,
            });
            if (ctx.mounted) {
              Navigator.of(ctx).pop();
              _load();
            }
          } catch (e) {
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(
                    e is GymBlogApiException ? e.message : e.toString(),
                  ),
                ),
              );
            }
          }
        },
        onCancel: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _confirmDelete(CustomExerciseItem item) {
    final l10n = AppLocalizations.of(context);
    final hasChildren = item.children.isNotEmpty;
    final message = hasChildren
        ? l10n.exerciseLibraryDeleteHasChildren
        : l10n.exerciseLibraryDeleteConfirm(item.name);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.exerciseLibraryDeleteTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.exerciseLibraryCancel),
          ),
          if (!hasChildren)
            FilledButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                try {
                  await _api.delete('$_basePath/${item.id}');
                  if (mounted) _load();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e is GymBlogApiException ? e.message : e.toString(),
                        ),
                      ),
                    );
                  }
                }
              },
              child: Text(l10n.exerciseLibraryDelete),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (!GymBlogApiClient.isConfigured) {
      return Scaffold(
        backgroundColor: cs.surfaceContainerHighest,
        appBar: AppBar(
          elevation: 0,
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
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.customersApiNotConfigured,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

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
          preferredSize: const Size.fromHeight(1),
          child: Container(color: cs.outline, height: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading && _items.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _load,
                            child: Text(l10n.exerciseLibraryRetry),
                          ),
                        ],
                      ),
                    ),
                  )
                : _items.isEmpty
                    ? Center(
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
                              l10n.exerciseLibraryEmpty,
                              style: theme.textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.exerciseLibraryEmptyHint,
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final it = _items[index];
                          return _ExerciseTile(
                            item: it,
                            onEdit: _showEditDialog,
                            onDelete: _confirmDelete,
                            onAddVariant: _showAddVariantDialog,
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _showAddDialog,
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
