import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/network/gymblog_api_client.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../data/workout_routine_model.dart';
import '../../data/workout_routine_storage.dart';
import '../../data/workout_plan_repository.dart';
import '../../domain/export_excel_usecase.dart';
import '../../domain/export_pdf_usecase.dart';
import '../../../customers/data/models/customer.dart' show Customer;

/// Returns list of superset group options for the day (id + label) for "Add to superset" menu.
List<({String id, String label})> _getSupersetGroupOptions(Day day) {
  final byId = <String, List<Exercise>>{};
  for (final e in day.exercises) {
    final id = e.supersetGroupId;
    if (id != null && id.isNotEmpty) {
      byId.putIfAbsent(id, () => []).add(e);
    }
  }
  return byId.entries.map((e) => (id: e.key, label: e.value.map((x) => x.name).join(' + '))).toList();
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
  State<WorkoutBuilderMobilityScreen> createState() => _WorkoutBuilderMobilityScreenState();
}

class _WorkoutBuilderMobilityScreenState extends State<WorkoutBuilderMobilityScreen> {
  final _routineNameController = TextEditingController();
  final _api = GymBlogApiClient();
  final _planRepo = WorkoutPlanRepository();
  String? _loadedPlanId;
  Customer? _editorCustomer;
  WorkoutRoutine _routine = WorkoutRoutine.empty();
  bool _loading = true;
  bool _saving = false;
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
    if (!GymBlogApiClient.isConfigured) {
      if (!mounted) return;
      setState(() {
        _routineNameController.text = _routine.name;
        _loading = false;
      });
      return;
    }
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
            _expandedWeekIds.clear();
            if (routine.weeks.isNotEmpty) _expandedWeekIds.add(routine.weeks.first.id);
          });
        }
      } else {
        setState(() {
          _expandedWeekIds.clear();
          if (_routine.weeks.isNotEmpty) _expandedWeekIds.add(_routine.weeks.first.id);
        });
      }
      try {
        final data = await _api.get('/api/customers/$customerId');
        customer = Customer.fromJson(data);
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
        if (_routine.weeks.isNotEmpty) _expandedWeekIds.add(_routine.weeks.first.id);
        _loading = false;
      });
    }
  }

  Future<void> _saveRoutine() async {
    if (_saving) return;
    setState(() => _saving = true);
    final name = _routineNameController.text.trim();
    final toSave = _routine.copyWith(name: name.isEmpty ? _routine.name : name);

    try {
      if (widget.editorMode && widget.customerId != null && GymBlogApiClient.isConfigured) {
        try {
          if (_loadedPlanId != null) {
            await _planRepo.update(
              planId: _loadedPlanId!,
              name: toSave.name,
              planDataJson: _encodeRoutine(toSave),
            );
          } else {
            final created = await _planRepo.create(
              customerId: widget.customerId!,
              name: toSave.name,
              planDataJson: _encodeRoutine(toSave),
              pdfHeader: _editorCustomer?.pdfHeader,
              useCustomPdfHeader: _editorCustomer?.useCustomPdfHeader ?? false,
            );
            if (mounted) setState(() => _loadedPlanId = created.id);
          }
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Plan saved'),
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
            content: const Text('Routine saved'),
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
    final customerId = widget.customerId ?? GoRouterState.of(context).uri.queryParameters['customerId'];
    if (customerId == null || customerId.isEmpty) return null;
    if (!GymBlogApiClient.isConfigured) return null;
    try {
      final data = await _api.get('/api/customers/$customerId');
      return Customer.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> _exportPdfAndShare() async {
    final l10n = AppLocalizations.of(context);
    final name = _routineNameController.text.trim();
    final routine = _routine.copyWith(name: name.isEmpty ? _routine.name : name);
    try {
      final customer = await _loadCustomerIfNeeded();
      final path = await exportWorkoutRoutineToPdf(routine, customer: customer);
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
    final routine = _routine.copyWith(name: name.isEmpty ? _routine.name : name);
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
    _showEditMobilityDialog(
      context,
      theme,
      cs,
      '',
      '',
      (title, subtitle) {
        final t = title.trim();
        final s = subtitle.trim();
        if (t.isEmpty && s.isEmpty) return;
        setState(() {
          final id = 'm_${DateTime.now().millisecondsSinceEpoch}';
          _routine = _routine.copyWith(
            mobilityItems: [
              ..._routine.mobilityItems,
              MobilityItem(id: id, title: t.isEmpty ? 'New exercise' : t, subtitle: s, sectionId: sectionId),
            ],
          );
        });
      },
    );
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
    if (oldIndex < 0 || oldIndex >= sectionItems.length || newIndex < 0 || newIndex >= sectionItems.length) return;
    setState(() {
      final reordered = List<MobilityItem>.from(sectionItems);
      if (newIndex > oldIndex) newIndex--;
      final item = reordered.removeAt(oldIndex);
      reordered.insert(newIndex, item);
      final others = _routine.mobilityItems.where((e) => e.sectionId != sectionId).toList();
      _routine = _routine.copyWith(mobilityItems: [...others, ...reordered]);
    });
  }

  void _addMobilitySection() {
    setState(() {
      final id = 'sec_${DateTime.now().millisecondsSinceEpoch}';
      final name = 'Section ${_routine.mobilitySections.length + 1}';
      _routine = _routine.copyWith(
        mobilitySections: [..._routine.mobilitySections, MobilitySection(id: id, name: name)],
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
        final updated = _routine.mobilitySections.map((s) => s.id == section.id ? s.copyWith(name: newName.trim()) : s).toList();
        _routine = _routine.copyWith(mobilitySections: updated);
      });
    });
  }

  void _deleteMobilitySection(int index) {
    if (index < 0 || index >= _routine.mobilitySections.length) return;
    if (_routine.mobilitySections.length <= 1) return; // keep at least one section
    final section = _routine.mobilitySections[index];
    final firstOtherId = _routine.mobilitySections.firstWhere((s) => s.id != section.id).id;
    setState(() {
      _routine = _routine.copyWith(
        mobilitySections: _routine.mobilitySections.where((s) => s.id != section.id).toList(),
        mobilityItems: _routine.mobilityItems
            .map((m) => m.sectionId == section.id ? m.copyWith(sectionId: firstOtherId) : m)
            .toList(),
      );
      _selectedMobilitySectionIndex = (_selectedMobilitySectionIndex.clamp(0, _routine.mobilitySections.length - 1));
    });
  }

  void _showEditSectionDialog(String initialName, void Function(String) onSave) {
    final controller = TextEditingController(text: initialName);
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final cs = theme.colorScheme;
        return AlertDialog(
          title: Text('Edit section', style: theme.textTheme.titleMedium),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Section name'),
            autofocus: true,
            onSubmitted: (_) {
              onSave(controller.text.trim());
              Navigator.of(ctx).pop();
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant))),
            FilledButton(
              onPressed: () {
                onSave(controller.text.trim());
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _addWeek() {
    setState(() {
      final id = 'w_${DateTime.now().millisecondsSinceEpoch}';
      _routine = _routine.copyWith(
        weeks: [..._routine.weeks, Week(id: id, name: 'WEEK ${_routine.weeks.length + 1}', days: [Day(id: '${id}_d1', name: 'DAY 1', exercises: [])])],
      );
      _expandedWeekIds.add(id);
    });
  }

  void _cloneWeek(int weekIndex) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    setState(() {
      final source = _routine.weeks[weekIndex];
      final newId = 'w_${DateTime.now().millisecondsSinceEpoch}';
      final newDays = source.days
          .map((d) => Day(
                id: '${newId}_d_${d.id}',
                name: d.name,
                exercises: d.exercises.map((e) => Exercise(
                  id: '${e.id}_$newId',
                  name: e.name,
                  sets: e.sets,
                  reps: e.reps,
                  rpe: e.rpe,
                  note: e.note,
                  setDetails: e.setDetails?.map((s) => ExerciseSet(line: s.line, sets: s.sets, reps: s.reps, rpe: s.rpe, note: s.note)).toList(),
                  supersetGroupId: null,
                )).toList(),
              ))
          .toList();
      final newWeek = Week(id: newId, name: '${source.name} (copy)', days: newDays);
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
      _selectedWeekIndex = _selectedWeekIndex.clamp(0, _routine.weeks.isNotEmpty ? _routine.weeks.length - 1 : 0);
    });
  }

  Future<void> _confirmDeleteWeek(BuildContext context, int weekIndex) async {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete week'),
        content: const Text('Remove this week and all its days and exercises? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: StitchM3Theme.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) _deleteWeek(weekIndex);
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

  void _deleteDay(int weekIndex, int dayIndex) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    if (week.days.length <= 1) return; // keep at least one day
    setState(() {
      final newDays = week.days.where((d) => d.id != week.days[dayIndex].id).toList();
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
      _selectedDayIndex = _selectedDayIndex.clamp(0, newDays.isNotEmpty ? newDays.length - 1 : 0);
    });
  }

  void _addDayToWeek(int weekIndex) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    setState(() {
      final week = _routine.weeks[weekIndex];
      final dayId = '${week.id}_d_${DateTime.now().millisecondsSinceEpoch}';
      final newDays = [...week.days, Day(id: dayId, name: 'DAY ${week.days.length + 1}', exercises: [])];
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  void _addExerciseToDay(int weekIndex, int dayIndex) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    if (dayIndex < 0 || dayIndex >= _routine.weeks[weekIndex].days.length) return;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final exId = 'e_${DateTime.now().millisecondsSinceEpoch}';
    // Apri sempre con UI multi-serie (top set / backoff): una riga vuota + "Add set"
    _showEditExerciseDialog(
      context,
      theme,
      cs,
      '',
      '',
      '',
      '',
      '',
      (_, __, ___, ____, _____) {},
      initialSetDetails: [const ExerciseSet()],
      onSaveWithSets: (name, note, details) {
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
            reps: list.map((s) => s.displayText).where((r) => r.isNotEmpty).join(' | '),
            rpe: '',
            note: note,
            setDetails: list,
          );
          final newEx = [...day.exercises, newExercise];
          final newDays = List<Day>.from(week.days);
          newDays[dayIndex] = day.copyWith(exercises: newEx);
          final newWeeks = List<Week>.from(_routine.weeks);
          newWeeks[weekIndex] = week.copyWith(days: newDays);
          _routine = _routine.copyWith(weeks: newWeeks);
        });
      },
    );
  }

  /// Adds a new exercise to the day and assigns it to the given superset group.
  /// The new exercise is inserted immediately after the last exercise of that group.
  /// Stesso dialog multi-serie della creazione normale.
  void _addExerciseToSuperset(int weekIndex, int dayIndex, String supersetGroupId) {
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
    _showEditExerciseDialog(
      context,
      theme,
      cs,
      '',
      '',
      '',
      '',
      '',
      (_, __, ___, ____, _____) {},
      initialSetDetails: [const ExerciseSet()],
      onSaveWithSets: (name, note, details) {
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
            reps: list.map((s) => s.displayText).where((r) => r.isNotEmpty).join(' | '),
            rpe: '',
            note: note,
            setDetails: list,
            supersetGroupId: supersetGroupId,
          );
          final newEx = List<Exercise>.from(d.exercises)..insert(insertIndex, newExercise);
          final newDays = List<Day>.from(w.days);
          newDays[dayIndex] = d.copyWith(exercises: newEx);
          final newWeeks = List<Week>.from(_routine.weeks);
          newWeeks[weekIndex] = w.copyWith(days: newDays);
          _routine = _routine.copyWith(weeks: newWeeks);
        });
      },
    );
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

  void _updateMobilityItem(String id, String title, String subtitle) {
    setState(() {
      _routine = _routine.copyWith(
        mobilityItems: _routine.mobilityItems.map((e) => e.id == id ? e.copyWith(title: title, subtitle: subtitle) : e).toList(),
      );
    });
  }

  void _updateExercise(int weekIndex, int dayIndex, String exerciseId, {String? name, String? sets, String? reps, String? rpe, String? note, List<ExerciseSet>? setDetails}) {
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

  void _updateExerciseSet(int weekIndex, int dayIndex, String exerciseId, int setIndex, {String? line, String? sets, String? reps, String? rpe, String? note}) {
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
            newDetails[setIndex] = ExerciseSet(line: trimmed, sets: '1', reps: '', rpe: '', note: note ?? cur.note);
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

  void _removeExerciseSet(int weekIndex, int dayIndex, String exerciseId, int setIndex) {
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

  void _assignToSuperset(int weekIndex, int dayIndex, String exerciseId, String supersetGroupId) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    setState(() {
      final day = week.days[dayIndex];
      final newEx = day.exercises.map((e) => e.id == exerciseId ? e.copyWith(supersetGroupId: supersetGroupId) : e).toList();
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
      final newEx = day.exercises.map((e) => e.id == exerciseId ? e.copyWith(clearSupersetGroupId: true) : e).toList();
      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(exercises: newEx);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
  }

  bool get _showMobilityContent => widget.variant == WorkoutBuilderVariant.mobility && _mobilityExpanded;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
          'Workout Builder',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        actions: [
          if (!_loading)
            PopupMenuButton<String>(
              icon: const Icon(Icons.ios_share),
              tooltip: AppLocalizations.of(context).workoutExport,
              onSelected: (value) {
                if (value == 'pdf') _exportPdfAndShare();
                if (value == 'excel') _exportExcelAndShare();
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'pdf', child: Text(AppLocalizations.of(context).workoutExportPdf)),
                PopupMenuItem(value: 'excel', child: Text(AppLocalizations.of(context).workoutExportExcel)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: _saving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Save'),
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
                          'ROUTINE NAME',
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
                            contentPadding: const EdgeInsets.symmetric(vertical: 6),
                            hintText: 'Add routine title',
                            hintStyle: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
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
                          onTap: () => setState(() => _mobilityExpanded = !_mobilityExpanded),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _mobilityExpanded ? Icons.expand_more : Icons.chevron_right,
                                    color: cs.onSurfaceVariant,
                                    size: 24,
                                  ),
                                  Icon(Icons.accessibility_new, color: StitchM3Theme.accent, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Mobility Routine',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton.icon(
                                onPressed: _addMobilityItem,
                                icon: Icon(Icons.add, size: 18, color: StitchM3Theme.accent),
                                label: Text('Add', style: TextStyle(color: StitchM3Theme.accent, fontWeight: FontWeight.w600)),
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
                                      for (var i = 0; i < _routine.mobilitySections.length; i++) ...[
                                        if (i > 0) const SizedBox(width: 8),
                                        _MobilitySectionChip(
                                          label: _routine.mobilitySections[i].name,
                                          selected: _selectedMobilitySectionIndex.clamp(0, _routine.mobilitySections.length - 1) == i,
                                          onTap: () => setState(() => _selectedMobilitySectionIndex = i),
                                          onEdit: () => _editMobilitySection(i),
                                          onDelete: _routine.mobilitySections.length > 1 ? () => _deleteMobilitySection(i) : null,
                                        ),
                                      ],
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: _addMobilitySection,
                                        borderRadius: BorderRadius.circular(999),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.add, size: 18, color: StitchM3Theme.accent),
                                              const SizedBox(width: 4),
                                              Text('Section', style: theme.textTheme.labelSmall?.copyWith(color: StitchM3Theme.accent, fontWeight: FontWeight.w700)),
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
                            itemCount: _mobilityItemsForSelectedSection.length,
                            itemBuilder: (context, index) {
                              final item = _mobilityItemsForSelectedSection[index];
                              return Padding(
                                key: ValueKey(item.id),
                                padding: EdgeInsets.only(bottom: index < _mobilityItemsForSelectedSection.length - 1 ? 12 : 0),
                                child: _MobilityItem(
                                  index: index,
                                  title: item.title,
                                  subtitle: item.subtitle,
                                  onEdit: (t, s) => _updateMobilityItem(item.id, t, s),
                                  onDelete: () => _removeMobilityItem(item.id),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _DashedButton(icon: Icons.add, label: 'Add Exercise', onPressed: _selectedSectionId != null ? _addMobilityItem : null),
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
                    onTrainingToggle: () => setState(() => _trainingExpanded = !_trainingExpanded),
                    onToggleWeek: (id) => setState(() {
                      if (_expandedWeekIds.contains(id)) {
                        _expandedWeekIds.remove(id);
                      } else {
                        _expandedWeekIds.add(id);
                      }
                    }),
                    onNewWeek: _addWeek,
                    onCloneWeek: _cloneWeek,
                    onDeleteWeek: (weekIndex) => _confirmDeleteWeek(context, weekIndex),
                    onAddDay: _addDayToWeek,
                    onRenameDay: _renameDay,
                    onDeleteDay: _deleteDay,
                    onAddExercise: _addExerciseToDay,
                    onRemoveExercise: _removeExercise,
                    onUpdateExercise: _updateExercise,
                    onAddSetToExercise: _addSetToExercise,
                    onUpdateExerciseSet: _updateExerciseSet,
                    onRemoveExerciseSet: _removeExerciseSet,
                    onAssignToSuperset: _assignToSuperset,
                    onRemoveFromSuperset: _removeFromSuperset,
                    onAddExerciseToSuperset: _addExerciseToSuperset,
                    onSelectWeek: (i) => setState(() => _selectedWeekIndex = i),
                    onSelectDay: (i) => setState(() => _selectedDayIndex = i),
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
                    child: Icon(Icons.edit, size: 18, color: cs.onSurfaceVariant),
                  ),
                ),
                if (onDelete != null) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.delete_outline, size: 18, color: StitchM3Theme.danger),
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
            child: Icon(Icons.drag_indicator, size: 20, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface)),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          if (onEdit != null)
            InkWell(
              onTap: () => _showEditMobilityDialog(context, theme, cs, title, subtitle, onEdit!),
              child: Icon(Icons.edit_outlined, size: 20, color: cs.onSurfaceVariant),
            ),
          if (onEdit != null) const SizedBox(width: 8),
          InkWell(
            onTap: onDelete,
            child: Icon(Icons.delete_outline, size: 20, color: StitchM3Theme.danger),
          ),
        ],
      ),
    );
  }
}

void _showRenameDayDialog(BuildContext context, String initialName, void Function(String) onSave) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  final controller = TextEditingController(text: initialName);
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Rename day', style: theme.textTheme.titleMedium),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(labelText: 'Day name'),
        autofocus: true,
        onSubmitted: (_) {
          final name = controller.text.trim();
          if (name.isNotEmpty) {
            onSave(name);
            Navigator.of(ctx).pop();
          }
        },
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant))),
        FilledButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              onSave(name);
              Navigator.of(ctx).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
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
  final titleController = TextEditingController(text: initialTitle);
  final subtitleController = TextEditingController(text: initialSubtitle);
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Edit mobility exercise', style: theme.textTheme.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: subtitleController,
            decoration: const InputDecoration(labelText: 'Subtitle'),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant))),
        FilledButton(
          onPressed: () {
            onSave(titleController.text.trim(), subtitleController.text.trim());
            Navigator.of(ctx).pop();
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
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
  void Function(String name, String sets, String reps, String rpe, String note) onSave, {
  List<ExerciseSet>? initialSetDetails,
  void Function(String name, String note, List<ExerciseSet> setDetails)? onSaveWithSets,
}) {
  final nameController = TextEditingController(text: initialName);
  final noteController = TextEditingController(text: initialNote);
  final setsController = TextEditingController(text: initialSets);
  final repsController = TextEditingController(text: initialReps);
  final rpeController = TextEditingController(text: initialRpe);
  final useMultiSet = onSaveWithSets != null && initialSetDetails != null && initialSetDetails.isNotEmpty;
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
  showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) {
        void addSetRow() {
          setState(() {
            setControllers.add(_SetEditControllers(TextEditingController(), TextEditingController(), TextEditingController(), TextEditingController()));
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        );
        return AlertDialog(
          title: Text(initialName.trim().isEmpty ? 'Add exercise' : 'Edit exercise', style: theme.textTheme.titleMedium),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name', isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    autofocus: true,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(labelText: 'Note (optional)', isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    maxLines: 1,
                  ),
                  if (useMultiSet) ...[
                    const SizedBox(height: 12),
                    Text('Serie (Set × Reps + Carico)', style: theme.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
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
                                decoration: denseDecoration.copyWith(labelText: 'Set', hintText: '1'),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: c.reps,
                                decoration: denseDecoration.copyWith(labelText: 'Reps', hintText: '3'),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: c.load,
                                decoration: denseDecoration.copyWith(labelText: 'Carico', hintText: '75kg'),
                                keyboardType: TextInputType.text,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 22, color: setControllers.length > 1 ? StitchM3Theme.danger : cs.onSurfaceVariant),
                              onPressed: setControllers.length > 1 ? () => removeSetRow(i) : null,
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
                        onPressed: addSetRow,
                        icon: Icon(Icons.add, size: 18, color: StitchM3Theme.accent),
                        label: Text('Add set', style: theme.textTheme.labelMedium?.copyWith(color: StitchM3Theme.accent)),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 10),
                    TextField(controller: setsController, decoration: denseDecoration.copyWith(labelText: 'Sets'), keyboardType: TextInputType.number),
                    const SizedBox(height: 8),
                    TextField(controller: repsController, decoration: denseDecoration.copyWith(labelText: 'Reps')),
                    const SizedBox(height: 8),
                    TextField(controller: rpeController, decoration: denseDecoration.copyWith(labelText: 'RPE / Load')),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant)),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: modalSaving,
              builder: (_, saving, __) => SizedBox(
                height: 36,
                child: FilledButton(
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
                              if (sets.isNotEmpty || reps.isNotEmpty || load.isNotEmpty) {
                                return ExerciseSet(sets: sets.isEmpty ? '1' : sets, reps: reps, rpe: load, note: noteSet);
                              }
                              return ExerciseSet(note: noteSet);
                            }).toList();
                            onSaveWithSets(name, note, details);
                          } else {
                            onSave(name, setsController.text.trim(), repsController.text.trim(), rpeController.text.trim(), note);
                          }
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        },
                  child: saving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(cs.onPrimary),
                          ),
                        )
                      : const Text('Save'),
                ),
              ),
            ),
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
  const _DashedButton({required this.icon, required this.label, this.onPressed});

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg)),
        foregroundColor: cs.onSurfaceVariant,
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
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
    required this.onAddDay,
    required this.onRenameDay,
    required this.onDeleteDay,
    required this.onAddExercise,
    required this.onRemoveExercise,
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
  final void Function(int) onAddDay;
  final void Function(int, int, String) onRenameDay;
  final void Function(int, int) onDeleteDay;
  final void Function(int, int) onAddExercise;
  final void Function(int, int, String) onRemoveExercise;
  final void Function(int, int, String, {String? name, String? sets, String? reps, String? rpe, String? note, List<ExerciseSet>? setDetails}) onUpdateExercise;
  final void Function(int, int, String) onAddSetToExercise;
  final void Function(int, int, String, int, {String? line, String? sets, String? reps, String? rpe, String? note}) onUpdateExerciseSet;
  final void Function(int, int, String, int) onRemoveExerciseSet;
  final void Function(int, int, String, String) onAssignToSuperset;
  final void Function(int, int, String) onRemoveFromSuperset;
  final void Function(int, int, String) onAddExerciseToSuperset;
  final void Function(int) onSelectWeek;
  final void Function(int) onSelectDay;
  final _TrainingVariant variant;

  @override
  Widget build(BuildContext context) {
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
                    Icon(expanded ? Icons.expand_more : Icons.chevron_right, color: cs.onSurfaceVariant, size: 24),
                    Icon(Icons.fitness_center, color: StitchM3Theme.accent, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Training Program',
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: StitchM3Theme.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16, color: StitchM3Theme.accent),
                      const SizedBox(width: 4),
                      Text('New Week', style: theme.textTheme.labelSmall?.copyWith(color: StitchM3Theme.accent, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (expanded) ...[
            if (variant == _TrainingVariant.mobility)
              ...weeks.asMap().entries.map((e) => _WeekAccordion(
                    key: ValueKey(e.value.id),
                    weekIndex: e.key,
                    week: e.value,
                    expanded: expandedWeekIds.contains(e.value.id),
                    onToggle: () => onToggleWeek(e.value.id),
                    onClone: () => onCloneWeek(e.key),
                    onDelete: () => onDeleteWeek(e.key),
                    onAddDay: () => onAddDay(e.key),
                    onRenameDay: (dayIndex, newName) => onRenameDay(e.key, dayIndex, newName),
                    onDeleteDay: (dayIndex) => onDeleteDay(e.key, dayIndex),
                    onAddExercise: onAddExercise,
                    onRemoveExercise: onRemoveExercise,
                    onUpdateExercise: onUpdateExercise,
                    onAddSetToExercise: onAddSetToExercise,
                    onUpdateExerciseSet: onUpdateExerciseSet,
                    onRemoveExerciseSet: onRemoveExerciseSet,
                    onAssignToSuperset: onAssignToSuperset,
                    onRemoveFromSuperset: onRemoveFromSuperset,
                    onAddExerciseToSuperset: onAddExerciseToSuperset,
                    theme: theme,
                    cs: cs,
                  )),
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
    required this.onAddDay,
    required this.onRenameDay,
    required this.onDeleteDay,
    required this.onAddExercise,
    required this.onRemoveExercise,
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
  final VoidCallback onAddDay;
  final void Function(int dayIndex, String newName) onRenameDay;
  final void Function(int dayIndex) onDeleteDay;
  final void Function(int, int) onAddExercise;
  final void Function(int, int, String) onRemoveExercise;
  final void Function(int, int, String, {String? name, String? sets, String? reps, String? rpe, String? note, List<ExerciseSet>? setDetails}) onUpdateExercise;
  final void Function(int, int, String) onAddSetToExercise;
  final void Function(int, int, String, int, {String? line, String? sets, String? reps, String? rpe, String? note}) onUpdateExerciseSet;
  final void Function(int, int, String, int) onRemoveExerciseSet;
  final void Function(int, int, String, String) onAssignToSuperset;
  final void Function(int, int, String) onRemoveFromSuperset;
  final void Function(int, int, String) onAddExerciseToSuperset;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
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
                    Icon(expanded ? Icons.expand_more : Icons.chevron_right, color: cs.onSurfaceVariant, size: 24),
                    Text(
                      week.name,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: onClone,
                      icon: Icon(Icons.copy, size: 14, color: cs.onSurfaceVariant),
                      label: Text('Clone', style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700)),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant, size: 20),
                      padding: EdgeInsets.zero,
                      onSelected: (value) {
                        if (value == 'clone') onClone();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'clone', child: Row(children: [Icon(Icons.copy, size: 18, color: cs.onSurface), const SizedBox(width: 12), const Text('Duplicate week')])),
                        PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: StitchM3Theme.danger), const SizedBox(width: 12), Text('Delete week', style: TextStyle(color: StitchM3Theme.danger))])),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...week.days.asMap().entries.expand((dayEntry) {
                  final dayIndex = dayEntry.key;
                  final day = dayEntry.value;
                  return [
                    if (dayIndex > 0) const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          day.name,
                          style: theme.textTheme.titleSmall?.copyWith(color: StitchM3Theme.accent, fontWeight: FontWeight.w700),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.settings, size: 18, color: cs.onSurfaceVariant),
                          padding: EdgeInsets.zero,
                          onSelected: (value) {
                            if (value == 'rename') _showRenameDayDialog(context, day.name, (newName) => onRenameDay(dayIndex, newName));
                            if (value == 'delete') onDeleteDay(dayIndex);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'rename', child: Row(children: [Icon(Icons.edit, size: 18, color: cs.onSurface), const SizedBox(width: 12), const Text('Rename day')])),
                            PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: StitchM3Theme.danger), const SizedBox(width: 12), Text('Delete day', style: TextStyle(color: StitchM3Theme.danger))])),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...(() {
                      final partition = partitionExercisesBySuperset(day.exercises);
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
                            onAddExercise: isLast ? () => onAddExercise(weekIndex, dayIndex) : null,
                            onRemove: () => onRemoveExercise(weekIndex, dayIndex, ex.id),
                            onEdit: (name, sets, reps, rpe, note, {setDetails}) => onUpdateExercise(weekIndex, dayIndex, ex.id, name: name, sets: sets, reps: reps, rpe: rpe, note: note, setDetails: setDetails),
                            onAddSet: () => onAddSetToExercise(weekIndex, dayIndex, ex.id),
                            onUpdateSet: (setIndex, sets, reps, load, note) => onUpdateExerciseSet(weekIndex, dayIndex, ex.id, setIndex, sets: sets, reps: reps, rpe: load, note: note),
                            onRemoveSet: (setIndex) => onRemoveExerciseSet(weekIndex, dayIndex, ex.id, setIndex),
                            supersetOptions: _getSupersetGroupOptions(day).where((o) => o.id != ex.supersetGroupId).toList(),
                            onAssignToSuperset: (groupId) => onAssignToSuperset(weekIndex, dayIndex, ex.id, groupId),
                            onRemoveFromSuperset: ex.supersetGroupId != null ? () => onRemoveFromSuperset(weekIndex, dayIndex, ex.id) : null,
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
                              supersetGroupId: group.isNotEmpty && group.first.supersetGroupId != null ? group.first.supersetGroupId! : null,
                              onAddExercise: () => onAddExercise(weekIndex, dayIndex),
                              onAddExerciseToSuperset: onAddExerciseToSuperset,
                              onRemoveExercise: onRemoveExercise,
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
                              _DashedButton(icon: Icons.add, label: 'Add Exercise', onPressed: () => onAddExercise(weekIndex, dayIndex)),
                            ],
                          ],
                        ),
                      );
                    });
                    })(),
                    if (day.exercises.isEmpty)
                      _DashedButton(
                        icon: Icons.add,
                        label: 'Add Exercise',
                        onPressed: () => onAddExercise(weekIndex, dayIndex),
                      ),
                  ];
                }),
                const SizedBox(height: 16),
                _DashedButton(icon: Icons.calendar_today, label: 'Add Day to Week ${weekIndex + 1}', onPressed: onAddDay),
              ],
            ),
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
  final void Function(int, int, String, {String? name, String? sets, String? reps, String? rpe, String? note, List<ExerciseSet>? setDetails}) onUpdateExercise;
  final void Function(int, int, String) onAddSetToExercise;
  final void Function(int, int, String, int, {String? line, String? sets, String? reps, String? rpe, String? note}) onUpdateExerciseSet;
  final void Function(int, int, String, int) onRemoveExerciseSet;
  final void Function(int, int, String, String) onAssignToSuperset;
  final void Function(int, int, String) onRemoveFromSuperset;
  final void Function(int, int, String) onAddExerciseToSuperset;
  final void Function(int) onAddDay;
  final void Function(int, int, String) onRenameDay;
  final void Function(int, int) onDeleteDay;

  @override
  Widget build(BuildContext context) {
    final weekIndex = weeks.isEmpty ? 0 : selectedWeekIndex.clamp(0, weeks.length - 1);
    final week = weeks.isEmpty ? null : weeks[weekIndex];
    final days = week?.days ?? [];
    final dayIndex = selectedDayIndex.clamp(0, days.isNotEmpty ? days.length - 1 : 0);
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
                  label: 'Week ${i + 1}',
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
                        label: days[i].name.startsWith('DAY') ? days[i].name : 'Day ${i + 1}',
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
                icon: Icon(Icons.settings, size: 20, color: cs.onSurfaceVariant),
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'rename') _showRenameDayDialog(context, day.name, (newName) => onRenameDay(weekIndex, dayIndex, newName));
                  if (value == 'delete') onDeleteDay(weekIndex, dayIndex);
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(value: 'rename', child: Row(children: [Icon(Icons.edit, size: 18, color: cs.onSurface), const SizedBox(width: 12), const Text('Rename day')])),
                  PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: StitchM3Theme.danger), const SizedBox(width: 12), Text('Delete day', style: TextStyle(color: StitchM3Theme.danger))])),
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
                    onAddExercise: isLast ? () => onAddExercise(weekIndex, dayIndex) : null,
                    onRemove: () => onRemoveExercise(weekIndex, dayIndex, ex.id),
                    onEdit: (name, sets, reps, rpe, note, {setDetails}) => onUpdateExercise(weekIndex, dayIndex, ex.id, name: name, sets: sets, reps: reps, rpe: rpe, note: note, setDetails: setDetails),
                    onAddSet: () => onAddSetToExercise(weekIndex, dayIndex, ex.id),
                    onUpdateSet: (setIndex, sets, reps, load, note) => onUpdateExerciseSet(weekIndex, dayIndex, ex.id, setIndex, sets: sets, reps: reps, rpe: load, note: note),
                    onRemoveSet: (setIndex) => onRemoveExerciseSet(weekIndex, dayIndex, ex.id, setIndex),
                    supersetOptions: _getSupersetGroupOptions(day).where((o) => o.id != ex.supersetGroupId).toList(),
                    onAssignToSuperset: (groupId) => onAssignToSuperset(weekIndex, dayIndex, ex.id, groupId),
                    onRemoveFromSuperset: ex.supersetGroupId != null ? () => onRemoveFromSuperset(weekIndex, dayIndex, ex.id) : null,
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
                      supersetGroupId: group.isNotEmpty && group.first.supersetGroupId != null ? group.first.supersetGroupId! : null,
                      onAddExercise: () => onAddExercise(weekIndex, dayIndex),
                      onAddExerciseToSuperset: onAddExerciseToSuperset,
                      onRemoveExercise: onRemoveExercise,
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
                      _DashedButton(icon: Icons.add, label: 'Add Exercise', onPressed: () => onAddExercise(weekIndex, dayIndex)),
                    ],
                  ],
                ),
              );
            });
          })(),
          if (day.exercises.isEmpty)
            _DashedButton(
              icon: Icons.add,
              label: 'Add Exercise',
              onPressed: () => onAddExercise(weekIndex, dayIndex),
            ),
          const SizedBox(height: 16),
          _DashedButton(
            icon: Icons.calendar_today,
            label: 'Add Day to Week ${weekIndex + 1}',
            onPressed: () => onAddDay(weekIndex),
          ),
        ] else if (week != null && days.isEmpty)
          _DashedButton(
            icon: Icons.calendar_today,
            label: 'Add Day to Week ${weekIndex + 1}',
            onPressed: () => onAddDay(weekIndex),
          )
        else if (weeks.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No weeks yet. Add a week above.', style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
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
          color: selected ? StitchM3Theme.accent.withValues(alpha: 0.2) : cs.surfaceContainerHighest,
          border: Border.all(color: selected ? StitchM3Theme.accent.withValues(alpha: 0.4) : Colors.transparent),
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
  final void Function(int, int, String, {String? name, String? sets, String? reps, String? rpe, String? note, List<ExerciseSet>? setDetails}) onUpdateExercise;
  final void Function(int, int, String) onAddSetToExercise;
  final void Function(int, int, String, int, {String? line, String? sets, String? reps, String? rpe, String? note}) onUpdateExerciseSet;
  final void Function(int, int, String, int) onRemoveExerciseSet;
  final void Function(int, int, String, String)? onAssignToSuperset;
  final void Function(int, int, String)? onRemoveFromSuperset;
  final List<({String id, String label})> supersetOptionsForDay;

  @override
  Widget build(BuildContext context) {
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
                'SUPER SET',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: StitchM3Theme.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...exercises.map((ex) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ExerciseCard(
              theme: theme,
              cs: cs,
              exercise: ex,
              compact: false,
              linked: true,
              onRemove: () => onRemoveExercise(weekIndex, dayIndex, ex.id),
              onEdit: (name, sets, reps, rpe, note, {setDetails}) => onUpdateExercise(weekIndex, dayIndex, ex.id, name: name, sets: sets, reps: reps, rpe: rpe, note: note, setDetails: setDetails),
              onAddSet: () => onAddSetToExercise(weekIndex, dayIndex, ex.id),
              onUpdateSet: (setIndex, sets, reps, load, note) => onUpdateExerciseSet(weekIndex, dayIndex, ex.id, setIndex, sets: sets, reps: reps, rpe: load, note: note),
              onRemoveSet: (setIndex) => onRemoveExerciseSet(weekIndex, dayIndex, ex.id, setIndex),
              supersetOptions: supersetOptionsForDay.where((o) => o.id != ex.supersetGroupId).toList(),
              onAssignToSuperset: onAssignToSuperset != null ? (groupId) => onAssignToSuperset!(weekIndex, dayIndex, ex.id, groupId) : null,
              onRemoveFromSuperset: onRemoveFromSuperset != null ? () => onRemoveFromSuperset!(weekIndex, dayIndex, ex.id) : null,
            ),
          )),
          const SizedBox(height: 8),
          _DashedButton(
            icon: Icons.add,
            label: 'Add Exercise',
            onPressed: supersetGroupId != null && onAddExerciseToSuperset != null
                ? () => onAddExerciseToSuperset!(weekIndex, dayIndex, supersetGroupId!)
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
  final void Function(String name, String sets, String reps, String rpe, String note, {List<ExerciseSet>? setDetails})? onEdit;
  final VoidCallback? onAddSet;
  final void Function(int setIndex, String sets, String reps, String load, String note)? onUpdateSet;
  final void Function(int setIndex)? onRemoveSet;
  final List<({String id, String label})> supersetOptions;
  final void Function(String groupId)? onAssignToSuperset;
  final VoidCallback? onRemoveFromSuperset;

  @override
  Widget build(BuildContext context) {
    final details = exercise.effectiveSetDetails;
    final hasMultipleSets = details.length > 1;

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
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
              ),
              if (linked) Icon(Icons.link_off, size: 20, color: StitchM3Theme.accent),
              if (linked) const SizedBox(width: 8),
              if (onAssignToSuperset != null || onRemoveFromSuperset != null)
                PopupMenuButton<String>(
                  icon: Icon(Icons.link, size: 20, color: cs.onSurfaceVariant),
                  padding: EdgeInsets.zero,
                  onSelected: (value) {
                    if (value == 'new') {
                      onAssignToSuperset!('ss_${DateTime.now().millisecondsSinceEpoch}');
                    } else if (value.startsWith('group:')) {
                      onAssignToSuperset!(value.substring(6));
                    } else if (value == 'remove') {
                      onRemoveFromSuperset?.call();
                    }
                  },
                  itemBuilder: (ctx) => [
                    if (onAssignToSuperset != null) ...[
                      const PopupMenuItem(value: 'new', child: Row(children: [Icon(Icons.add, size: 18), SizedBox(width: 12), Text('New superset')])),
                      ...supersetOptions.map((o) => PopupMenuItem(value: 'group:${o.id}', child: Row(children: [Icon(Icons.link, size: 18), SizedBox(width: 12), Expanded(child: Text(o.label, overflow: TextOverflow.ellipsis))]))),
                    ],
                    if (onRemoveFromSuperset != null)
                      const PopupMenuItem(value: 'remove', child: Row(children: [Icon(Icons.link_off, size: 18, color: StitchM3Theme.danger), SizedBox(width: 12), Text('Remove from superset', style: TextStyle(color: StitchM3Theme.danger))])),
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
                    (name, sets, reps, rpe, note) => onEdit!(name, sets, reps, rpe, note),
                    initialSetDetails: exercise.effectiveSetDetails,
                    onSaveWithSets: (name, note, setDetails) => onEdit!(name, exercise.sets, exercise.reps, exercise.rpe, note, setDetails: setDetails),
                  ),
                  child: Icon(Icons.edit_outlined, size: 20, color: cs.onSurfaceVariant),
                ),
              if (onEdit != null) const SizedBox(width: 8),
              if (onRemove != null)
                InkWell(
                  onTap: onRemove,
                  child: Icon(Icons.delete_outline, size: 20, color: StitchM3Theme.danger),
                ),
              if (onRemove != null) const SizedBox(width: 8),
              Icon(Icons.drag_indicator, size: 20, color: cs.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 12),
          if (hasMultipleSets)
            ...details.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: i < details.length - 1 ? 8 : 0),
                child: Row(
                  children: [
                    Expanded(child: _SetRepCell(theme: theme, cs: cs, label: 'Serie', value: s.displayText, compact: compact)),
                    if (onUpdateSet != null)
                      InkWell(
                        onTap: () => _showEditSetDialog(context, theme, cs, s.sets, s.reps, s.rpe, s.note, (sets, reps, load, note) => onUpdateSet!(i, sets, reps, load, note)),
                        child: Icon(Icons.edit_outlined, size: 18, color: cs.onSurfaceVariant),
                      ),
                    if (onRemoveSet != null && details.length > 1)
                      InkWell(
                        onTap: () => onRemoveSet!(i),
                        child: Icon(Icons.delete_outline, size: 18, color: StitchM3Theme.danger),
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
                    label: 'Serie',
                    value: details.first.displayText,
                    compact: compact,
                  ),
                ),
                if (onUpdateSet != null)
                  InkWell(
                    onTap: () {
                      final s = details.first;
                      _showEditSetDialog(context, theme, cs, s.sets, s.reps, s.rpe, s.note, (sets, reps, load, note) => onUpdateSet!(0, sets, reps, load, note));
                    },
                    child: Icon(Icons.edit_outlined, size: 18, color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          if (!compact && onAddSet != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onAddSet,
              icon: Icon(Icons.add, size: 16, color: StitchM3Theme.accent),
              label: Text('Add Set', style: theme.textTheme.labelSmall?.copyWith(color: StitchM3Theme.accent, fontWeight: FontWeight.w700)),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            exercise.note.isNotEmpty ? exercise.note : 'Add note...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: exercise.note.isNotEmpty ? cs.onSurface : cs.onSurfaceVariant,
              fontStyle: exercise.note.isEmpty ? FontStyle.italic : null,
            ),
          ),
          if (showAddExercise) ...[
            const SizedBox(height: 12),
            _DashedButton(icon: Icons.add, label: 'Add Exercise', onPressed: onAddExercise),
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
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Edit set', style: theme.textTheme.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: TextField(controller: setsController, decoration: const InputDecoration(labelText: 'Set', hintText: '1'), keyboardType: TextInputType.number, autofocus: true)),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: repsController, decoration: const InputDecoration(labelText: 'Reps', hintText: '3'), keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: TextField(controller: loadController, decoration: const InputDecoration(labelText: 'Carico', hintText: '75kg'), keyboardType: TextInputType.text)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(controller: noteController, decoration: const InputDecoration(labelText: 'Note'), maxLines: 2),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant))),
        FilledButton(
          onPressed: () {
            onSave(setsController.text.trim(), repsController.text.trim(), loadController.text.trim(), noteController.text.trim());
            Navigator.of(ctx).pop();
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

class _SetRepCell extends StatelessWidget {
  const _SetRepCell({required this.theme, required this.cs, required this.label, required this.value, required this.compact});

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
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface),
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkoutBuilderBottomNav extends StatelessWidget {
  const _WorkoutBuilderBottomNav({required this.navContext, required this.selectedIndex});

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
                  Icon(icon, size: 24, color: selected ? StitchM3Theme.accent : cs.onSurfaceVariant),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: selected ? StitchM3Theme.accent : cs.onSurfaceVariant,
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
