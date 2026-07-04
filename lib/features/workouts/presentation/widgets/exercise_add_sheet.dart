import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import '../../../customers/data/customer_exercise_record_repository.dart';
import '../../../customers/data/models/customer_exercise_record.dart';
import '../../../exercise_library/data/custom_exercise_item.dart';
import '../../../exercise_library/data/custom_exercise_repository.dart';
import '../../../exercise_library/data/pinned_exercises_store.dart';
import '../../../exercise_library/data/recent_exercises_store.dart';
import '../../../exercise_library/domain/exercise_autocomplete_filter.dart';
import '../../data/workout_routine_model.dart';
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
  final _loadPercentInputController = TextEditingController();
  final List<SetEditControllers> _setControllers = [];
  bool _saving = false;
  List<CustomerExerciseRecord> _recordsForExercise = [];
  bool _loadingRecords = false;
  final _exerciseFilter = DebouncedExerciseAutocompleteFilter();

  bool get _apiConfigured => true;
  bool get _hasCustomerContext =>
      widget.customerId != null && widget.customerId!.isNotEmpty;

  String _exerciseDisplayName(CustomExerciseItem e) {
    final parentName = _exerciseParentName[e.id];
    return parentName != null ? '$parentName › ${e.name}' : e.name;
  }

  Widget _buildRecordLine(
    ThemeData theme,
    ColorScheme cs,
    CustomerExerciseRecord r,
  ) {
    final dateStr =
        '${r.recordedAt.day.toString().padLeft(2, '0')}/${r.recordedAt.month.toString().padLeft(2, '0')}/${r.recordedAt.year}';
    return Text(
      '${r.value} ${r.unit} · $dateStr${r.note != null && r.note!.isNotEmpty ? ' · ${r.note}' : ''}',
      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface),
    );
  }

  static bool _isMassBasedRecordUnit(String unit) {
    final u = unit.trim().toLowerCase();
    return u == 'kg' || u == 'lb' || u == 'lbs';
  }

  static String _formatLoadForDisplay(double v) {
    final rounded = (v * 10).round() / 10;
    if ((rounded - rounded.round()).abs() < 1e-9) {
      return rounded.round().toString();
    }
    return rounded.toStringAsFixed(1);
  }

  /// Standard % ladder for powerlifting-style reference loads.
  static const List<int> _loadPercentLadder = [
    100,
    95,
    90,
    85,
    80,
    75,
    70,
    65,
    60,
    55,
    50,
  ];

  Widget _buildLoadPercentGuideContent(
    ThemeData theme,
    ColorScheme cs,
    AppLocalizations l10n,
    CustomerExerciseRecord r,
    bool mass,
  ) {
    if (mass) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final p in _loadPercentLadder)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                l10n.workoutBuilderLoadPercentGuideRow(
                  p.toString(),
                  _formatLoadForDisplay(r.value * p / 100.0),
                  r.unit,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.45,
                  color: cs.onSurface,
                ),
              ),
            ),
        ],
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        l10n.workoutBuilderLoadPercentGuideBody,
        style: theme.textTheme.bodySmall?.copyWith(
          height: 1.45,
          color: cs.onSurface,
        ),
      ),
    );
  }

  String _loadPercentResultLabel(
    AppLocalizations l10n,
    CustomerExerciseRecord r,
  ) {
    final raw = _loadPercentInputController.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return '—';
    final p = double.tryParse(raw);
    if (p == null || p <= 0 || p > 100) {
      return l10n.workoutBuilderLoadPercentInvalid;
    }
    final load = r.value * p / 100.0;
    final w = _formatLoadForDisplay(load);
    final percentStr = (p - p.round()).abs() < 1e-9
        ? p.round().toString()
        : _formatLoadForDisplay(p);
    return l10n.workoutBuilderLoadPercentResult(w, r.unit, percentStr);
  }

  Widget _buildLoadPercentTools(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    CustomerExerciseRecord r,
  ) {
    final l10n = AppLocalizations.of(context);
    final mass = _isMassBasedRecordUnit(r.unit);
    final denseDecoration = InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: const OutlineInputBorder(),
    );
    return Card(
      margin: EdgeInsets.zero,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                title: Text(
                  l10n.workoutBuilderLoadPercentGuideTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  mass
                      ? l10n.workoutBuilderLoadPercentGuideIntroMass
                      : l10n.workoutBuilderLoadPercentGuideIntroReps,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                children: [
                  _buildLoadPercentGuideContent(theme, cs, l10n, r, mass),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              l10n.workoutBuilderLoadPercentCalculator,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (mass)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _loadPercentInputController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: denseDecoration.copyWith(
                        labelText: l10n.workoutBuilderLoadPercentFieldLabel,
                        hintText: l10n.workoutBuilderLoadPercentFieldHint,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _loadPercentResultLabel(l10n, r),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Text(
                l10n.workoutBuilderLoadPercentMassOnly,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

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
    _loadPercentInputController.dispose();
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
      final flat = <CustomExerciseItem>[];
      void visit(CustomExerciseItem node, int depth, String? parentName) {
        flat.add(node);
        _exerciseDepth[node.id] = depth;
        if (parentName != null) _exerciseParentName[node.id] = parentName;
        for (final c in node.children) {
          visit(c, depth + 1, node.name);
        }
      }

      for (final root in items) {
        visit(root, 0, null);
      }
      final recentIds = await _recentStore.getRecentIds();
      final pinnedIds = await _pinnedStore.getPinnedIds();
      final byId = {for (final e in flat) e.id: e};
      final recent = recentIds
          .map((id) => byId[id])
          .whereType<CustomExerciseItem>()
          .toList();
      final sorted = List<CustomExerciseItem>.from(flat)
        ..sort((a, b) {
          final aPinned = pinnedIds.contains(a.id);
          final bPinned = pinnedIds.contains(b.id);
          if (aPinned != bPinned) return aPinned ? -1 : 1;
          final ai = recentIds.indexOf(a.id);
          final bi = recentIds.indexOf(b.id);
          if (ai >= 0 || bi >= 0) {
            if (ai < 0) return 1;
            if (bi < 0) return -1;
            return ai.compareTo(bi);
          }
          return _exerciseDisplayName(
            a,
          ).toLowerCase().compareTo(_exerciseDisplayName(b).toLowerCase());
        });
      if (mounted) {
        setState(() {
          _exerciseOptions = sorted;
          _recentExercises = recent.take(6).toList();
          _pinnedExerciseIds = pinnedIds;
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
          _loadPercentInputController.clear();
        });
      }
      return;
    }
    setState(() {
      _loadingRecords = true;
      _loadPercentInputController.clear();
    });
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
    final theme = widget.theme;
    final cs = widget.cs;
    final l10n = AppLocalizations.of(context);
    final denseDecoration = InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );

    if (_loadingExercises && _apiConfigured) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: widget.onCancel,
            child: Text(l10n.customerCancel),
          ),
        ],
      );
    }

    if (_exerciseLoadFailed && _apiConfigured && _fromLibrary) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Icon(Icons.cloud_off_outlined, size: 40, color: cs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            l10n.workoutBuilderExerciseLoadError,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loadExercises,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.workoutBuilderExerciseRetry),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => setState(() => _fromLibrary = false),
            child: Text(l10n.workoutBuilderCreateNew),
          ),
        ],
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
        if (_apiConfigured && _fromLibrary && _exerciseOptions.isNotEmpty) ...[
          Text(
            l10n.workoutBuilderExerciseLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          if (_recentExercises.isNotEmpty) ...[
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
                      onPressed: () {
                        setState(() => _selectedExercise = e);
                        _loadRecordsForExercise(e.id);
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
          ],
          Autocomplete<CustomExerciseItem>(
            initialValue: _selectedExercise != null
                ? TextEditingValue(
                    text: _exerciseDisplayName(_selectedExercise!),
                  )
                : const TextEditingValue(),
            optionsBuilder: (TextEditingValue value) {
              return _exerciseFilter.optionsFor<CustomExerciseItem>(
                query: value.text,
                options: _exerciseOptions,
                displayName: _exerciseDisplayName,
                isActive: () => mounted,
              );
            },
            displayStringForOption: _exerciseDisplayName,
            onSelected: (e) {
              setState(() => _selectedExercise = e);
              _loadRecordsForExercise(e.id);
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) =>
                    TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: l10n.recordSearchExerciseHint,
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
            optionsViewBuilder: (context, onSelected, options) => Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final e = options.elementAt(index);
                      final depth = _exerciseDepth[e.id] ?? 0;
                      return Padding(
                        padding: EdgeInsets.only(left: 16.0 + (depth * 16.0)),
                        child: ListTile(
                          dense: depth > 0,
                          title: Text(
                            depth > 0 ? e.name : _exerciseDisplayName(e),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: depth == 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          onTap: () => onSelected(e),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          if (_hasCustomerContext && _selectedExercise != null) ...[
            const SizedBox(height: 10),
            Text(
              l10n.workoutBuilderClientRecord,
              style: theme.textTheme.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            if (_loadingRecords)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (_recordsForExercise.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  l10n.workoutBuilderNoExerciseRecord,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildRecordLine(theme, cs, _recordsForExercise.first),
                    const SizedBox(height: 10),
                    _buildLoadPercentTools(
                      context,
                      theme,
                      cs,
                      _recordsForExercise.first,
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 12),
        ] else ...[
          // Create new (or no API): show name field
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
        Text(
          l10n.workoutBuilderMultiSetBlockHeader,
          style: theme.textTheme.labelMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        ...List.generate(_setControllers.length, (i) {
          final c = _setControllers[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: c.sets,
                    decoration: denseDecoration.copyWith(
                      labelText: l10n.workoutBuilderSetLabel,
                      hintText: '1',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: c.reps,
                    decoration: denseDecoration.copyWith(
                      labelText: l10n.workoutBuilderRepsLabel,
                      hintText: '3',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: c.load,
                    decoration: denseDecoration.copyWith(
                      labelText: l10n.workoutBuilderLoadLabel,
                      hintText: '75kg',
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 22,
                    color: _setControllers.length > 1
                        ? StitchM3Theme.danger
                        : cs.onSurfaceVariant,
                  ),
                  onPressed: _setControllers.length > 1
                      ? () {
                          final removed = _setControllers.removeAt(i);
                          removed.sets.dispose();
                          removed.reps.dispose();
                          removed.load.dispose();
                          removed.note.dispose();
                          setState(() {});
                        }
                      : null,
                  style: IconButton.styleFrom(padding: const EdgeInsets.all(8)),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(
              () => _setControllers.add(
                SetEditControllers(
                  TextEditingController(),
                  TextEditingController(),
                  TextEditingController(),
                  TextEditingController(),
                ),
              ),
            ),
            icon: Icon(Icons.add, size: 18, color: StitchM3Theme.accent),
            label: Text(
              l10n.workoutBuilderAddSet,
              style: theme.textTheme.labelMedium?.copyWith(
                color: StitchM3Theme.accent,
              ),
            ),
          ),
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
