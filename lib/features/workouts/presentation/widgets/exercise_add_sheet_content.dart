import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../customers/data/models/customer_exercise_record.dart';
import '../../../exercise_library/data/custom_exercise_item.dart';
import '../../../exercise_library/data/custom_exercise_repository.dart';
import '../../../exercise_library/data/recent_exercises_store.dart';
import '../../../exercise_library/domain/exercise_autocomplete_filter.dart';
import '../../data/workout_routine_model.dart';
import 'exercise_add_create_new_fields.dart';
import 'exercise_add_library_picker.dart';
import 'exercise_add_load_percent_tools.dart';
import 'exercise_add_set_rows_editor.dart';
import 'exercise_add_sheet_loader.dart';
import 'exercise_add_sheet_save_handler.dart';
import 'exercise_add_sheet_states.dart';
import 'exercise_set_edit_controllers.dart';

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
  final ExerciseAddSheetLoader _loader = ExerciseAddSheetLoader();
  final CustomExerciseRepository _customExerciseRepo = CustomExerciseRepository();
  final RecentExercisesStore _recentStore = RecentExercisesStore.instance;

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
      final data = await _loader.loadPickerData();
      if (mounted) {
        setState(() {
          _exerciseOptions = data.exerciseOptions;
          _recentExercises = data.recentExercises;
          _pinnedExerciseIds = data.pinnedExerciseIds;
          _exerciseDepth
            ..clear()
            ..addAll(data.exerciseDepth);
          _exerciseParentName
            ..clear()
            ..addAll(data.exerciseParentName);
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
      final list = await _loader.loadCustomerRecords(
        customerId: customerId,
        customExerciseId: customExerciseId,
      );
      if (mounted) {
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
    handleExerciseAddSheetSave(
      context: context,
      colorScheme: widget.cs,
      apiConfigured: _apiConfigured,
      fromLibrary: _fromLibrary,
      selectedExercise: _selectedExercise,
      nameController: _nameController,
      noteController: _noteController,
      setControllers: _setControllers,
      recentStore: _recentStore,
      customExerciseRepo: _customExerciseRepo,
      setSaving: (saving) => setState(() => _saving = saving),
      onSaveWithSets: widget.onSaveWithSets,
      onCancel: widget.onCancel,
    );
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
        else
          ExerciseAddCreateNewFields(
            l10n: l10n,
            nameController: _nameController,
            autofocusName: !_apiConfigured,
          ),
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
