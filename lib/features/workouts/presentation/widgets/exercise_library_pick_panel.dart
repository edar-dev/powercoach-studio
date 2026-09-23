import 'dart:async';

import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../exercise_library/data/custom_exercise_item.dart';
import '../../../exercise_library/data/custom_exercise_repository.dart';
import '../../../exercise_library/data/recent_exercises_store.dart';
import '../../../exercise_library/domain/exercise_autocomplete_filter.dart';
import '../../../exercise_library/domain/exercise_library_tree_helpers.dart';
import '../../../exercise_library/presentation/widgets/custom_exercise_edit_dialog.dart';
import '../../domain/exercise_picker_index_helpers.dart';
import 'exercise_add_sheet_loader.dart';

/// Opens a pick-only exercise library panel (desktop side panel / mobile sheet).
///
/// Selection invokes [onPicked] and closes this panel only — callers keep any
/// parent session modal open. When [autoAddCreated] is true, a newly created
/// exercise is passed to [onPicked] after the create flow.
Future<void> showExerciseLibraryPickPanel({
  required BuildContext context,
  required ThemeData theme,
  required ColorScheme cs,
  required ValueChanged<CustomExerciseItem> onPicked,
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
      onPicked: (item) {
        onPicked(item);
        if (panelContext.mounted) {
          Navigator.of(panelContext).pop();
        }
      },
      autoAddCreated: autoAddCreated,
    ),
  );
}

/// Pick-only library UI: search, recent, list, and create-custom CTA.
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
  final ValueChanged<CustomExerciseItem> onPicked;
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

  List<CustomExerciseItem> _exerciseOptions = [];
  List<CustomExerciseItem> _treeItems = [];
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
      final tree = await _customExerciseRepo.getTree();
      final data = await _loader.loadPickerData();
      if (!mounted) return;
      setState(() {
        _treeItems = tree;
        _exerciseOptions = data.exerciseOptions;
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
    widget.onPicked(exercise);
  }

  Future<void> _openCreateExercise() async {
    final l10n = AppLocalizations.of(context);
    final parentCandidates = flattenExerciseTree(_treeItems);

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
        parentCandidates: parentCandidates,
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

  List<CustomExerciseItem> get _filteredOptions {
    return filterExercisesByQuery(
      query: _searchController.text,
      options: _exerciseOptions,
      displayName: _displayName,
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = widget.theme;
    final cs = widget.cs;

    if (_loadingExercises) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_exerciseLoadFailed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.workoutBuilderExerciseLoadError),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadExercises,
                child: Text(l10n.customersRetry),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _filteredOptions;
    final showRecent = _searchController.text.trim().isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchController,
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
          onChanged: (_) => setState(() {}),
        ),
        if (showRecent && _recentExercises.isNotEmpty) ...[
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
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    l10n.workoutBuilderCompactAddEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final exercise = filtered[index];
                    return ListTile(
                      title: Text(_displayName(exercise)),
                      trailing: _pinnedExerciseIds.contains(exercise.id)
                          ? Icon(Icons.push_pin, size: 18, color: cs.primary)
                          : null,
                      onTap: () => _pick(exercise),
                    );
                  },
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
