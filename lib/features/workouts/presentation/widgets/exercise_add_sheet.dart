import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import '../../../customers/data/customer_exercise_record_repository.dart';
import '../../../customers/data/models/customer_exercise_record.dart';
import '../../../exercise_library/data/custom_exercise_item.dart';
import '../../../exercise_library/data/custom_exercise_repository.dart';
import '../../../exercise_library/data/pinned_exercises_store.dart';
import '../../../exercise_library/data/recent_exercises_store.dart';
import '../../../exercise_library/domain/exercise_autocomplete_filter.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/exercise_picker_index_helpers.dart';
import 'exercise_add_library_picker.dart';
import 'exercise_add_load_percent_tools.dart';
import 'exercise_add_set_rows_editor.dart';
import 'exercise_add_sheet_states.dart';
import 'exercise_set_edit_controllers.dart';

/// Shows the "Add exercise" dialog: choose from custom exercise library or create new on the fly.
/// When [customerId] is set, records for the selected exercise are loaded and shown.
void showAddExerciseDialog(
  BuildContext context,
  ThemeData theme,
  ColorScheme cs,
  void Function(
    String name,
    String note,
    List<ExerciseSet> setDetails, [
    String? customExerciseId,
  ])
  onSaveWithSets, {
  String? customerId,
}) {
  final l10n = AppLocalizations.of(context);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderAddExerciseTitle,
    fullScreen: true,
    bodyBuilder: (sheetContext) => AddExerciseDialogContent(
      theme: theme,
      cs: cs,
      customerId: customerId,
      onSaveWithSets: onSaveWithSets,
      onCancel: () => Navigator.of(sheetContext).pop(),
    ),
  );
}

class AddExerciseDialogContent extends StatefulWidget {
  const AddExerciseDialogContent({
    super.key,
    required this.theme,
    required this.cs,
    this.customerId,
    required this.onSaveWithSets,
    required this.onCancel,
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

  @override
  State<AddExerciseDialogContent> createState() =>
      AddExerciseDialogContentState();
}

class AddExerciseDialogContentState extends State<AddExerciseDialogContent> {
  final _customExerciseRepo = CustomExerciseRepository();
  final _recordRepo = CustomerExerciseRecordRepository();
  final _recentStore = RecentExercisesStore.instance;
  final _pinnedStore = PinnedExercisesStore.instance;
  List<CustomExerciseItem> _exerciseOptions = [];
  List<CustomExerciseItem> _recentExercises = [];
  Set<String> _pinnedExerciseIds = <String>{};
  final Map<String, int> _exerciseDepth = {};
  final Map<String, String> _exerciseParentName = {};
  bool _loadingExercises = true;
  bool _exerciseLoadFailed = false;
  bool _fromLibrary = true;
  CustomExerciseItem? _selectedExercise;
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  final List<SetEditControllers> _setControllers = [];
  bool _saving = false;
  List<CustomerExerciseRecord> _recordsForExercise = [];
  bool _loadingRecords = false;
  final _exerciseFilter = DebouncedExerciseAutocompleteFilter();

  bool get _apiConfigured => true;
  bool get _hasCustomerContext =>
      widget.customerId != null && widget.customerId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _setControllers.add(
      SetEditControllers(
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ),
    );
    _loadExercises();
  }

  @override
  void dispose() {
    _exerciseFilter.cancel();
    _nameController.dispose();
    _noteController.dispose();
    for (final c in _setControllers) {
      c.sets.dispose();
      c.reps.dispose();
      c.load.dispose();
      c.note.dispose();
    }
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
      final items = await _customExerciseRepo.getTree();
      final index = buildExercisePickerIndex(items);
      final recentIds = await _recentStore.getRecentIds();
      final pinnedIds = await _pinnedStore.getPinnedIds();
      final byId = {for (final e in index.flat) e.id: e};
      final recent = recentIds
          .map((id) => byId[id])
          .whereType<CustomExerciseItem>()
          .toList();
      final sorted = sortExercisePickerOptions(
        flat: index.flat,
        pinnedIds: pinnedIds,
        recentIds: recentIds,
        displayName: (e) => exercisePickerDisplayName(
          e,
          index.parentNameById,
        ),
      );
      if (mounted) {
        setState(() {
          _exerciseOptions = sorted;
          _recentExercises = recent.take(6).toList();
          _pinnedExerciseIds = pinnedIds;
          _exerciseDepth
            ..clear()
            ..addAll(index.depthById);
          _exerciseParentName
            ..clear()
            ..addAll(index.parentNameById);
          _loadingExercises = false;
          _exerciseLoadFailed = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingExercises = false;
          _exerciseLoadFailed = true;
        });
      }
    }
  }

  Future<void> _loadRecordsForExercise(String? customExerciseId) async {
    final customerId = widget.customerId;
    if (customerId == null || customExerciseId == null || !_apiConfigured) {
      if (mounted) {
        setState(() {
          _recordsForExercise = [];
          _loadingRecords = false;
        });
      }
      return;
    }
    setState(() => _loadingRecords = true);
    try {
      final list = await _recordRepo.getByCustomerId(
        customerId,
        customExerciseId: customExerciseId,
      );
      if (mounted) {
        list.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
        setState(() {
          _recordsForExercise = list;
          _loadingRecords = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _recordsForExercise = [];
          _loadingRecords = false;
        });
      }
    }
  }

  void _onExerciseSelected(CustomExerciseItem exercise) {
    setState(() => _selectedExercise = exercise);
    _loadRecordsForExercise(exercise.id);
  }

  Future<void> _createCustomExerciseAndSave(
    String name,
    String note,
    List<ExerciseSet> details,
  ) async {
    if (!_apiConfigured) {
      widget.onSaveWithSets(name, note, details, null);
      widget.onCancel();
      return;
    }
    setState(() => _saving = true);
    try {
      final body = <String, dynamic>{
        'name': name.trim(),
        if (note.trim().isNotEmpty) 'description': note.trim(),
      };
      final res = await _customExerciseRepo.create(body);
      if (!mounted) return;
      final id = res['id']?.toString();
      final createdName = res['name'] as String? ?? name.trim();
      widget.onSaveWithSets(createdName, note, details, id);
      widget.onCancel();
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).workoutBuilderCouldNotCreateExercise,
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: widget.cs.errorContainer,
          ),
        );
      }
    }
  }

  void _addSetRow() {
    setState(
      () => _setControllers.add(
        SetEditControllers(
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ),
      ),
    );
  }

  void _removeSetRow(int index) {
    final removed = _setControllers.removeAt(index);
    removed.sets.dispose();
    removed.reps.dispose();
    removed.load.dispose();
    removed.note.dispose();
    setState(() {});
  }

  void _doSave() {
    final note = _noteController.text.trim();
    final details = _setControllers.map((c) {
      final sets = c.sets.text.trim();
      final reps = c.reps.text.trim();
      final load = c.load.text.trim();
      final noteSet = c.note.text.trim();
      if (sets.isNotEmpty || reps.isNotEmpty || load.isNotEmpty) {
        return ExerciseSet(
          sets: sets.isEmpty ? '1' : sets,
          reps: reps,
          rpe: load,
          note: noteSet,
        );
      }
      return ExerciseSet(note: noteSet);
    }).toList();

    if (_fromLibrary && _selectedExercise != null) {
      unawaited(_recentStore.recordUse(_selectedExercise!.id));
      widget.onSaveWithSets(
        _selectedExercise!.name,
        note,
        details.isEmpty ? [const ExerciseSet()] : details,
        _selectedExercise!.id,
      );
      widget.onCancel();
      return;
    }

    final name = (!_apiConfigured || !_fromLibrary)
        ? _nameController.text.trim()
        : (_selectedExercise?.name ?? '').trim();
    if (name.isEmpty) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).workoutBuilderEnterNameOrSelect,
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: widget.cs.errorContainer,
        ),
      );
      return;
    }

    if (!_fromLibrary && _apiConfigured) {
      _createCustomExerciseAndSave(
        name,
        note,
        details.isEmpty ? [const ExerciseSet()] : details,
      );
      return;
    }

    if (!_fromLibrary) {
      widget.onSaveWithSets(
        name,
        note,
        details.isEmpty ? [const ExerciseSet()] : details,
        null,
      );
      widget.onCancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_loadingExercises && _apiConfigured) {
      return ExerciseAddSheetLoadingView(onCancel: widget.onCancel);
    }

    if (_exerciseLoadFailed && _apiConfigured && _fromLibrary) {
      return ExerciseAddSheetLoadErrorView(
        onRetry: _loadExercises,
        onCreateNew: () => setState(() => _fromLibrary = false),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_apiConfigured) ...[
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: true,
                label: Text(l10n.workoutBuilderFromLibrary),
                icon: const Icon(Icons.fitness_center, size: 18),
              ),
              ButtonSegment(
                value: false,
                label: Text(l10n.workoutBuilderCreateNew),
                icon: const Icon(Icons.add, size: 18),
              ),
            ],
            selected: {_fromLibrary},
            onSelectionChanged: (s) => setState(() {
              _fromLibrary = s.first;
              if (!_fromLibrary) _selectedExercise = null;
            }),
          ),
          const SizedBox(height: 12),
        ],
        if (_apiConfigured && _fromLibrary && _exerciseOptions.isNotEmpty)
          ExerciseAddLibraryPicker(
            exerciseOptions: _exerciseOptions,
            recentExercises: _recentExercises,
            pinnedExerciseIds: _pinnedExerciseIds,
            depthById: _exerciseDepth,
            parentNameById: _exerciseParentName,
            selectedExercise: _selectedExercise,
            exerciseFilter: _exerciseFilter,
            isMounted: () => mounted,
            onExerciseSelected: _onExerciseSelected,
            customerRecordPanel: _hasCustomerContext && _selectedExercise != null
                ? ExerciseAddCustomerRecordPanel(
                    loading: _loadingRecords,
                    records: _recordsForExercise,
                  )
                : null,
          )
        else ...[
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.workoutBuilderNameLabel,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: const OutlineInputBorder(),
            ),
            autofocus: !_apiConfigured,
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _noteController,
          decoration: InputDecoration(
            labelText: l10n.workoutBuilderNoteOptionalLabel,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: const OutlineInputBorder(),
          ),
          maxLines: 1,
        ),
        const SizedBox(height: 12),
        ExerciseAddSetRowsEditor(
          setControllers: _setControllers,
          onAddSet: _addSetRow,
          onRemoveSet: _removeSetRow,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saving ? null : widget.onCancel,
                child: Text(l10n.customerCancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _saving ? null : _doSave,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.customerSave),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
