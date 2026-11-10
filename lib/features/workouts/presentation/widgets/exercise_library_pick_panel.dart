import 'dart:async';

import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/ui/widgets/app_search_field.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import 'package:powercoach_studio/core/ui/widgets/inline_error_banner.dart';
import 'package:powercoach_studio/core/ui/widgets/list_skeleton.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/analytics/product_analytics.dart';
import '../../../exercise_library/data/custom_exercise_item.dart';
import '../../../exercise_library/data/custom_exercise_repository.dart';
import '../../../exercise_library/data/recent_exercises_store.dart';
import '../../../exercise_library/domain/exercise_catalog_source.dart';
import '../../../exercise_library/domain/exercise_library_tree_helpers.dart';
import '../../../exercise_library/presentation/widgets/custom_exercise_edit_dialog.dart';
import '../../domain/exercise_picker_index_helpers.dart';
import 'exercise_add_sheet_loader.dart';
import 'exercise_picker_tree_list.dart';

/// Opens a pick-only exercise library panel (desktop side panel / mobile sheet).
///
/// Selection invokes [onPicked] and closes this panel only — callers keep any
/// parent session modal open. When [autoAddCreated] is true, a newly created
/// exercise is passed to [onPicked] after the create flow.
Future<void> showExerciseLibraryPickPanel({
  required BuildContext context,
  required ThemeData theme,
  required ColorScheme cs,
  required void Function(CustomExerciseItem item, String displayName) onPicked,
  bool autoAddCreated = true,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppSidePanel<void>(
    context: context,
    title: l10n.workoutBuilderAddExerciseTitle,
    scrollBody: false,
    useRootNavigator: true,
    bodyBuilder: (panelContext) => ExerciseLibraryPickPanel(
      theme: theme,
      cs: cs,
      onPicked: (item, displayName) {
        onPicked(item, displayName);
        if (panelContext.mounted) {
          Navigator.of(panelContext).pop();
        }
      },
      autoAddCreated: autoAddCreated,
    ),
  );
}

/// Pick-only library UI: search, recent, tree, and create-custom CTA.
class ExerciseLibraryPickPanel extends StatefulWidget {
  const ExerciseLibraryPickPanel({
    super.key,
    required this.theme,
    required this.cs,
    required this.onPicked,
    this.autoAddCreated = true,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final void Function(CustomExerciseItem item, String displayName) onPicked;
  final bool autoAddCreated;

  @override
  State<ExerciseLibraryPickPanel> createState() =>
      _ExerciseLibraryPickPanelState();
}

class _ExerciseLibraryPickPanelState extends State<ExerciseLibraryPickPanel> {
  final ExerciseAddSheetLoader _loader = ExerciseAddSheetLoader();
  final CustomExerciseRepository _customExerciseRepo =
      CustomExerciseRepository();
  final RecentExercisesStore _recentStore = RecentExercisesStore.instance;
  final _searchController = TextEditingController();

  List<CustomExerciseItem> _treeRoots = [];
  List<CustomExerciseItem> _recentExercises = [];
  Set<String> _pinnedExerciseIds = <String>{};
  final Map<String, String> _exerciseParentName = {};
  bool _loadingExercises = true;
  bool _exerciseLoadFailed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadExercises());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    if (mounted) {
      setState(() {
        _loadingExercises = true;
        _exerciseLoadFailed = false;
      });
    }
    try {
      final data = await _loader.loadPickerData();
      if (!mounted) return;
      setState(() {
        _treeRoots = data.treeRoots;
        _recentExercises = data.recentExercises;
        _pinnedExerciseIds = data.pinnedExerciseIds;
        _exerciseParentName
          ..clear()
          ..addAll(data.exerciseParentName);
        _loadingExercises = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingExercises = false;
        _exerciseLoadFailed = true;
      });
    }
  }

  String _displayName(CustomExerciseItem exercise) {
    return exercisePickerDisplayName(exercise, _exerciseParentName);
  }

  void _pick(CustomExerciseItem exercise) {
    unawaited(_recentStore.recordUse(exercise.id));
    widget.onPicked(exercise, _displayName(exercise));
  }

  Future<void> _openCreateExercise() async {
    final l10n = AppLocalizations.of(context);

    await showAppBottomSheet<void>(
      context: context,
      title: l10n.exerciseLibraryAddExercise,
      wrapContent: true,
      useRootNavigator: true,
      bodyBuilder: (sheetContext) => CustomExerciseEditDialog(
        title: l10n.exerciseLibraryAddExercise,
        name: '',
        description: null,
        isMobility: false,
        parentId: null,
        parentTreeRoots: _treeRoots,
        onSave: (name, description, selectedParentId, isMobility) async {
          try {
            final created = await _customExerciseRepo.create({
              'name': name,
              if (description != null && description.isNotEmpty)
                'description': description,
              if (selectedParentId != null && selectedParentId.isNotEmpty)
                'parentId': selectedParentId,
              'isMobility': isMobility,
            });
            ProductAnalytics.customExerciseCreated(
              catalogSource: ExerciseCatalogSource.manual,
            );
            final item = CustomExerciseItem.fromJson(created);
            if (sheetContext.mounted) {
              Navigator.of(sheetContext).pop();
            }
            await _loadExercises();
            if (!mounted) return;
            if (widget.autoAddCreated) {
              _pick(item);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = widget.theme;
    final cs = widget.cs;

    if (_loadingExercises) {
      return const ListSkeleton(rowCount: 8, padding: EdgeInsets.all(8));
    }
    if (_exerciseLoadFailed) {
      return Center(
        child: InlineErrorBanner(
          message: l10n.workoutBuilderExerciseLoadError,
          onRetry: _loadExercises,
          retryLabel: l10n.customersRetry,
        ),
      );
    }

    final query = _searchController.text;
    final searching = query.trim().isNotEmpty;
    final visibleRoots = searching
        ? filterExerciseTreeByQuery(_treeRoots, query)
        : _treeRoots;
    final libraryEmpty = _treeRoots.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSearchTextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: l10n.workoutBuilderCompactAddSearchHint,
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: cs.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (!searching && _recentExercises.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            l10n.workoutBuilderCompactAddRecent,
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _recentExercises
                .map(
                  (e) => ActionChip(
                    label: Text(e.name),
                    avatar: _pinnedExerciseIds.contains(e.id)
                        ? const Icon(Icons.push_pin, size: 14)
                        : null,
                    onPressed: () => _pick(e),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 12),
        Expanded(
          child: visibleRoots.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: !searching && libraryEmpty
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.exerciseLibraryEmpty,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.exerciseLibraryEmptyHint,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            l10n.workoutBuilderCompactAddEmpty,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                  ),
                )
              : ExercisePickerTreeList(
                  roots: visibleRoots,
                  pinnedIds: _pinnedExerciseIds,
                  onPick: _pick,
                  forceExpandAll: searching,
                ),
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: _openCreateExercise,
          icon: const Icon(Icons.add),
          label: Text(l10n.workoutBuilderCreateNew),
        ),
      ],
    );
  }
}
