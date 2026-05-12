import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/workout_plan_template_scope.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/data/customer_repository.dart';
import '../../../exercise_library/data/custom_exercise_repository.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../../../widgets/app_sheet.dart';
import '../../data/workout_routine_model.dart';
import '../../data/workout_routine_storage.dart';
import '../../data/workout_plan_repository.dart';
import '../../domain/export_excel_usecase.dart';
import '../../domain/export_pdf_usecase.dart';
import '../../../customers/data/customer_exercise_record_repository.dart';
import '../../../customers/data/models/customer.dart' show Customer;
import '../../../customers/data/models/customer_exercise_record.dart';
import '../../../exercise_library/data/custom_exercise_item.dart';

/// Returns list of superset group options for the day (id + label) for "Add to superset" menu.
List<({String id, String label})> _getSupersetGroupOptions(Day day) {
  final byId = <String, List<Exercise>>{};
  for (final e in day.exercises) {
    final id = e.supersetGroupId;
    if (id != null && id.isNotEmpty) {
      byId.putIfAbsent(id, () => []).add(e);
    }
  }
  return byId.entries
      .map((e) => (id: e.key, label: e.value.map((x) => x.name).join(' + ')))
      .toList();
}

/// Workout Builder variant: Enhanced Mobility (694ace9b), Multi-set (9ffa631f), Super Set (e63b1ef6), Intuitive Super Set (7ce630e5).
enum WorkoutBuilderVariant { mobility, multiset, superset, intuitiveSuperset }

/// Workout Builder – Enhanced Mobility Controls (Stitch 694ace9b83514965989f12ac2a3d54fa).
/// When [editorMode] is true and [customerId] is set, loads/saves via API (workout plan for customer).
class WorkoutBuilderMobilityScreen extends StatefulWidget {
  const WorkoutBuilderMobilityScreen({
    super.key,
    this.variant = WorkoutBuilderVariant.mobility,
    this.customerId,
    this.planId,
    this.editorMode = false,
  });

  final WorkoutBuilderVariant variant;
  final String? customerId;
  final String? planId;
  final bool editorMode;

  @override
  State<WorkoutBuilderMobilityScreen> createState() =>
      _WorkoutBuilderMobilityScreenState();
}

class _WorkoutBuilderMobilityScreenState
    extends State<WorkoutBuilderMobilityScreen> {
  final _routineNameController = TextEditingController();
  final _initialWeekController = TextEditingController(text: '1');
  final _customerRepo = CustomerRepository();
  final _planRepo = WorkoutPlanRepository();
  String? _loadedPlanId;
  Customer? _editorCustomer;
  WorkoutRoutine _routine = WorkoutRoutine.empty();
  bool _loading = true;
  bool _saving = false;
  int _initialWeekNumber = 1;
  int _selectedMobilitySectionIndex = 0;
  bool _trainingExpanded = true;
  final Set<String> _expandedWeekIds = {};
  int _selectedWeekIndex = 0;
  int _selectedDayIndex = 0;

  bool _mobilityExpanded = true;

  @override
  void initState() {
    super.initState();
    if (widget.variant != WorkoutBuilderVariant.mobility) {
      _mobilityExpanded = false;
    }
    _loadRoutine();
  }

  Future<void> _loadRoutine() async {
    if (widget.editorMode && widget.customerId != null) {
      await _loadForEditorMode();
      return;
    }
    final loaded = await WorkoutRoutineStorage.load();
    if (!mounted) return;
    setState(() {
      _routine = loaded;
      _routineNameController.text = loaded.name;
      _expandedWeekIds.clear();
      if (loaded.weeks.isNotEmpty) {
        _expandedWeekIds.add(loaded.weeks.first.id);
      }
      _loading = false;
    });
  }

  Future<void> _loadForEditorMode() async {
    final customerId = widget.customerId!;
    try {
      Customer? customer;
      if (widget.planId != null && widget.planId!.isNotEmpty) {
        final plan = await _planRepo.getById(widget.planId!);
        if (plan != null && mounted) {
          final routine = planDataToRoutine(plan.planData);
          setState(() {
            _routine = routine;
            _routineNameController.text = routine.name;
            _loadedPlanId = plan.id;
            _initialWeekNumber = plan.initialWeekNumber;
            _initialWeekController.text = plan.initialWeekNumber.toString();
            _expandedWeekIds.clear();
            if (routine.weeks.isNotEmpty)
              _expandedWeekIds.add(routine.weeks.first.id);
          });
        }
      } else {
        setState(() {
          _expandedWeekIds.clear();
          if (_routine.weeks.isNotEmpty)
            _expandedWeekIds.add(_routine.weeks.first.id);
        });
      }
      try {
        customer = await _customerRepo.getById(customerId);
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _editorCustomer = customer;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _expandedWeekIds.clear();
        if (_routine.weeks.isNotEmpty)
          _expandedWeekIds.add(_routine.weeks.first.id);
        _loading = false;
      });
    }
  }

  Future<void> _pickRoutineStartDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = _routine.startDate ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 10, 12, 31),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _routine = _routine.copyWith(
        startDate: DateTime(picked.year, picked.month, picked.day),
      );
    });
  }

  Future<void> _saveRoutine() async {
    if (_saving) return;
    setState(() => _saving = true);
    final name = _routineNameController.text.trim();
    final toSave = _routine.copyWith(name: name.isEmpty ? _routine.name : name);
    final savedInitialWeek = () {
      final v = int.tryParse(_initialWeekController.text.trim());
      return (v != null && v >= 1) ? v : _initialWeekNumber;
    }();

    try {
      if (widget.editorMode && widget.customerId != null) {
        try {
          if (_loadedPlanId != null) {
            await _planRepo.update(
              planId: _loadedPlanId!,
              name: toSave.name,
              planDataJson: _encodeRoutine(toSave),
              initialWeekNumber: savedInitialWeek,
            );
          } else {
            final created = await _planRepo.create(
              customerId: widget.customerId!,
              name: toSave.name,
              planDataJson: _encodeRoutine(toSave),
              initialWeekNumber: savedInitialWeek,
              pdfHeader: _editorCustomer?.pdfHeader,
              useCustomPdfHeader: _editorCustomer?.useCustomPdfHeader ?? false,
            );
            if (mounted) setState(() => _loadedPlanId = created.id);
          }
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).workoutBuilderPlanSaved,
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: StitchM3Theme.accent,
            ),
          );
        } catch (_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).workoutExportError),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          );
        }
      } else {
        await WorkoutRoutineStorage.save(toSave);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).workoutBuilderRoutineSaved,
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: StitchM3Theme.accent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  static String _encodeRoutine(WorkoutRoutine r) {
    return jsonEncode(r.toJson());
  }

  Future<Customer?> _loadCustomerIfNeeded() async {
    if (widget.editorMode && _editorCustomer != null) return _editorCustomer;
    final customerId =
        widget.customerId ??
        GoRouterState.of(context).uri.queryParameters['customerId'];
    if (customerId == null || customerId.isEmpty) return null;
    try {
      return await _customerRepo.getById(customerId);
    } catch (_) {
      return null;
    }
  }

  void _showPdfExportSheet() {
    final l10n = AppLocalizations.of(context);
    var selected = WorkoutPdfLayout.canonical;
    showAppBottomSheet<void>(
      context: context,
      title: l10n.workoutExportPdfSheetTitle,
      bodyBuilder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setModalState) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<WorkoutPdfLayout>(
              segments: [
                ButtonSegment<WorkoutPdfLayout>(
                  value: WorkoutPdfLayout.canonical,
                  label: Text(l10n.workoutPdfLayoutCanonical),
                ),
                ButtonSegment<WorkoutPdfLayout>(
                  value: WorkoutPdfLayout.compact,
                  label: Text(l10n.workoutPdfLayoutCompact),
                ),
              ],
              selected: {selected},
              onSelectionChanged: (set) {
                if (set.isNotEmpty) setModalState(() => selected = set.first);
              },
            ),
            if (selected == WorkoutPdfLayout.compact)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  l10n.workoutPdfLayoutCompactDescription,
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
      primaryActionLabel: l10n.workoutExportPdfGenerateAndShare,
      onPrimaryAction: () {
        final layout = selected;
        Navigator.of(context).pop();
        _exportPdfAndShare(layout);
      },
    );
  }

  Future<void> _exportPdfAndShare(WorkoutPdfLayout layout) async {
    final l10n = AppLocalizations.of(context);
    final name = _routineNameController.text.trim();
    final routine = _routine.copyWith(
      name: name.isEmpty ? _routine.name : name,
    );
    try {
      final customer = await _loadCustomerIfNeeded();
      final path = await exportWorkoutRoutineToPdf(
        routine,
        customer: customer,
        layout: layout,
      );
      if (!mounted) return;
      await Share.shareXFiles([XFile(path)]);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportSuccess),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  Future<void> _exportExcelAndShare() async {
    final l10n = AppLocalizations.of(context);
    final name = _routineNameController.text.trim();
    final routine = _routine.copyWith(
      name: name.isEmpty ? _routine.name : name,
    );
    try {
      final path = await exportWorkoutRoutineToExcel(routine);
      if (!mounted) return;
      await Share.shareXFiles([XFile(path)]);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportSuccess),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  String? get _selectedSectionId {
    final sections = _routine.mobilitySections;
    if (sections.isEmpty) return null;
    final idx = _selectedMobilitySectionIndex.clamp(0, sections.length - 1);
    return sections[idx].id;
  }

  List<MobilityItem> get _mobilityItemsForSelectedSection {
    final sid = _selectedSectionId;
    if (sid == null) return [];
    return _routine.mobilityItems.where((e) => e.sectionId == sid).toList();
  }

  void _addMobilityItem() {
    final sectionId = _selectedSectionId;
    if (sectionId == null) return;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    _showAddMobilityExerciseDialog(context, theme, cs, (
      title,
      subtitle,
      customExerciseId,
    ) {
      final t = title.trim();
      final s = subtitle.trim();
      if (t.isEmpty && s.isEmpty) return;
      setState(() {
        final id = 'm_${DateTime.now().millisecondsSinceEpoch}';
        _routine = _routine.copyWith(
          mobilityItems: [
            ..._routine.mobilityItems,
            MobilityItem(
              id: id,
              title: t.isEmpty ? l10n.workoutBuilderNewExerciseDefault : t,
              subtitle: s,
              sectionId: sectionId,
              customExerciseId: customExerciseId,
            ),
          ],
        );
      });
    });
  }

  void _removeMobilityItem(String id) {
    setState(() {
      _routine = _routine.copyWith(
        mobilityItems: _routine.mobilityItems.where((e) => e.id != id).toList(),
      );
    });
  }

  void _reorderMobility(int oldIndex, int newIndex) {
    final sectionId = _selectedSectionId;
    if (sectionId == null) return;
    final sectionItems = _mobilityItemsForSelectedSection;
    if (oldIndex < 0 ||
        oldIndex >= sectionItems.length ||
        newIndex < 0 ||
        newIndex >= sectionItems.length)
      return;
    setState(() {
      final reordered = List<MobilityItem>.from(sectionItems);
      if (newIndex > oldIndex) newIndex--;
      final item = reordered.removeAt(oldIndex);
      reordered.insert(newIndex, item);
      final others = _routine.mobilityItems
          .where((e) => e.sectionId != sectionId)
          .toList();
      _routine = _routine.copyWith(mobilityItems: [...others, ...reordered]);
    });
  }

  void _addMobilitySection() {
    final l10n = AppLocalizations.of(context);
    setState(() {
      final id = 'sec_${DateTime.now().millisecondsSinceEpoch}';
      final name = l10n.workoutBuilderSectionNumbered(
        _routine.mobilitySections.length + 1,
      );
      _routine = _routine.copyWith(
        mobilitySections: [
          ..._routine.mobilitySections,
          MobilitySection(id: id, name: name),
        ],
      );
      _selectedMobilitySectionIndex = _routine.mobilitySections.length - 1;
    });
  }

  void _editMobilitySection(int index) {
    if (index < 0 || index >= _routine.mobilitySections.length) return;
    final section = _routine.mobilitySections[index];
    _showEditSectionDialog(section.name, (newName) {
      if (newName.trim().isEmpty) return;
      setState(() {
        final updated = _routine.mobilitySections
            .map(
              (s) => s.id == section.id ? s.copyWith(name: newName.trim()) : s,
            )
            .toList();
        _routine = _routine.copyWith(mobilitySections: updated);
      });
    });
  }

  void _deleteMobilitySection(int index) {
    if (index < 0 || index >= _routine.mobilitySections.length) return;
    if (_routine.mobilitySections.length <= 1)
      return; // keep at least one section
    final section = _routine.mobilitySections[index];
    final firstOtherId = _routine.mobilitySections
        .firstWhere((s) => s.id != section.id)
        .id;
    setState(() {
      _routine = _routine.copyWith(
        mobilitySections: _routine.mobilitySections
            .where((s) => s.id != section.id)
            .toList(),
        mobilityItems: _routine.mobilityItems
            .map(
              (m) => m.sectionId == section.id
                  ? m.copyWith(sectionId: firstOtherId)
                  : m,
            )
            .toList(),
      );
      _selectedMobilitySectionIndex = (_selectedMobilitySectionIndex.clamp(
        0,
        _routine.mobilitySections.length - 1,
      ));
    });
  }

  void _showEditSectionDialog(
    String initialName,
    void Function(String) onSave,
  ) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: initialName);
    showAppBottomSheet<void>(
      context: context,
      title: l10n.workoutBuilderEditSectionTitle,
      bodyBuilder: (sheetContext) {
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.workoutBuilderSectionNameLabel,
          ),
          autofocus: false,
          onSubmitted: (_) {
            onSave(controller.text.trim());
            Navigator.of(sheetContext).pop();
          },
        );
      },
      primaryActionLabel: l10n.customerSave,
      onPrimaryAction: () {
        onSave(controller.text.trim());
        Navigator.of(context).pop();
      },
    );
  }

  void _addWeek() {
    final l10n = AppLocalizations.of(context);
    setState(() {
      final id = 'w_${DateTime.now().millisecondsSinceEpoch}';
      final next = _routine.weeks.length + 1;
      _routine = _routine.copyWith(
        weeks: [
          ..._routine.weeks,
          Week(
            id: id,
            name: l10n.workoutBuilderWeekNumbered(next),
            days: [
              Day(
                id: '${id}_d1',
                name: l10n.workoutBuilderDayNumbered(1),
                exercises: [],
              ),
            ],
          ),
        ],
      );
      _expandedWeekIds.add(id);
    });
  }

  void _cloneWeek(int weekIndex) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      final source = _routine.weeks[weekIndex];
      final newId = 'w_${DateTime.now().millisecondsSinceEpoch}';
      final newDays = source.days
          .map(
            (d) => Day(
              id: '${newId}_d_${d.id}',
              name: d.name,
              exercises: d.exercises
                  .map(
                    (e) => Exercise(
                      id: '${e.id}_$newId',
                      name: e.name,
                      sets: e.sets,
                      reps: e.reps,
                      rpe: e.rpe,
                      note: e.note,
                      setDetails: e.setDetails
                          ?.map(
                            (s) => ExerciseSet(
                              line: s.line,
                              sets: s.sets,
                              reps: s.reps,
                              rpe: s.rpe,
                              note: s.note,
                            ),
                          )
                          .toList(),
                      supersetGroupId: e.supersetGroupId,
                      customExerciseId: e.customExerciseId,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList();
      final newWeek = Week(
        id: newId,
        name: '${source.name}${l10n.workoutBuilderNameCopySuffix}',
        days: newDays,
      );
      _routine = _routine.copyWith(weeks: [..._routine.weeks, newWeek]);
      _expandedWeekIds.add(newId);
    });
  }

  void _deleteWeek(int weekIndex) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final weekId = _routine.weeks[weekIndex].id;
    setState(() {
      _routine = _routine.copyWith(
        weeks: _routine.weeks.where((w) => w.id != weekId).toList(),
      );
      _expandedWeekIds.remove(weekId);
      _selectedWeekIndex = _selectedWeekIndex.clamp(
        0,
        _routine.weeks.isNotEmpty ? _routine.weeks.length - 1 : 0,
      );
    });
  }

  Future<void> _confirmDeleteWeek(BuildContext context, int weekIndex) async {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: l10n.workoutBuilderDeleteWeekTitle,
      message: l10n.workoutBuilderDeleteWeekMessage,
      confirmLabel: l10n.customerDelete,
      cancelLabel: l10n.customerCancel,
      destructive: true,
    );
    if (confirmed && mounted) _deleteWeek(weekIndex);
  }

  void _renameDay(int weekIndex, int dayIndex, String newName) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    final name = newName.trim();
    if (name.isEmpty) return;
    setState(() {
      final day = week.days[dayIndex];
      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(name: name);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  void _renameWeek(int weekIndex, String newName) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final name = newName.trim();
    if (name.isEmpty) return;
    setState(() {
      final week = _routine.weeks[weekIndex];
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(name: name);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  void _deleteDay(int weekIndex, int dayIndex) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    if (week.days.length <= 1) return; // keep at least one day
    setState(() {
      final newDays = week.days
          .where((d) => d.id != week.days[dayIndex].id)
          .toList();
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
      _selectedDayIndex = _selectedDayIndex.clamp(
        0,
        newDays.isNotEmpty ? newDays.length - 1 : 0,
      );
    });
  }

  void _addDayToWeek(int weekIndex) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      final week = _routine.weeks[weekIndex];
      final dayId = '${week.id}_d_${DateTime.now().millisecondsSinceEpoch}';
      final newDays = [
        ...week.days,
        Day(
          id: dayId,
          name: l10n.workoutBuilderDayNumbered(week.days.length + 1),
          exercises: [],
        ),
      ];
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  void _addExerciseToDay(int weekIndex, int dayIndex) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    if (dayIndex < 0 || dayIndex >= _routine.weeks[weekIndex].days.length)
      return;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final exId = 'e_${DateTime.now().millisecondsSinceEpoch}';
    _showAddExerciseDialog(context, theme, cs, (
      name,
      note,
      details, [
      customExerciseId,
    ]) {
      final trimmedName = name.trim();
      if (trimmedName.isEmpty) return;
      final list = details.isEmpty ? [const ExerciseSet()] : details;
      setState(() {
        final week = _routine.weeks[weekIndex];
        if (dayIndex < 0 || dayIndex >= week.days.length) return;
        final day = week.days[dayIndex];
        final newExercise = Exercise(
          id: exId,
          name: trimmedName,
          sets: '${list.length}',
          reps: list
              .map((s) => s.displayText)
              .where((r) => r.isNotEmpty)
              .join(' | '),
          rpe: '',
          note: note,
          setDetails: list,
          customExerciseId: customExerciseId,
        );
        final newEx = [...day.exercises, newExercise];
        final newDays = List<Day>.from(week.days);
        newDays[dayIndex] = day.copyWith(exercises: newEx);
        final newWeeks = List<Week>.from(_routine.weeks);
        newWeeks[weekIndex] = week.copyWith(days: newDays);
        _routine = _routine.copyWith(weeks: newWeeks);
      });
    }, customerId: widget.customerId);
  }

  /// Adds a new exercise to the day and assigns it to the given superset group.
  /// The new exercise is inserted immediately after the last exercise of that group.
  /// Stesso dialog multi-serie della creazione normale.
  void _addExerciseToSuperset(
    int weekIndex,
    int dayIndex,
    String supersetGroupId,
  ) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    final day = week.days[dayIndex];
    int insertIndex = -1;
    for (var i = day.exercises.length - 1; i >= 0; i--) {
      if (day.exercises[i].supersetGroupId == supersetGroupId) {
        insertIndex = i + 1;
        break;
      }
    }
    if (insertIndex < 0) insertIndex = day.exercises.length;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final exId = 'e_${DateTime.now().millisecondsSinceEpoch}';
    _showAddExerciseDialog(context, theme, cs, (
      name,
      note,
      details, [
      customExerciseId,
    ]) {
      final trimmedName = name.trim();
      if (trimmedName.isEmpty) return;
      final list = details.isEmpty ? [const ExerciseSet()] : details;
      setState(() {
        final w = _routine.weeks[weekIndex];
        if (dayIndex < 0 || dayIndex >= w.days.length) return;
        final d = w.days[dayIndex];
        final newExercise = Exercise(
          id: exId,
          name: trimmedName,
          sets: '${list.length}',
          reps: list
              .map((s) => s.displayText)
              .where((r) => r.isNotEmpty)
              .join(' | '),
          rpe: '',
          note: note,
          customExerciseId: customExerciseId,
          setDetails: list,
          supersetGroupId: supersetGroupId,
        );
        final newEx = List<Exercise>.from(d.exercises)
          ..insert(insertIndex, newExercise);
        final newDays = List<Day>.from(w.days);
        newDays[dayIndex] = d.copyWith(exercises: newEx);
        final newWeeks = List<Week>.from(_routine.weeks);
        newWeeks[weekIndex] = w.copyWith(days: newDays);
        _routine = _routine.copyWith(weeks: newWeeks);
      });
    }, customerId: widget.customerId);
  }

  void _removeExercise(int weekIndex, int dayIndex, String exerciseId) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    setState(() {
      final day = week.days[dayIndex];
      final newEx = day.exercises.where((e) => e.id != exerciseId).toList();
      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(exercises: newEx);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  void _moveExerciseInDay(
    int weekIndex,
    int dayIndex,
    String exerciseId, {
    required bool up,
  }) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    final day = week.days[dayIndex];

    final currentIndex = day.exercises.indexWhere((e) => e.id == exerciseId);
    if (currentIndex < 0) return;
    final targetIndex = up ? currentIndex - 1 : currentIndex + 1;
    if (targetIndex < 0 || targetIndex >= day.exercises.length) return;

    setState(() {
      final reordered = List<Exercise>.from(day.exercises);
      final item = reordered.removeAt(currentIndex);
      reordered.insert(targetIndex, item);

      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(exercises: reordered);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  void _updateMobilityItem(String id, String title, String subtitle) {
    setState(() {
      _routine = _routine.copyWith(
        mobilityItems: _routine.mobilityItems
            .map(
              (e) =>
                  e.id == id ? e.copyWith(title: title, subtitle: subtitle) : e,
            )
            .toList(),
      );
    });
  }

  void _updateExercise(
    int weekIndex,
    int dayIndex,
    String exerciseId, {
    String? name,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
    List<ExerciseSet>? setDetails,
  }) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    setState(() {
      final day = week.days[dayIndex];
      final newEx = day.exercises.map((e) {
        if (e.id != exerciseId) return e;
        return e.copyWith(
          name: name ?? e.name,
          sets: sets ?? e.sets,
          reps: reps ?? e.reps,
          rpe: rpe ?? e.rpe,
          note: note ?? e.note,
          setDetails: setDetails ?? e.setDetails,
        );
      }).toList();
      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(exercises: newEx);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  void _addSetToExercise(int weekIndex, int dayIndex, String exerciseId) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    setState(() {
      final day = week.days[dayIndex];
      final newEx = day.exercises.map((e) {
        if (e.id != exerciseId) return e;
        final details = [...e.effectiveSetDetails, const ExerciseSet()];
        return e.copyWith(setDetails: details);
      }).toList();
      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(exercises: newEx);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  void _updateExerciseSet(
    int weekIndex,
    int dayIndex,
    String exerciseId,
    int setIndex, {
    String? line,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
  }) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    setState(() {
      final day = week.days[dayIndex];
      final newEx = day.exercises.map((e) {
        if (e.id != exerciseId) return e;
        final details = e.effectiveSetDetails;
        if (setIndex < 0 || setIndex >= details.length) return e;
        final newDetails = List<ExerciseSet>.from(details);
        final cur = details[setIndex];
        if (line != null) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty) {
            newDetails[setIndex] = ExerciseSet(
              line: trimmed,
              sets: '1',
              reps: '',
              rpe: '',
              note: note ?? cur.note,
            );
          } else {
            newDetails[setIndex] = cur.copyWith(note: note ?? cur.note);
          }
        } else if (sets != null || reps != null || rpe != null) {
          newDetails[setIndex] = ExerciseSet(
            line: '',
            sets: sets ?? cur.sets,
            reps: reps ?? cur.reps,
            rpe: rpe ?? cur.rpe,
            note: note ?? cur.note,
          );
        } else {
          newDetails[setIndex] = cur.copyWith(note: note ?? cur.note);
        }
        return e.copyWith(setDetails: newDetails);
      }).toList();
      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(exercises: newEx);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  void _removeExerciseSet(
    int weekIndex,
    int dayIndex,
    String exerciseId,
    int setIndex,
  ) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    setState(() {
      final day = week.days[dayIndex];
      final newEx = day.exercises.map((e) {
        if (e.id != exerciseId) return e;
        final details = e.effectiveSetDetails;
        if (details.length <= 1) return e;
        if (setIndex < 0 || setIndex >= details.length) return e;
        final newDetails = List<ExerciseSet>.from(details)..removeAt(setIndex);
        return e.copyWith(setDetails: newDetails);
      }).toList();
      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(exercises: newEx);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  void _assignToSuperset(
    int weekIndex,
    int dayIndex,
    String exerciseId,
    String supersetGroupId,
  ) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    setState(() {
      final day = week.days[dayIndex];
      final newEx = day.exercises
          .map(
            (e) => e.id == exerciseId
                ? e.copyWith(supersetGroupId: supersetGroupId)
                : e,
          )
          .toList();
      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(exercises: newEx);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  void _removeFromSuperset(int weekIndex, int dayIndex, String exerciseId) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    setState(() {
      final day = week.days[dayIndex];
      final newEx = day.exercises
          .map(
            (e) =>
                e.id == exerciseId ? e.copyWith(clearSupersetGroupId: true) : e,
          )
          .toList();
      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(exercises: newEx);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  bool get _showMobilityContent =>
      widget.variant == WorkoutBuilderVariant.mobility && _mobilityExpanded;
  _TrainingVariant get _trainingVariant {
    switch (widget.variant) {
      case WorkoutBuilderVariant.mobility:
        return _TrainingVariant.mobility;
      case WorkoutBuilderVariant.multiset:
        return _TrainingVariant.multiset;
      case WorkoutBuilderVariant.superset:
      case WorkoutBuilderVariant.intuitiveSuperset:
        return _TrainingVariant.superset;
    }
  }

  @override
  void dispose() {
    _routineNameController.dispose();
    _initialWeekController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final hideExportMenu =
        widget.editorMode && widget.customerId == kWorkoutPlanTemplateScopeId;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/customers');
            }
          },
        ),
        title: Text(
          l10n.workoutBuilderTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        actions: [
          if (!widget.editorMode)
            IconButton(
              icon: const Icon(Icons.bookmark_outline),
              tooltip: l10n.workoutTemplatesTitle,
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.push('/workouts/templates');
              },
            ),
          if (!_loading && !hideExportMenu)
            PopupMenuButton<String>(
              icon: const Icon(Icons.ios_share),
              tooltip: l10n.workoutExport,
              onSelected: (value) {
                if (value == 'pdf') _showPdfExportSheet();
                if (value == 'excel') _exportExcelAndShare();
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'pdf', child: Text(l10n.workoutExportPdf)),
                PopupMenuItem(
                  value: 'excel',
                  child: Text(l10n.workoutExportExcel),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 88,
              height: 36,
              child: FilledButton(
                onPressed: (_loading || _saving) ? null : _saveRoutine,
                style: FilledButton.styleFrom(
                  backgroundColor: StitchM3Theme.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: _saving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(l10n.customerSave),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: cs.outline, height: 1),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Routine name
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.workoutBuilderRoutineNameLabel,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: StitchM3Theme.accent,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _routineNameController,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                                maxLines: 2,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: false,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  hintText: l10n.workoutBuilderRoutineNameHint,
                                  hintStyle: theme.textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: cs.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Routine start date (plan ordering / display)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(
                                  context,
                                ).workoutRoutineStartDate,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: StitchM3Theme.accent,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: _pickRoutineStartDate,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 20,
                                        color: cs.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _routine.startDate != null
                                              ? MaterialLocalizations.of(
                                                  context,
                                                ).formatFullDate(
                                                  _routine.startDate!,
                                                )
                                              : AppLocalizations.of(
                                                  context,
                                                ).workoutRoutineStartDatePlaceholder,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    _routine.startDate != null
                                                    ? cs.onSurface
                                                    : cs.onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Starting week (editor mode only)
                        if (widget.editorMode)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  ).workoutStartingWeek,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: StitchM3Theme.accent,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _initialWeekController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    hintText: AppLocalizations.of(
                                      context,
                                    ).workoutStartingWeekHint,
                                    hintStyle: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: cs.onSurfaceVariant,
                                        ),
                                  ),
                                  onChanged: (s) {
                                    final v = int.tryParse(s);
                                    if (v != null && v >= 1) {
                                      setState(() => _initialWeekNumber = v);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        // Mobility Routine (expanded content only in mobility variant)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () => setState(
                                  () => _mobilityExpanded = !_mobilityExpanded,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _mobilityExpanded
                                              ? Icons.expand_more
                                              : Icons.chevron_right,
                                          color: cs.onSurfaceVariant,
                                          size: 24,
                                        ),
                                        Icon(
                                          Icons.accessibility_new,
                                          color: StitchM3Theme.accent,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.workoutBuilderMobilityRoutineTitle,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: cs.onSurface,
                                              ),
                                        ),
                                      ],
                                    ),
                                    TextButton.icon(
                                      onPressed: _addMobilityItem,
                                      icon: Icon(
                                        Icons.add,
                                        size: 18,
                                        color: StitchM3Theme.accent,
                                      ),
                                      label: Text(
                                        l10n.workoutBuilderAddShort,
                                        style: TextStyle(
                                          color: StitchM3Theme.accent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_showMobilityContent) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            for (
                                              var i = 0;
                                              i <
                                                  _routine
                                                      .mobilitySections
                                                      .length;
                                              i++
                                            ) ...[
                                              if (i > 0)
                                                const SizedBox(width: 8),
                                              _MobilitySectionChip(
                                                label: _routine
                                                    .mobilitySections[i]
                                                    .name,
                                                selected:
                                                    _selectedMobilitySectionIndex
                                                        .clamp(
                                                          0,
                                                          _routine
                                                                  .mobilitySections
                                                                  .length -
                                                              1,
                                                        ) ==
                                                    i,
                                                onTap: () => setState(
                                                  () =>
                                                      _selectedMobilitySectionIndex =
                                                          i,
                                                ),
                                                onEdit: () =>
                                                    _editMobilitySection(i),
                                                onDelete:
                                                    _routine
                                                            .mobilitySections
                                                            .length >
                                                        1
                                                    ? () =>
                                                          _deleteMobilitySection(
                                                            i,
                                                          )
                                                    : null,
                                              ),
                                            ],
                                            const SizedBox(width: 8),
                                            InkWell(
                                              onTap: _addMobilitySection,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.add,
                                                      size: 18,
                                                      color:
                                                          StitchM3Theme.accent,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      l10n.workoutBuilderSectionHeading,
                                                      style: theme
                                                          .textTheme
                                                          .labelSmall
                                                          ?.copyWith(
                                                            color: StitchM3Theme
                                                                .accent,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ReorderableListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  buildDefaultDragHandles: false,
                                  onReorder: _reorderMobility,
                                  itemCount:
                                      _mobilityItemsForSelectedSection.length,
                                  itemBuilder: (context, index) {
                                    final item =
                                        _mobilityItemsForSelectedSection[index];
                                    return Padding(
                                      key: ValueKey(item.id),
                                      padding: EdgeInsets.only(
                                        bottom:
                                            index <
                                                _mobilityItemsForSelectedSection
                                                        .length -
                                                    1
                                            ? 12
                                            : 0,
                                      ),
                                      child: _MobilityItem(
                                        index: index,
                                        title: item.title,
                                        subtitle: item.subtitle,
                                        onEdit: (t, s) =>
                                            _updateMobilityItem(item.id, t, s),
                                        onDelete: () =>
                                            _removeMobilityItem(item.id),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                _DashedButton(
                                  icon: Icons.add,
                                  label: l10n.workoutBuilderAddExercise,
                                  onPressed: _selectedSectionId != null
                                      ? _addMobilityItem
                                      : null,
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Training Program
                        _TrainingSection(
                          theme: theme,
                          cs: cs,
                          expanded: _trainingExpanded,
                          expandedWeekIds: _expandedWeekIds,
                          weeks: _routine.weeks,
                          selectedWeekIndex: _selectedWeekIndex,
                          selectedDayIndex: _selectedDayIndex,
                          onTrainingToggle: () => setState(
                            () => _trainingExpanded = !_trainingExpanded,
                          ),
                          onToggleWeek: (id) => setState(() {
                            if (_expandedWeekIds.contains(id)) {
                              _expandedWeekIds.remove(id);
                            } else {
                              _expandedWeekIds.add(id);
                            }
                          }),
                          onNewWeek: _addWeek,
                          onCloneWeek: _cloneWeek,
                          onDeleteWeek: (weekIndex) =>
                              _confirmDeleteWeek(context, weekIndex),
                          onRenameWeek: _renameWeek,
                          onAddDay: _addDayToWeek,
                          onRenameDay: _renameDay,
                          onDeleteDay: _deleteDay,
                          onAddExercise: _addExerciseToDay,
                          onRemoveExercise: _removeExercise,
                          onMoveExercise: _moveExerciseInDay,
                          onUpdateExercise: _updateExercise,
                          onAddSetToExercise: _addSetToExercise,
                          onUpdateExerciseSet: _updateExerciseSet,
                          onRemoveExerciseSet: _removeExerciseSet,
                          onAssignToSuperset: _assignToSuperset,
                          onRemoveFromSuperset: _removeFromSuperset,
                          onAddExerciseToSuperset: _addExerciseToSuperset,
                          onSelectWeek: (i) =>
                              setState(() => _selectedWeekIndex = i),
                          onSelectDay: (i) =>
                              setState(() => _selectedDayIndex = i),
                          variant: _trainingVariant,
                        ),
                      ],
                    ),
                  ),
                ),
                _WorkoutBuilderBottomNav(navContext: context, selectedIndex: 1),
              ],
            ),
    );
  }
}

class _MobilitySectionChip extends StatelessWidget {
  const _MobilitySectionChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    this.onDelete,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? cs.onSurface : cs.onSurfaceVariant,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.edit,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                if (onDelete != null) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: StitchM3Theme.danger,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            width: 60,
            color: selected ? StitchM3Theme.accent : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _MobilityItem extends StatelessWidget {
  const _MobilityItem({
    required this.index,
    required this.title,
    required this.subtitle,
    this.onEdit,
    this.onDelete,
  });

  final int index;
  final String title;
  final String subtitle;
  final void Function(String title, String subtitle)? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_indicator,
              size: 20,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            InkWell(
              onTap: () => _showEditMobilityDialog(
                context,
                theme,
                cs,
                title,
                subtitle,
                onEdit!,
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 20,
                color: cs.onSurfaceVariant,
              ),
            ),
          if (onEdit != null) const SizedBox(width: 8),
          InkWell(
            onTap: onDelete,
            child: Icon(
              Icons.delete_outline,
              size: 20,
              color: StitchM3Theme.danger,
            ),
          ),
        ],
      ),
    );
  }
}

void _showRenameDayDialog(
  BuildContext context,
  String initialName,
  void Function(String) onSave,
) {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: initialName);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderRenameDayTitle,
    bodyBuilder: (sheetContext) => TextField(
      controller: controller,
      decoration: InputDecoration(labelText: l10n.workoutBuilderDayNameLabel),
      autofocus: false,
      onSubmitted: (_) {
        final name = controller.text.trim();
        if (name.isEmpty) return;
        onSave(name);
        Navigator.of(sheetContext).pop();
      },
    ),
    primaryActionLabel: l10n.customerSave,
    onPrimaryAction: () {
      final name = controller.text.trim();
      if (name.isEmpty) return;
      onSave(name);
      Navigator.of(context).pop();
    },
  );
}

void _showRenameWeekDialog(
  BuildContext context,
  String initialName,
  void Function(String) onSave,
) {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: initialName);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderRenameWeekTitle,
    bodyBuilder: (sheetContext) => TextField(
      controller: controller,
      decoration: InputDecoration(labelText: l10n.workoutBuilderWeekNameLabel),
      autofocus: false,
      onSubmitted: (_) {
        final name = controller.text.trim();
        if (name.isEmpty) return;
        onSave(name);
        Navigator.of(sheetContext).pop();
      },
    ),
    primaryActionLabel: l10n.customerSave,
    onPrimaryAction: () {
      final name = controller.text.trim();
      if (name.isEmpty) return;
      onSave(name);
      Navigator.of(context).pop();
    },
  );
}

void _showEditMobilityDialog(
  BuildContext context,
  ThemeData theme,
  ColorScheme cs,
  String initialTitle,
  String initialSubtitle,
  void Function(String title, String subtitle) onSave,
) {
  final l10n = AppLocalizations.of(context);
  final titleController = TextEditingController(text: initialTitle);
  final subtitleController = TextEditingController(text: initialSubtitle);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderEditMobilityExerciseTitle,
    fullScreen: false,
    bodyBuilder: (sheetContext) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: titleController,
          decoration: InputDecoration(labelText: l10n.mobilityTitle),
          autofocus: false,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: subtitleController,
          decoration: InputDecoration(labelText: l10n.mobilitySubtitle),
          maxLines: 2,
        ),
      ],
    ),
    primaryActionLabel: l10n.customerSave,
    onPrimaryAction: () {
      onSave(titleController.text.trim(), subtitleController.text.trim());
      Navigator.of(context).pop();
    },
  );
}

enum _MobilitySource { createNew, fromMobilityLibrary, fromExerciseLibrary }

/// Shows the "Add mobility exercise" dialog: create on the fly, from mobility library, or from exercise library.
void _showAddMobilityExerciseDialog(
  BuildContext context,
  ThemeData theme,
  ColorScheme cs,
  void Function(String title, String subtitle, String? customExerciseId) onSave,
) {
  final l10n = AppLocalizations.of(context);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderAddMobilityExerciseTitle,
    fullScreen: true,
    bodyBuilder: (sheetContext) => _AddMobilityExerciseDialogContent(
      theme: theme,
      cs: cs,
      onSave: onSave,
      onCancel: () => Navigator.of(sheetContext).pop(),
    ),
  );
}

class _AddMobilityExerciseDialogContent extends StatefulWidget {
  const _AddMobilityExerciseDialogContent({
    required this.theme,
    required this.cs,
    required this.onSave,
    required this.onCancel,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final void Function(String title, String subtitle, String? customExerciseId)
  onSave;
  final VoidCallback onCancel;

  @override
  State<_AddMobilityExerciseDialogContent> createState() =>
      _AddMobilityExerciseDialogContentState();
}

class _AddMobilityExerciseDialogContentState
    extends State<_AddMobilityExerciseDialogContent> {
  final _customExerciseRepo = CustomExerciseRepository();
  _MobilitySource _source = _MobilitySource.fromMobilityLibrary;
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  bool _saveToLibrary = false;
  List<CustomExerciseItem> _mobilityOptions = [];
  List<CustomExerciseItem> _exerciseOptions = [];
  CustomExerciseItem? _selectedLibraryItem;
  bool _loadingMobility = false;
  bool _loadingExercise = false;
  bool _saving = false;
  final Map<String, int> _mobilityDepth = {};
  final Map<String, String> _mobilityParentName = {};
  final Map<String, int> _exerciseDepth = {};
  final Map<String, String> _exerciseParentName = {};

  bool get _apiConfigured => true;

  String _exerciseDisplayName(
    CustomExerciseItem e, {
    bool useMobility = false,
  }) {
    final parentName = useMobility
        ? _mobilityParentName[e.id]
        : _exerciseParentName[e.id];
    return parentName != null ? '$parentName › ${e.name}' : e.name;
  }

  @override
  void initState() {
    super.initState();
    _loadMobilityOptions();
    _loadExerciseOptions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  Future<void> _loadMobilityOptions() async {
    setState(() => _loadingMobility = true);
    try {
      final items = await _customExerciseRepo.getTree(mobility: true);
      final flat = <CustomExerciseItem>[];
      void visit(CustomExerciseItem node, int depth, String? parentName) {
        flat.add(node);
        _mobilityDepth[node.id] = depth;
        if (parentName != null) {
          _mobilityParentName[node.id] = parentName;
        }
        for (final c in node.children) {
          visit(c, depth + 1, node.name);
        }
      }

      for (final node in items) {
        visit(node, 0, null);
      }
      if (mounted) {
        setState(() {
          _mobilityOptions = flat;
          _loadingMobility = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingMobility = false);
      }
    }
  }

  Future<void> _loadExerciseOptions() async {
    setState(() => _loadingExercise = true);
    try {
      final items = await _customExerciseRepo.getTree(mobility: false);
      final flat = <CustomExerciseItem>[];
      void visit(CustomExerciseItem node, int depth, String? parentName) {
        flat.add(node);
        _exerciseDepth[node.id] = depth;
        if (parentName != null) {
          _exerciseParentName[node.id] = parentName;
        }
        for (final c in node.children) {
          visit(c, depth + 1, node.name);
        }
      }

      for (final node in items) {
        visit(node, 0, null);
      }
      if (mounted) {
        setState(() {
          _exerciseOptions = flat;
          _loadingExercise = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingExercise = false);
      }
    }
  }

  Future<void> _handleSave() async {
    final l10n = AppLocalizations.of(context);
    String title;
    String subtitle;
    String? customExerciseId;

    switch (_source) {
      case _MobilitySource.createNew:
        title = _titleController.text.trim();
        subtitle = _subtitleController.text.trim();
        if (title.isEmpty && subtitle.isEmpty) return;
        if (title.isEmpty) title = l10n.workoutBuilderNewExerciseDefault;
        if (_saveToLibrary && _apiConfigured) {
          setState(() => _saving = true);
          try {
            final body = {
              'name': title,
              'description': subtitle.isEmpty ? null : subtitle,
              'isMobility': true,
            };
            final res = await _customExerciseRepo.create(body);
            final id = res['id']?.toString();
            if (id != null && mounted) {
              customExerciseId = id;
              widget.onSave(title, subtitle, customExerciseId);
              Navigator.of(context).pop();
            }
          } catch (_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.workoutExportError),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
          if (mounted) setState(() => _saving = false);
          return;
        }
        break;
      case _MobilitySource.fromMobilityLibrary:
      case _MobilitySource.fromExerciseLibrary:
        if (_selectedLibraryItem == null) return;
        title = _selectedLibraryItem!.name;
        subtitle = _selectedLibraryItem!.description ?? '';
        customExerciseId = _selectedLibraryItem!.id;
        break;
    }

    widget.onSave(title, subtitle, customExerciseId);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = widget.theme;
    final cs = widget.cs;

    final libraryOptions = _source == _MobilitySource.fromMobilityLibrary
        ? _mobilityOptions
        : _exerciseOptions;
    final loadingLibrary = _source == _MobilitySource.fromMobilityLibrary
        ? _loadingMobility
        : _loadingExercise;

    final isMobilityLibrary = _source == _MobilitySource.fromMobilityLibrary;
    final depthMap = isMobilityLibrary ? _mobilityDepth : _exerciseDepth;
    String displayName(CustomExerciseItem e) =>
        _exerciseDisplayName(e, useMobility: isMobilityLibrary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_apiConfigured)
                SegmentedButton<_MobilitySource>(
                  segments: [
                    ButtonSegment(
                      value: _MobilitySource.fromMobilityLibrary,
                      label: Text(l10n.mobilityFromMobilityLibrary),
                      icon: const Icon(Icons.self_improvement, size: 18),
                    ),
                    ButtonSegment(
                      value: _MobilitySource.createNew,
                      label: Text(l10n.mobilityCreateNew),
                      icon: const Icon(Icons.add, size: 18),
                    ),
                    ButtonSegment(
                      value: _MobilitySource.fromExerciseLibrary,
                      label: Text(l10n.mobilityFromExerciseLibrary),
                      icon: const Icon(Icons.fitness_center, size: 18),
                    ),
                  ],
                  selected: {_source},
                  onSelectionChanged: (s) => setState(() {
                    _source = s.first;
                    _selectedLibraryItem = null;
                  }),
                ),
              if (!_apiConfigured) const SizedBox(height: 8),
              const SizedBox(height: 12),
              if (_source == _MobilitySource.createNew) ...[
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.mobilityTitle,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  autofocus: false,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _subtitleController,
                  decoration: InputDecoration(
                    labelText: l10n.mobilitySubtitle,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                if (_apiConfigured) ...[
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    value: _saveToLibrary,
                    onChanged: (v) =>
                        setState(() => _saveToLibrary = v ?? false),
                    title: Text(
                      l10n.mobilitySaveToLibrary,
                      style: theme.textTheme.bodyMedium,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ],
              ] else if (loadingLibrary)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (libraryOptions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    l10n.recordSearchExerciseHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                Autocomplete<CustomExerciseItem>(
                  initialValue: _selectedLibraryItem != null
                      ? TextEditingValue(
                          text: displayName(_selectedLibraryItem!),
                        )
                      : const TextEditingValue(),
                  optionsBuilder: (TextEditingValue value) {
                    final query = value.text.trim().toLowerCase();
                    if (query.isEmpty) return libraryOptions;
                    return libraryOptions.where(
                      (e) => displayName(e).toLowerCase().contains(query),
                    );
                  },
                  displayStringForOption: displayName,
                  onSelected: (e) => setState(() => _selectedLibraryItem = e),
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) =>
                          TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              hintText: l10n.recordSearchExerciseHint,
                              border: const OutlineInputBorder(),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
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
                            final depth = depthMap[e.id] ?? 0;
                            return Padding(
                              padding: EdgeInsets.only(
                                left: 16.0 + (depth * 16.0),
                              ),
                              child: ListTile(
                                dense: depth > 0,
                                title: Text(
                                  depth > 0 ? e.name : displayName(e),
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
            ],
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
                onPressed: _saving
                    ? null
                    : () {
                        if (_source == _MobilitySource.fromMobilityLibrary ||
                            _source == _MobilitySource.fromExerciseLibrary) {
                          if (_selectedLibraryItem == null) return;
                        }
                        _handleSave();
                      },
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
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

/// Shows the "Add exercise" dialog: choose from custom exercise library or create new on the fly.
/// When [customerId] is set, records for the selected exercise are loaded and shown.
void _showAddExerciseDialog(
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
    bodyBuilder: (sheetContext) => _AddExerciseDialogContent(
      theme: theme,
      cs: cs,
      customerId: customerId,
      onSaveWithSets: onSaveWithSets,
      onCancel: () => Navigator.of(sheetContext).pop(),
    ),
  );
}

class _AddExerciseDialogContent extends StatefulWidget {
  const _AddExerciseDialogContent({
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
  State<_AddExerciseDialogContent> createState() =>
      _AddExerciseDialogContentState();
}

class _AddExerciseDialogContentState extends State<_AddExerciseDialogContent> {
  final _customExerciseRepo = CustomExerciseRepository();
  final _recordRepo = CustomerExerciseRecordRepository();
  List<CustomExerciseItem> _exerciseOptions = [];
  final Map<String, int> _exerciseDepth = {};
  final Map<String, String> _exerciseParentName = {};
  bool _loadingExercises = true;
  bool _fromLibrary = true;
  CustomExerciseItem? _selectedExercise;
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  final _loadPercentInputController = TextEditingController();
  final List<_SetEditControllers> _setControllers = [];
  bool _saving = false;
  List<CustomerExerciseRecord> _recordsForExercise = [];
  bool _loadingRecords = false;

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
      _SetEditControllers(
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
      if (mounted) {
        setState(() {
          _exerciseOptions = flat;
          _loadingExercises = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingExercises = false);
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
          Autocomplete<CustomExerciseItem>(
            initialValue: _selectedExercise != null
                ? TextEditingValue(
                    text: _exerciseDisplayName(_selectedExercise!),
                  )
                : const TextEditingValue(),
            optionsBuilder: (TextEditingValue value) {
              final query = value.text.trim().toLowerCase();
              if (query.isEmpty) return _exerciseOptions;
              return _exerciseOptions.where(
                (e) => _exerciseDisplayName(e).toLowerCase().contains(query),
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
                _SetEditControllers(
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

void _showEditExerciseDialog(
  BuildContext context,
  ThemeData theme,
  ColorScheme cs,
  String initialName,
  String initialSets,
  String initialReps,
  String initialRpe,
  String initialNote,
  void Function(String name, String sets, String reps, String rpe, String note)
  onSave, {
  List<ExerciseSet>? initialSetDetails,
  void Function(String name, String note, List<ExerciseSet> setDetails)?
  onSaveWithSets,
}) {
  final nameController = TextEditingController(text: initialName);
  final noteController = TextEditingController(text: initialNote);
  final setsController = TextEditingController(text: initialSets);
  final repsController = TextEditingController(text: initialReps);
  final rpeController = TextEditingController(text: initialRpe);
  final useMultiSet =
      onSaveWithSets != null &&
      initialSetDetails != null &&
      initialSetDetails.isNotEmpty;
  final setControllers = useMultiSet
      ? initialSetDetails.map((s) {
          String sets = s.sets.trim();
          String reps = s.reps.trim();
          String load = s.rpe.trim();
          if (sets.isEmpty && reps.isEmpty && s.line.trim().isNotEmpty) {
            final m = RegExp(r'^(\d+)x(\d+)\s*(.*)$').firstMatch(s.line.trim());
            if (m != null) {
              sets = m.group(1)!;
              reps = m.group(2)!;
              load = (m.group(3) ?? '').trim();
            } else {
              sets = s.line.trim();
            }
          }
          return _SetEditControllers(
            TextEditingController(text: sets),
            TextEditingController(text: reps),
            TextEditingController(text: load),
            TextEditingController(text: s.note),
          );
        }).toList()
      : <_SetEditControllers>[];

  final modalSaving = ValueNotifier<bool>(false);
  final l10n = AppLocalizations.of(context);
  showAppBottomSheet<void>(
    context: context,
    title: initialName.trim().isEmpty
        ? l10n.workoutBuilderAddExerciseTitle
        : l10n.workoutBuilderEditExerciseTitle,
    fullScreen: useMultiSet,
    bodyBuilder: (sheetContext) => StatefulBuilder(
      builder: (context, setState) {
        void addSetRow() {
          setState(() {
            setControllers.add(
              _SetEditControllers(
                TextEditingController(),
                TextEditingController(),
                TextEditingController(),
                TextEditingController(),
              ),
            );
          });
        }

        void removeSetRow(int i) {
          if (setControllers.length <= 1) return;
          setState(() {
            setControllers.removeAt(i);
          });
        }

        final denseDecoration = InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.workoutBuilderNameLabel,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              autofocus: false,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: l10n.workoutBuilderNoteOptionalLabel,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              maxLines: 1,
            ),
            if (useMultiSet) ...[
              const SizedBox(height: 12),
              Text(
                l10n.workoutBuilderMultiSetBlockHeader,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              ...setControllers.asMap().entries.map((entry) {
                final i = entry.key;
                final c = entry.value;
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
                          color: setControllers.length > 1
                              ? StitchM3Theme.danger
                              : cs.onSurfaceVariant,
                        ),
                        onPressed: setControllers.length > 1
                            ? () => removeSetRow(i)
                            : null,
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: addSetRow,
                  icon: Icon(Icons.add, size: 18, color: StitchM3Theme.accent),
                  label: Text(
                    l10n.workoutBuilderAddSet,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: StitchM3Theme.accent,
                    ),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
              TextField(
                controller: setsController,
                decoration: denseDecoration.copyWith(
                  labelText: l10n.workoutBuilderSetsLabel,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: repsController,
                decoration: denseDecoration.copyWith(
                  labelText: l10n.workoutBuilderRepsLabel,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: rpeController,
                decoration: denseDecoration.copyWith(
                  labelText: l10n.workoutBuilderRpeOrLoadLabel,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(l10n.customerCancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: modalSaving,
                    builder: (_, saving, __) => FilledButton(
                      onPressed: saving
                          ? null
                          : () {
                              modalSaving.value = true;
                              final name = nameController.text.trim();
                              final note = noteController.text.trim();
                              if (useMultiSet) {
                                final details = setControllers.map((c) {
                                  final sets = c.sets.text.trim();
                                  final reps = c.reps.text.trim();
                                  final load = c.load.text.trim();
                                  final noteSet = c.note.text.trim();
                                  if (sets.isNotEmpty ||
                                      reps.isNotEmpty ||
                                      load.isNotEmpty) {
                                    return ExerciseSet(
                                      sets: sets.isEmpty ? '1' : sets,
                                      reps: reps,
                                      rpe: load,
                                      note: noteSet,
                                    );
                                  }
                                  return ExerciseSet(note: noteSet);
                                }).toList();
                                onSaveWithSets(name, note, details);
                              } else {
                                onSave(
                                  name,
                                  setsController.text.trim(),
                                  repsController.text.trim(),
                                  rpeController.text.trim(),
                                  note,
                                );
                              }
                              Navigator.of(sheetContext).pop();
                            },
                      child: saving
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  cs.onPrimary,
                                ),
                              ),
                            )
                          : Text(l10n.customerSave),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        );
      },
    ),
  );
}

class _SetEditControllers {
  _SetEditControllers(this.sets, this.reps, this.load, this.note);
  final TextEditingController sets;
  final TextEditingController reps;
  final TextEditingController load;
  final TextEditingController note;
}

class _DashedButton extends StatelessWidget {
  const _DashedButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: cs.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        ),
        foregroundColor: cs.onSurfaceVariant,
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

enum _TrainingVariant { mobility, multiset, superset }

class _TrainingSection extends StatelessWidget {
  const _TrainingSection({
    required this.theme,
    required this.cs,
    required this.expanded,
    required this.expandedWeekIds,
    required this.weeks,
    required this.selectedWeekIndex,
    required this.selectedDayIndex,
    required this.onTrainingToggle,
    required this.onToggleWeek,
    required this.onNewWeek,
    required this.onCloneWeek,
    required this.onDeleteWeek,
    required this.onRenameWeek,
    required this.onAddDay,
    required this.onRenameDay,
    required this.onDeleteDay,
    required this.onAddExercise,
    required this.onRemoveExercise,
    required this.onMoveExercise,
    required this.onUpdateExercise,
    required this.onAddSetToExercise,
    required this.onUpdateExerciseSet,
    required this.onRemoveExerciseSet,
    required this.onAssignToSuperset,
    required this.onRemoveFromSuperset,
    required this.onAddExerciseToSuperset,
    required this.onSelectWeek,
    required this.onSelectDay,
    required this.variant,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final bool expanded;
  final Set<String> expandedWeekIds;
  final List<Week> weeks;
  final int selectedWeekIndex;
  final int selectedDayIndex;
  final VoidCallback onTrainingToggle;
  final void Function(String) onToggleWeek;
  final VoidCallback onNewWeek;
  final void Function(int) onCloneWeek;
  final void Function(int) onDeleteWeek;
  final void Function(int, String) onRenameWeek;
  final void Function(int) onAddDay;
  final void Function(int, int, String) onRenameDay;
  final void Function(int, int) onDeleteDay;
  final void Function(int, int) onAddExercise;
  final void Function(int, int, String) onRemoveExercise;
  final void Function(int, int, String, {required bool up}) onMoveExercise;
  final void Function(
    int,
    int,
    String, {
    String? name,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
    List<ExerciseSet>? setDetails,
  })
  onUpdateExercise;
  final void Function(int, int, String) onAddSetToExercise;
  final void Function(
    int,
    int,
    String,
    int, {
    String? line,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
  })
  onUpdateExerciseSet;
  final void Function(int, int, String, int) onRemoveExerciseSet;
  final void Function(int, int, String, String) onAssignToSuperset;
  final void Function(int, int, String) onRemoveFromSuperset;
  final void Function(int, int, String) onAddExerciseToSuperset;
  final void Function(int) onSelectWeek;
  final void Function(int) onSelectDay;
  final _TrainingVariant variant;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onTrainingToggle,
                child: Row(
                  children: [
                    Icon(
                      expanded ? Icons.expand_more : Icons.chevron_right,
                      color: cs.onSurfaceVariant,
                      size: 24,
                    ),
                    Icon(
                      Icons.fitness_center,
                      color: StitchM3Theme.accent,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.workoutBuilderTrainingProgram,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onNewWeek,
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: StitchM3Theme.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16, color: StitchM3Theme.accent),
                      const SizedBox(width: 4),
                      Text(
                        l10n.workoutBuilderNewWeek,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: StitchM3Theme.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (expanded) ...[
            if (variant == _TrainingVariant.mobility)
              ...weeks.asMap().entries.map(
                (e) => _WeekAccordion(
                  key: ValueKey(e.value.id),
                  weekIndex: e.key,
                  week: e.value,
                  expanded: expandedWeekIds.contains(e.value.id),
                  onToggle: () => onToggleWeek(e.value.id),
                  onClone: () => onCloneWeek(e.key),
                  onDelete: () => onDeleteWeek(e.key),
                  onRenameWeek: (newName) => onRenameWeek(e.key, newName),
                  onAddDay: () => onAddDay(e.key),
                  onRenameDay: (dayIndex, newName) =>
                      onRenameDay(e.key, dayIndex, newName),
                  onDeleteDay: (dayIndex) => onDeleteDay(e.key, dayIndex),
                  onAddExercise: onAddExercise,
                  onRemoveExercise: onRemoveExercise,
                  onMoveExercise: onMoveExercise,
                  onUpdateExercise: onUpdateExercise,
                  onAddSetToExercise: onAddSetToExercise,
                  onUpdateExerciseSet: onUpdateExerciseSet,
                  onRemoveExerciseSet: onRemoveExerciseSet,
                  onAssignToSuperset: onAssignToSuperset,
                  onRemoveFromSuperset: onRemoveFromSuperset,
                  onAddExerciseToSuperset: onAddExerciseToSuperset,
                  theme: theme,
                  cs: cs,
                ),
              ),
            if (variant == _TrainingVariant.multiset)
              _WeekDayChipsAndCards(
                theme: theme,
                cs: cs,
                superset: false,
                weeks: weeks,
                selectedWeekIndex: selectedWeekIndex,
                selectedDayIndex: selectedDayIndex,
                onSelectWeek: onSelectWeek,
                onSelectDay: onSelectDay,
                onAddExercise: onAddExercise,
                onRemoveExercise: onRemoveExercise,
                onMoveExercise: onMoveExercise,
                onUpdateExercise: onUpdateExercise,
                onAddSetToExercise: onAddSetToExercise,
                onUpdateExerciseSet: onUpdateExerciseSet,
                onRemoveExerciseSet: onRemoveExerciseSet,
                onAssignToSuperset: onAssignToSuperset,
                onRemoveFromSuperset: onRemoveFromSuperset,
                onAddExerciseToSuperset: onAddExerciseToSuperset,
                onAddDay: onAddDay,
                onRenameDay: onRenameDay,
                onDeleteDay: onDeleteDay,
              ),
            if (variant == _TrainingVariant.superset)
              _WeekDayChipsAndCards(
                theme: theme,
                cs: cs,
                superset: true,
                weeks: weeks,
                selectedWeekIndex: selectedWeekIndex,
                selectedDayIndex: selectedDayIndex,
                onSelectWeek: onSelectWeek,
                onSelectDay: onSelectDay,
                onAddExercise: onAddExercise,
                onRemoveExercise: onRemoveExercise,
                onMoveExercise: onMoveExercise,
                onUpdateExercise: onUpdateExercise,
                onAddSetToExercise: onAddSetToExercise,
                onUpdateExerciseSet: onUpdateExerciseSet,
                onRemoveExerciseSet: onRemoveExerciseSet,
                onAssignToSuperset: onAssignToSuperset,
                onRemoveFromSuperset: onRemoveFromSuperset,
                onAddExerciseToSuperset: onAddExerciseToSuperset,
                onAddDay: onAddDay,
                onRenameDay: onRenameDay,
                onDeleteDay: onDeleteDay,
              ),
          ],
        ],
      ),
    );
  }
}

class _WeekAccordion extends StatelessWidget {
  const _WeekAccordion({
    super.key,
    required this.weekIndex,
    required this.week,
    required this.expanded,
    required this.onToggle,
    required this.onClone,
    required this.onDelete,
    required this.onRenameWeek,
    required this.onAddDay,
    required this.onRenameDay,
    required this.onDeleteDay,
    required this.onAddExercise,
    required this.onRemoveExercise,
    required this.onMoveExercise,
    required this.onUpdateExercise,
    required this.onAddSetToExercise,
    required this.onUpdateExerciseSet,
    required this.onRemoveExerciseSet,
    required this.onAssignToSuperset,
    required this.onRemoveFromSuperset,
    required this.onAddExerciseToSuperset,
    required this.theme,
    required this.cs,
  });

  final int weekIndex;
  final Week week;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onClone;
  final VoidCallback onDelete;
  final void Function(String newName) onRenameWeek;
  final VoidCallback onAddDay;
  final void Function(int dayIndex, String newName) onRenameDay;
  final void Function(int dayIndex) onDeleteDay;
  final void Function(int, int) onAddExercise;
  final void Function(int, int, String) onRemoveExercise;
  final void Function(int, int, String, {required bool up}) onMoveExercise;
  final void Function(
    int,
    int,
    String, {
    String? name,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
    List<ExerciseSet>? setDetails,
  })
  onUpdateExercise;
  final void Function(int, int, String) onAddSetToExercise;
  final void Function(
    int,
    int,
    String,
    int, {
    String? line,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
  })
  onUpdateExerciseSet;
  final void Function(int, int, String, int) onRemoveExerciseSet;
  final void Function(int, int, String, String) onAssignToSuperset;
  final void Function(int, int, String) onRemoveFromSuperset;
  final void Function(int, int, String) onAddExerciseToSuperset;
  final ThemeData theme;
  final ColorScheme cs;
  static final Map<String, int> _selectedDayByWeekId = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        InkWell(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: cs.surfaceContainerHighest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      expanded ? Icons.expand_more : Icons.chevron_right,
                      color: cs.onSurfaceVariant,
                      size: 24,
                    ),
                    Text(
                      week.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: onClone,
                      icon: Icon(
                        Icons.copy,
                        size: 14,
                        color: cs.onSurfaceVariant,
                      ),
                      label: Text(
                        l10n.workoutBuilderClone,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: cs.onSurfaceVariant,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      onSelected: (value) {
                        if (value == 'clone') onClone();
                        if (value == 'rename')
                          _showRenameWeekDialog(
                            context,
                            week.name,
                            onRenameWeek,
                          );
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'clone',
                          child: Row(
                            children: [
                              Icon(Icons.copy, size: 18, color: cs.onSurface),
                              const SizedBox(width: 12),
                              Text(l10n.workoutBuilderDuplicateWeek),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'rename',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: cs.onSurface,
                              ),
                              const SizedBox(width: 12),
                              Text(l10n.workoutBuilderRenameWeekMenu),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: StitchM3Theme.danger,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.workoutBuilderDeleteWeekMenu,
                                style: TextStyle(color: StitchM3Theme.danger),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          StatefulBuilder(
            builder: (context, setLocalState) {
              if (week.days.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: _DashedButton(
                    icon: Icons.calendar_today,
                    label: l10n.workoutBuilderAddDayToWeek(weekIndex + 1),
                    onPressed: onAddDay,
                  ),
                );
              }

              final savedIndex = _selectedDayByWeekId[week.id] ?? 0;
              final dayIndex = savedIndex.clamp(0, week.days.length - 1);
              _selectedDayByWeekId[week.id] = dayIndex;
              final day = week.days[dayIndex];

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: week.days.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final d = week.days[i];
                          return ChoiceChip(
                            label: Text(d.name),
                            selected: i == dayIndex,
                            onSelected: (_) {
                              setLocalState(
                                () => _selectedDayByWeekId[week.id] = i,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          day.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: StitchM3Theme.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.settings,
                            size: 18,
                            color: cs.onSurfaceVariant,
                          ),
                          padding: EdgeInsets.zero,
                          onSelected: (value) {
                            if (value == 'rename') {
                              _showRenameDayDialog(
                                context,
                                day.name,
                                (newName) => onRenameDay(dayIndex, newName),
                              );
                            }
                            if (value == 'delete') onDeleteDay(dayIndex);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'rename',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: cs.onSurface,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    ).workoutBuilderRenameDayTitle,
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: StitchM3Theme.danger,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    ).workoutBuilderDeleteDayMenu,
                                    style: TextStyle(
                                      color: StitchM3Theme.danger,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...(() {
                      final partition = partitionExercisesBySuperset(
                        day.exercises,
                      );
                      return partition.asMap().entries.map((entry) {
                        final isLast = entry.key == partition.length - 1;
                        final item = entry.value;
                        if (item is Exercise) {
                          final ex = item;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ExerciseCard(
                              theme: theme,
                              cs: cs,
                              exercise: ex,
                              compact: true,
                              showAddExercise: isLast,
                              onAddExercise: isLast
                                  ? () => onAddExercise(weekIndex, dayIndex)
                                  : null,
                              onRemove: () =>
                                  onRemoveExercise(weekIndex, dayIndex, ex.id),
                              onMoveUp: () => onMoveExercise(
                                weekIndex,
                                dayIndex,
                                ex.id,
                                up: true,
                              ),
                              onMoveDown: () => onMoveExercise(
                                weekIndex,
                                dayIndex,
                                ex.id,
                                up: false,
                              ),
                              onEdit:
                                  (name, sets, reps, rpe, note, {setDetails}) =>
                                      onUpdateExercise(
                                        weekIndex,
                                        dayIndex,
                                        ex.id,
                                        name: name,
                                        sets: sets,
                                        reps: reps,
                                        rpe: rpe,
                                        note: note,
                                        setDetails: setDetails,
                                      ),
                              onAddSet: () => onAddSetToExercise(
                                weekIndex,
                                dayIndex,
                                ex.id,
                              ),
                              onUpdateSet: (setIndex, sets, reps, load, note) =>
                                  onUpdateExerciseSet(
                                    weekIndex,
                                    dayIndex,
                                    ex.id,
                                    setIndex,
                                    sets: sets,
                                    reps: reps,
                                    rpe: load,
                                    note: note,
                                  ),
                              onRemoveSet: (setIndex) => onRemoveExerciseSet(
                                weekIndex,
                                dayIndex,
                                ex.id,
                                setIndex,
                              ),
                              supersetOptions: _getSupersetGroupOptions(day)
                                  .where((o) => o.id != ex.supersetGroupId)
                                  .toList(),
                              onAssignToSuperset: (groupId) =>
                                  onAssignToSuperset(
                                    weekIndex,
                                    dayIndex,
                                    ex.id,
                                    groupId,
                                  ),
                              onRemoveFromSuperset: ex.supersetGroupId != null
                                  ? () => onRemoveFromSuperset(
                                      weekIndex,
                                      dayIndex,
                                      ex.id,
                                    )
                                  : null,
                            ),
                          );
                        }
                        final group = item as List<Exercise>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SuperSetBlock(
                                theme: theme,
                                cs: cs,
                                weekIndex: weekIndex,
                                dayIndex: dayIndex,
                                exercises: group,
                                supersetGroupId:
                                    group.isNotEmpty &&
                                        group.first.supersetGroupId != null
                                    ? group.first.supersetGroupId!
                                    : null,
                                onAddExercise: () =>
                                    onAddExercise(weekIndex, dayIndex),
                                onAddExerciseToSuperset:
                                    onAddExerciseToSuperset,
                                onRemoveExercise: onRemoveExercise,
                                onMoveExercise: onMoveExercise,
                                onUpdateExercise: onUpdateExercise,
                                onAddSetToExercise: onAddSetToExercise,
                                onUpdateExerciseSet: onUpdateExerciseSet,
                                onRemoveExerciseSet: onRemoveExerciseSet,
                                onAssignToSuperset: onAssignToSuperset,
                                onRemoveFromSuperset: onRemoveFromSuperset,
                                supersetOptionsForDay: _getSupersetGroupOptions(
                                  day,
                                ),
                              ),
                              if (isLast) ...[
                                const SizedBox(height: 12),
                                _DashedButton(
                                  icon: Icons.add,
                                  label: l10n.workoutBuilderAddExercise,
                                  onPressed: () =>
                                      onAddExercise(weekIndex, dayIndex),
                                ),
                              ],
                            ],
                          ),
                        );
                      });
                    })(),
                    if (day.exercises.isEmpty)
                      _DashedButton(
                        icon: Icons.add,
                        label: l10n.workoutBuilderAddExercise,
                        onPressed: () => onAddExercise(weekIndex, dayIndex),
                      ),
                    const SizedBox(height: 16),
                    _DashedButton(
                      icon: Icons.calendar_today,
                      label: l10n.workoutBuilderAddDayToWeek(weekIndex + 1),
                      onPressed: onAddDay,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _WeekDayChipsAndCards extends StatelessWidget {
  const _WeekDayChipsAndCards({
    required this.theme,
    required this.cs,
    required this.superset,
    required this.weeks,
    required this.selectedWeekIndex,
    required this.selectedDayIndex,
    required this.onSelectWeek,
    required this.onSelectDay,
    required this.onAddExercise,
    required this.onRemoveExercise,
    required this.onMoveExercise,
    required this.onUpdateExercise,
    required this.onAddSetToExercise,
    required this.onUpdateExerciseSet,
    required this.onRemoveExerciseSet,
    required this.onAssignToSuperset,
    required this.onRemoveFromSuperset,
    required this.onAddExerciseToSuperset,
    required this.onAddDay,
    required this.onRenameDay,
    required this.onDeleteDay,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final bool superset;
  final List<Week> weeks;
  final int selectedWeekIndex;
  final int selectedDayIndex;
  final void Function(int) onSelectWeek;
  final void Function(int) onSelectDay;
  final void Function(int, int) onAddExercise;
  final void Function(int, int, String) onRemoveExercise;
  final void Function(int, int, String, {required bool up}) onMoveExercise;
  final void Function(
    int,
    int,
    String, {
    String? name,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
    List<ExerciseSet>? setDetails,
  })
  onUpdateExercise;
  final void Function(int, int, String) onAddSetToExercise;
  final void Function(
    int,
    int,
    String,
    int, {
    String? line,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
  })
  onUpdateExerciseSet;
  final void Function(int, int, String, int) onRemoveExerciseSet;
  final void Function(int, int, String, String) onAssignToSuperset;
  final void Function(int, int, String) onRemoveFromSuperset;
  final void Function(int, int, String) onAddExerciseToSuperset;
  final void Function(int) onAddDay;
  final void Function(int, int, String) onRenameDay;
  final void Function(int, int) onDeleteDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final weekIndex = weeks.isEmpty
        ? 0
        : selectedWeekIndex.clamp(0, weeks.length - 1);
    final week = weeks.isEmpty ? null : weeks[weekIndex];
    final days = week?.days ?? [];
    final dayIndex = selectedDayIndex.clamp(
      0,
      days.isNotEmpty ? days.length - 1 : 0,
    );
    final day = days.isEmpty ? null : days[dayIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (var i = 0; i < weeks.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _Chip(
                  label: weeks[i].name,
                  selected: i == weekIndex,
                  onTap: () => onSelectWeek(i),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (var i = 0; i < days.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      _DayChip(
                        label: days[i].name,
                        selected: i == dayIndex,
                        onTap: () => onSelectDay(i),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (day != null)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.settings,
                  size: 20,
                  color: cs.onSurfaceVariant,
                ),
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'rename') {
                    _showRenameDayDialog(
                      context,
                      day.name,
                      (newName) => onRenameDay(weekIndex, dayIndex, newName),
                    );
                  }
                  if (value == 'delete') {
                    onDeleteDay(weekIndex, dayIndex);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18, color: cs.onSurface),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalizations.of(ctx).workoutBuilderRenameDayTitle,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: StitchM3Theme.danger,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalizations.of(ctx).workoutBuilderDeleteDayMenu,
                          style: TextStyle(color: StitchM3Theme.danger),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (day != null) ...[
          ...(() {
            final partition = partitionExercisesBySuperset(day.exercises);
            return partition.asMap().entries.map((entry) {
              final isLast = entry.key == partition.length - 1;
              final item = entry.value;
              if (item is Exercise) {
                final ex = item;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ExerciseCard(
                    theme: theme,
                    cs: cs,
                    exercise: ex,
                    compact: false,
                    showAddExercise: isLast,
                    onAddExercise: isLast
                        ? () => onAddExercise(weekIndex, dayIndex)
                        : null,
                    onRemove: () =>
                        onRemoveExercise(weekIndex, dayIndex, ex.id),
                    onMoveUp: () =>
                        onMoveExercise(weekIndex, dayIndex, ex.id, up: true),
                    onMoveDown: () =>
                        onMoveExercise(weekIndex, dayIndex, ex.id, up: false),
                    onEdit: (name, sets, reps, rpe, note, {setDetails}) =>
                        onUpdateExercise(
                          weekIndex,
                          dayIndex,
                          ex.id,
                          name: name,
                          sets: sets,
                          reps: reps,
                          rpe: rpe,
                          note: note,
                          setDetails: setDetails,
                        ),
                    onAddSet: () =>
                        onAddSetToExercise(weekIndex, dayIndex, ex.id),
                    onUpdateSet: (setIndex, sets, reps, load, note) =>
                        onUpdateExerciseSet(
                          weekIndex,
                          dayIndex,
                          ex.id,
                          setIndex,
                          sets: sets,
                          reps: reps,
                          rpe: load,
                          note: note,
                        ),
                    onRemoveSet: (setIndex) => onRemoveExerciseSet(
                      weekIndex,
                      dayIndex,
                      ex.id,
                      setIndex,
                    ),
                    supersetOptions: _getSupersetGroupOptions(
                      day,
                    ).where((o) => o.id != ex.supersetGroupId).toList(),
                    onAssignToSuperset: (groupId) =>
                        onAssignToSuperset(weekIndex, dayIndex, ex.id, groupId),
                    onRemoveFromSuperset: ex.supersetGroupId != null
                        ? () => onRemoveFromSuperset(weekIndex, dayIndex, ex.id)
                        : null,
                  ),
                );
              }
              final group = item as List<Exercise>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SuperSetBlock(
                      theme: theme,
                      cs: cs,
                      weekIndex: weekIndex,
                      dayIndex: dayIndex,
                      exercises: group,
                      supersetGroupId:
                          group.isNotEmpty &&
                              group.first.supersetGroupId != null
                          ? group.first.supersetGroupId!
                          : null,
                      onAddExercise: () => onAddExercise(weekIndex, dayIndex),
                      onAddExerciseToSuperset: onAddExerciseToSuperset,
                      onRemoveExercise: onRemoveExercise,
                      onMoveExercise: onMoveExercise,
                      onUpdateExercise: onUpdateExercise,
                      onAddSetToExercise: onAddSetToExercise,
                      onUpdateExerciseSet: onUpdateExerciseSet,
                      onRemoveExerciseSet: onRemoveExerciseSet,
                      onAssignToSuperset: onAssignToSuperset,
                      onRemoveFromSuperset: onRemoveFromSuperset,
                      supersetOptionsForDay: _getSupersetGroupOptions(day),
                    ),
                    if (isLast) ...[
                      const SizedBox(height: 12),
                      _DashedButton(
                        icon: Icons.add,
                        label: l10n.workoutBuilderAddExercise,
                        onPressed: () => onAddExercise(weekIndex, dayIndex),
                      ),
                    ],
                  ],
                ),
              );
            });
          })(),
          if (day.exercises.isEmpty)
            _DashedButton(
              icon: Icons.add,
              label: l10n.workoutBuilderAddExercise,
              onPressed: () => onAddExercise(weekIndex, dayIndex),
            ),
          const SizedBox(height: 16),
          _DashedButton(
            icon: Icons.calendar_today,
            label: l10n.workoutBuilderAddDayToWeek(weekIndex + 1),
            onPressed: () => onAddDay(weekIndex),
          ),
        ] else if (week != null && days.isEmpty)
          _DashedButton(
            icon: Icons.calendar_today,
            label: l10n.workoutBuilderAddDayToWeek(weekIndex + 1),
            onPressed: () => onAddDay(weekIndex),
          )
        else if (weeks.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.workoutBuilderNoWeeksYet,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: selected ? StitchM3Theme.accent : cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : cs.onSurfaceVariant,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                Icon(Icons.edit, size: 14, color: Colors.white70),
                Icon(Icons.delete_outline, size: 14, color: Colors.white70),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? StitchM3Theme.accent.withValues(alpha: 0.2)
              : cs.surfaceContainerHighest,
          border: Border.all(
            color: selected
                ? StitchM3Theme.accent.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? StitchM3Theme.accent : cs.onSurfaceVariant,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 4),
              Icon(Icons.edit, size: 12, color: StitchM3Theme.accent),
              Icon(Icons.delete_outline, size: 12, color: StitchM3Theme.accent),
            ],
          ],
        ),
      ),
    );
  }
}

class _SuperSetBlock extends StatelessWidget {
  const _SuperSetBlock({
    required this.theme,
    required this.cs,
    required this.weekIndex,
    required this.dayIndex,
    required this.exercises,
    this.supersetGroupId,
    required this.onAddExercise,
    this.onAddExerciseToSuperset,
    required this.onRemoveExercise,
    required this.onMoveExercise,
    required this.onUpdateExercise,
    required this.onAddSetToExercise,
    required this.onUpdateExerciseSet,
    required this.onRemoveExerciseSet,
    this.onAssignToSuperset,
    this.onRemoveFromSuperset,
    this.supersetOptionsForDay = const [],
  });

  final ThemeData theme;
  final ColorScheme cs;
  final int weekIndex;
  final int dayIndex;
  final List<Exercise> exercises;
  final String? supersetGroupId;
  final VoidCallback onAddExercise;
  final void Function(int, int, String)? onAddExerciseToSuperset;
  final void Function(int, int, String) onRemoveExercise;
  final void Function(int, int, String, {required bool up}) onMoveExercise;
  final void Function(
    int,
    int,
    String, {
    String? name,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
    List<ExerciseSet>? setDetails,
  })
  onUpdateExercise;
  final void Function(int, int, String) onAddSetToExercise;
  final void Function(
    int,
    int,
    String,
    int, {
    String? line,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
  })
  onUpdateExerciseSet;
  final void Function(int, int, String, int) onRemoveExerciseSet;
  final void Function(int, int, String, String)? onAssignToSuperset;
  final void Function(int, int, String)? onRemoveFromSuperset;
  final List<({String id, String label})> supersetOptionsForDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        border: Border(left: BorderSide(color: StitchM3Theme.accent, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, size: 18, color: StitchM3Theme.accent),
              const SizedBox(width: 8),
              Text(
                l10n.workoutBuilderSuperSetHeading,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: StitchM3Theme.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...exercises.map(
            (ex) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ExerciseCard(
                theme: theme,
                cs: cs,
                exercise: ex,
                compact: false,
                linked: true,
                onRemove: () => onRemoveExercise(weekIndex, dayIndex, ex.id),
                onMoveUp: () =>
                    onMoveExercise(weekIndex, dayIndex, ex.id, up: true),
                onMoveDown: () =>
                    onMoveExercise(weekIndex, dayIndex, ex.id, up: false),
                onEdit: (name, sets, reps, rpe, note, {setDetails}) =>
                    onUpdateExercise(
                      weekIndex,
                      dayIndex,
                      ex.id,
                      name: name,
                      sets: sets,
                      reps: reps,
                      rpe: rpe,
                      note: note,
                      setDetails: setDetails,
                    ),
                onAddSet: () => onAddSetToExercise(weekIndex, dayIndex, ex.id),
                onUpdateSet: (setIndex, sets, reps, load, note) =>
                    onUpdateExerciseSet(
                      weekIndex,
                      dayIndex,
                      ex.id,
                      setIndex,
                      sets: sets,
                      reps: reps,
                      rpe: load,
                      note: note,
                    ),
                onRemoveSet: (setIndex) =>
                    onRemoveExerciseSet(weekIndex, dayIndex, ex.id, setIndex),
                supersetOptions: supersetOptionsForDay
                    .where((o) => o.id != ex.supersetGroupId)
                    .toList(),
                onAssignToSuperset: onAssignToSuperset != null
                    ? (groupId) => onAssignToSuperset!(
                        weekIndex,
                        dayIndex,
                        ex.id,
                        groupId,
                      )
                    : null,
                onRemoveFromSuperset: onRemoveFromSuperset != null
                    ? () => onRemoveFromSuperset!(weekIndex, dayIndex, ex.id)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _DashedButton(
            icon: Icons.add,
            label: l10n.workoutBuilderAddExercise,
            onPressed:
                supersetGroupId != null && onAddExerciseToSuperset != null
                ? () => onAddExerciseToSuperset!(
                    weekIndex,
                    dayIndex,
                    supersetGroupId!,
                  )
                : onAddExercise,
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.theme,
    required this.cs,
    required this.exercise,
    required this.compact,
    this.showAddExercise = false,
    this.linked = false,
    this.onAddExercise,
    this.onRemove,
    this.onMoveUp,
    this.onMoveDown,
    this.onEdit,
    this.onAddSet,
    this.onUpdateSet,
    this.onRemoveSet,
    this.supersetOptions = const [],
    this.onAssignToSuperset,
    this.onRemoveFromSuperset,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final Exercise exercise;
  final bool compact;
  final bool showAddExercise;
  final bool linked;
  final VoidCallback? onAddExercise;
  final VoidCallback? onRemove;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final void Function(
    String name,
    String sets,
    String reps,
    String rpe,
    String note, {
    List<ExerciseSet>? setDetails,
  })?
  onEdit;
  final VoidCallback? onAddSet;
  final void Function(
    int setIndex,
    String sets,
    String reps,
    String load,
    String note,
  )?
  onUpdateSet;
  final void Function(int setIndex)? onRemoveSet;
  final List<({String id, String label})> supersetOptions;
  final void Function(String groupId)? onAssignToSuperset;
  final VoidCallback? onRemoveFromSuperset;

  @override
  Widget build(BuildContext context) {
    final details = exercise.effectiveSetDetails;
    final hasMultipleSets = details.length > 1;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
              if (linked)
                Icon(Icons.link_off, size: 20, color: StitchM3Theme.accent),
              if (linked) const SizedBox(width: 8),
              if (onAssignToSuperset != null || onRemoveFromSuperset != null)
                PopupMenuButton<String>(
                  icon: Icon(Icons.link, size: 20, color: cs.onSurfaceVariant),
                  padding: EdgeInsets.zero,
                  onSelected: (value) {
                    if (value == 'new') {
                      onAssignToSuperset!(
                        'ss_${DateTime.now().millisecondsSinceEpoch}',
                      );
                    } else if (value.startsWith('group:')) {
                      onAssignToSuperset!(value.substring(6));
                    } else if (value == 'remove') {
                      onRemoveFromSuperset?.call();
                    }
                  },
                  itemBuilder: (ctx) => [
                    if (onAssignToSuperset != null) ...[
                      PopupMenuItem(
                        value: 'new',
                        child: Row(
                          children: [
                            const Icon(Icons.add, size: 18),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(
                                ctx,
                              ).workoutBuilderNewSuperset,
                            ),
                          ],
                        ),
                      ),
                      ...supersetOptions.map(
                        (o) => PopupMenuItem(
                          value: 'group:${o.id}',
                          child: Row(
                            children: [
                              Icon(Icons.link, size: 18),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  o.label,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (onRemoveFromSuperset != null)
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(
                              Icons.link_off,
                              size: 18,
                              color: StitchM3Theme.danger,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Remove from superset',
                              style: TextStyle(color: StitchM3Theme.danger),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              if (onEdit != null)
                InkWell(
                  onTap: () => _showEditExerciseDialog(
                    context,
                    theme,
                    cs,
                    exercise.name,
                    exercise.sets,
                    exercise.reps,
                    exercise.rpe,
                    exercise.note,
                    (name, sets, reps, rpe, note) =>
                        onEdit!(name, sets, reps, rpe, note),
                    initialSetDetails: exercise.effectiveSetDetails,
                    onSaveWithSets: (name, note, setDetails) => onEdit!(
                      name,
                      exercise.sets,
                      exercise.reps,
                      exercise.rpe,
                      note,
                      setDetails: setDetails,
                    ),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              if (onEdit != null) const SizedBox(width: 8),
              if (onRemove != null)
                InkWell(
                  onTap: onRemove,
                  child: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: StitchM3Theme.danger,
                  ),
                ),
              if (onRemove != null) const SizedBox(width: 8),
              if (onMoveUp != null)
                InkWell(
                  onTap: onMoveUp,
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    size: 20,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              if (onMoveUp != null) const SizedBox(width: 4),
              if (onMoveDown != null)
                InkWell(
                  onTap: onMoveDown,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              if (onMoveDown != null) const SizedBox(width: 4),
              Icon(Icons.drag_indicator, size: 20, color: cs.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 12),
          if (hasMultipleSets)
            ...details.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: i < details.length - 1 ? 8 : 0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SetRepCell(
                        theme: theme,
                        cs: cs,
                        label: 'Serie',
                        value: s.displayText,
                        compact: compact,
                      ),
                    ),
                    if (onUpdateSet != null)
                      InkWell(
                        onTap: () => _showEditSetDialog(
                          context,
                          theme,
                          cs,
                          s.sets,
                          s.reps,
                          s.rpe,
                          s.note,
                          (sets, reps, load, note) =>
                              onUpdateSet!(i, sets, reps, load, note),
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    if (onRemoveSet != null && details.length > 1)
                      InkWell(
                        onTap: () => onRemoveSet!(i),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: StitchM3Theme.danger,
                        ),
                      ),
                  ],
                ),
              );
            })
          else
            Row(
              children: [
                Expanded(
                  child: _SetRepCell(
                    theme: theme,
                    cs: cs,
                    label: l10n.workoutBuilderSetsLabel,
                    value: details.first.displayText,
                    compact: compact,
                  ),
                ),
                if (onUpdateSet != null)
                  InkWell(
                    onTap: () {
                      final s = details.first;
                      _showEditSetDialog(
                        context,
                        theme,
                        cs,
                        s.sets,
                        s.reps,
                        s.rpe,
                        s.note,
                        (sets, reps, load, note) =>
                            onUpdateSet!(0, sets, reps, load, note),
                      );
                    },
                    child: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          if (!compact && onAddSet != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onAddSet,
              icon: Icon(Icons.add, size: 16, color: StitchM3Theme.accent),
              label: Text(
                l10n.workoutBuilderAddSet,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: StitchM3Theme.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            exercise.note.isNotEmpty ? exercise.note : 'Add note...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: exercise.note.isNotEmpty
                  ? cs.onSurface
                  : cs.onSurfaceVariant,
              fontStyle: exercise.note.isEmpty ? FontStyle.italic : null,
            ),
          ),
          if (showAddExercise) ...[
            const SizedBox(height: 12),
            _DashedButton(
              icon: Icons.add,
              label: l10n.workoutBuilderAddExercise,
              onPressed: onAddExercise,
            ),
          ],
        ],
      ),
    );
  }
}

void _showEditSetDialog(
  BuildContext context,
  ThemeData theme,
  ColorScheme cs,
  String initialSets,
  String initialReps,
  String initialLoad,
  String initialNote,
  void Function(String sets, String reps, String load, String note) onSave,
) {
  final setsController = TextEditingController(text: initialSets);
  final repsController = TextEditingController(text: initialReps);
  final loadController = TextEditingController(text: initialLoad);
  final noteController = TextEditingController(text: initialNote);
  final l10n = AppLocalizations.of(context);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderEditSetTitle,
    bodyBuilder: (sheetContext) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: setsController,
                decoration: InputDecoration(
                  labelText: l10n.workoutBuilderSetLabel,
                  hintText: '1',
                ),
                keyboardType: TextInputType.number,
                autofocus: false,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: repsController,
                decoration: InputDecoration(
                  labelText: l10n.workoutBuilderRepsLabel,
                  hintText: '3',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: loadController,
                decoration: InputDecoration(
                  labelText: l10n.workoutBuilderLoadLabel,
                  hintText: '75kg',
                ),
                keyboardType: TextInputType.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: noteController,
          decoration: InputDecoration(labelText: l10n.workoutBuilderNoteLabel),
          maxLines: 2,
        ),
      ],
    ),
    primaryActionLabel: l10n.customerSave,
    onPrimaryAction: () {
      onSave(
        setsController.text.trim(),
        repsController.text.trim(),
        loadController.text.trim(),
        noteController.text.trim(),
      );
      Navigator.of(context).pop();
    },
  );
}

class _SetRepCell extends StatelessWidget {
  const _SetRepCell({
    required this.theme,
    required this.cs,
    required this.label,
    required this.value,
    required this.compact,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: EdgeInsets.all(compact ? 8 : 12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
            border: Border.all(color: cs.outline),
          ),
          child: Center(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkoutBuilderBottomNav extends StatelessWidget {
  const _WorkoutBuilderBottomNav({
    required this.navContext,
    required this.selectedIndex,
  });

  final BuildContext navContext;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const items = [
      (Icons.library_books, 'Library', '/workouts/library'),
      (Icons.add_circle, 'Builder', '/workouts/builder'),
      (Icons.calendar_month, 'Diary', '/workouts/diary'),
      (Icons.bar_chart, 'Stats', '/workouts/stats'),
      (Icons.person, 'Profile', '/profile'),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.9),
        border: Border(top: BorderSide(color: cs.outline)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final (icon, label, route) = items[i];
          final selected = i == selectedIndex;
          return InkWell(
            onTap: () {
              if (route != '/workouts/builder' || !selected) {
                GoRouter.of(navContext).go(route);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: selected
                        ? StitchM3Theme.accent
                        : cs.onSurfaceVariant,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: selected
                          ? StitchM3Theme.accent
                          : cs.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
