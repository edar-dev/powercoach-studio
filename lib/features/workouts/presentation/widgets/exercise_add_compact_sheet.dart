import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/breakpoints.dart';
import '../../../exercise_library/data/custom_exercise_item.dart';
import '../../../exercise_library/data/recent_exercises_store.dart';
import '../../../exercise_library/domain/exercise_autocomplete_filter.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/exercise_picker_index_helpers.dart';
import '../../domain/workout_exercise_mutations.dart';
import 'exercise_add_sheet_loader.dart';

/// Compact gym-mode sheet: recent/pinned + search, one tap adds 3×10 defaults.
class ExerciseAddCompactSheet extends StatefulWidget {
  const ExerciseAddCompactSheet({
    super.key,
    required this.theme,
    required this.cs,
    this.customerId,
    required this.onSaveWithSets,
    required this.onCancel,
    required this.onOpenFullEditor,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String? customerId;
  final void Function(
    String name,
    String note,
    List<ExerciseSet> setDetails, [
    String? customExerciseId,
  ])
  onSaveWithSets;
  final VoidCallback onCancel;
  final VoidCallback onOpenFullEditor;

  @override
  State<ExerciseAddCompactSheet> createState() => _ExerciseAddCompactSheetState();
}

class _ExerciseAddCompactSheetState extends State<ExerciseAddCompactSheet> {
  final ExerciseAddSheetLoader _loader = ExerciseAddSheetLoader();
  final RecentExercisesStore _recentStore = RecentExercisesStore.instance;
  final _searchController = TextEditingController();
  final _exerciseFilter = DebouncedExerciseAutocompleteFilter();

  List<CustomExerciseItem> _exerciseOptions = [];
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
    _exerciseFilter.cancel();
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

  void _addExercise(CustomExerciseItem exercise) {
    unawaited(_recentStore.recordUse(exercise.id));
    widget.onSaveWithSets(
      exercise.name,
      '',
      defaultExerciseSetDetails(),
      exercise.id,
    );
    widget.onCancel();
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
                    onPressed: () => _addExercise(e),
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
                      onTap: () => _addExercise(exercise),
                    );
                  },
                ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: widget.onOpenFullEditor,
          icon: const Icon(Icons.tune_outlined),
          label: Text(l10n.workoutBuilderCompactAddFullEditor),
        ),
      ],
    );
  }
}

Future<bool> resolveWorkoutBuilderCompactAdd(
  BuildContext context, {
  bool? preferenceOverride,
}) async {
  if (preferenceOverride != null) {
    return preferenceOverride;
  }
  return MediaQuery.sizeOf(context).width < AppBreakpoints.tablet;
}
