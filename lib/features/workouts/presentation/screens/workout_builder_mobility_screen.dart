import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/stitch_m3_theme.dart';
import '../../data/workout_routine_model.dart';
import '../../data/workout_routine_storage.dart';

/// Workout Builder variant: Enhanced Mobility (694ace9b), Multi-set (9ffa631f), Super Set (e63b1ef6), Intuitive Super Set (7ce630e5).
enum WorkoutBuilderVariant { mobility, multiset, superset, intuitiveSuperset }

/// Workout Builder – Enhanced Mobility Controls (Stitch 694ace9b83514965989f12ac2a3d54fa).
class WorkoutBuilderMobilityScreen extends StatefulWidget {
  const WorkoutBuilderMobilityScreen({super.key, this.variant = WorkoutBuilderVariant.mobility});

  final WorkoutBuilderVariant variant;

  @override
  State<WorkoutBuilderMobilityScreen> createState() => _WorkoutBuilderMobilityScreenState();
}

class _WorkoutBuilderMobilityScreenState extends State<WorkoutBuilderMobilityScreen> {
  final _routineNameController = TextEditingController(text: 'Hypertrophy Phase 1');
  WorkoutRoutine _routine = WorkoutRoutine(
    name: 'Hypertrophy Phase 1',
    mobilityItems: WorkoutRoutine.defaultMobilityItems(),
    weeks: WorkoutRoutine.defaultWeeks(),
  );
  bool _loading = true;
  int _mobilityTabIndex = 0;
  bool _trainingExpanded = true;
  final Set<String> _expandedWeekIds = {'w1'};
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

  Future<void> _saveRoutine() async {
    final name = _routineNameController.text.trim();
    final toSave = _routine.copyWith(name: name.isEmpty ? _routine.name : name);
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

  void _addMobilityItem() {
    setState(() {
      final id = 'm_${DateTime.now().millisecondsSinceEpoch}';
      _routine = _routine.copyWith(
        mobilityItems: [..._routine.mobilityItems, MobilityItem(id: id, title: 'New exercise', subtitle: 'Add details', categoryIndex: _mobilityTabIndex)],
      );
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
    setState(() {
      final list = List<MobilityItem>.from(_routine.mobilityItems);
      if (newIndex > oldIndex) newIndex--;
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
      _routine = _routine.copyWith(mobilityItems: list);
    });
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
                exercises: d.exercises.map((e) => Exercise(id: '${e.id}_$newId', name: e.name, sets: e.sets, reps: e.reps, rpe: e.rpe, note: e.note)).toList(),
              ))
          .toList();
      final newWeek = Week(id: newId, name: '${source.name} (copy)', days: newDays);
      _routine = _routine.copyWith(weeks: [..._routine.weeks, newWeek]);
      _expandedWeekIds.add(newId);
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
    final week = _routine.weeks[weekIndex];
    if (dayIndex < 0 || dayIndex >= week.days.length) return;
    setState(() {
      final day = week.days[dayIndex];
      final exId = 'e_${DateTime.now().millisecondsSinceEpoch}';
      final newEx = [...day.exercises, Exercise(id: exId, name: 'New exercise', sets: '3', reps: '8', rpe: '@8', note: '')];
      final newDays = List<Day>.from(week.days);
      newDays[dayIndex] = day.copyWith(exercises: newEx);
      final newWeeks = List<Week>.from(_routine.weeks);
      newWeeks[weekIndex] = week.copyWith(days: newDays);
      _routine = _routine.copyWith(weeks: newWeeks);
    });
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

  void _updateExercise(int weekIndex, int dayIndex, String exerciseId, {String? name, String? sets, String? reps, String? rpe, String? note}) {
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
        );
      }).toList();
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _loading ? null : _saveRoutine,
              style: TextButton.styleFrom(
                backgroundColor: StitchM3Theme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: const Text('Save'),
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
                          ),
                        ),
                        TextField(
                          controller: _routineNameController,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
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
                              _MobilityTab(label: 'Upper Body', selected: _mobilityTabIndex == 0, onTap: () => setState(() => _mobilityTabIndex = 0)),
                              const SizedBox(width: 16),
                              _MobilityTab(label: 'Lower Body', selected: _mobilityTabIndex == 1, onTap: () => setState(() => _mobilityTabIndex = 1)),
                              const SizedBox(width: 16),
                              _MobilityTab(label: 'Full Body', selected: _mobilityTabIndex == 2, onTap: () => setState(() => _mobilityTabIndex = 2)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            buildDefaultDragHandles: false,
                            onReorder: _reorderMobility,
                            itemCount: _routine.mobilityItems.length,
                            itemBuilder: (context, index) {
                              final item = _routine.mobilityItems[index];
                              return Padding(
                                key: ValueKey(item.id),
                                padding: EdgeInsets.only(bottom: index < _routine.mobilityItems.length - 1 ? 12 : 0),
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
                          _DashedButton(icon: Icons.add, label: 'Add Exercise', onPressed: _addMobilityItem),
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
                    onAddDay: _addDayToWeek,
                    onAddExercise: _addExerciseToDay,
                    onRemoveExercise: _removeExercise,
                    onUpdateExercise: _updateExercise,
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

class _MobilityTab extends StatelessWidget {
  const _MobilityTab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return InkWell(
      onTap: onTap,
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
                const SizedBox(width: 4),
                Icon(Icons.edit, size: 14, color: cs.onSurfaceVariant),
                Icon(Icons.delete_outline, size: 14, color: StitchM3Theme.danger),
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
  void Function(String name, String sets, String reps, String rpe, String note) onSave,
) {
  final nameController = TextEditingController(text: initialName);
  final setsController = TextEditingController(text: initialSets);
  final repsController = TextEditingController(text: initialReps);
  final rpeController = TextEditingController(text: initialRpe);
  final noteController = TextEditingController(text: initialNote);
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Edit exercise', style: theme.textTheme.titleMedium),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name'), autofocus: true),
            const SizedBox(height: 12),
            TextField(controller: setsController, decoration: const InputDecoration(labelText: 'Sets'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: repsController, decoration: const InputDecoration(labelText: 'Reps')),
            const SizedBox(height: 12),
            TextField(controller: rpeController, decoration: const InputDecoration(labelText: 'RPE / Load')),
            const SizedBox(height: 12),
            TextField(controller: noteController, decoration: const InputDecoration(labelText: 'Note'), maxLines: 2),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant))),
        FilledButton(
          onPressed: () {
            onSave(
              nameController.text.trim(),
              setsController.text.trim(),
              repsController.text.trim(),
              rpeController.text.trim(),
              noteController.text.trim(),
            );
            Navigator.of(ctx).pop();
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
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
    required this.onAddDay,
    required this.onAddExercise,
    required this.onRemoveExercise,
    required this.onUpdateExercise,
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
  final void Function(int) onAddDay;
  final void Function(int, int) onAddExercise;
  final void Function(int, int, String) onRemoveExercise;
  final void Function(int, int, String, {String? name, String? sets, String? reps, String? rpe, String? note}) onUpdateExercise;
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
                    onAddDay: () => onAddDay(e.key),
                    onAddExercise: onAddExercise,
                    onRemoveExercise: onRemoveExercise,
                    onUpdateExercise: onUpdateExercise,
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
                onAddDay: onAddDay,
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
                onAddDay: onAddDay,
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
    required this.onAddDay,
    required this.onAddExercise,
    required this.onRemoveExercise,
    required this.onUpdateExercise,
    required this.theme,
    required this.cs,
  });

  final int weekIndex;
  final Week week;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onClone;
  final VoidCallback onAddDay;
  final void Function(int, int) onAddExercise;
  final void Function(int, int, String) onRemoveExercise;
  final void Function(int, int, String, {String? name, String? sets, String? reps, String? rpe, String? note}) onUpdateExercise;
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
                    Icon(Icons.more_vert, color: cs.onSurfaceVariant, size: 20),
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
                        Icon(Icons.settings, size: 18, color: cs.onSurfaceVariant),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...day.exercises.asMap().entries.map((exEntry) {
                      final ex = exEntry.value;
                      final isLast = exEntry.key == day.exercises.length - 1;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ExerciseCard(
                          theme: theme,
                          cs: cs,
                          name: ex.name,
                          sets: ex.sets,
                          reps: ex.reps,
                          rpe: ex.rpe,
                          note: ex.note,
                          compact: true,
                          showAddExercise: isLast,
                          onAddExercise: isLast ? () => onAddExercise(weekIndex, dayIndex) : null,
                          onRemove: () => onRemoveExercise(weekIndex, dayIndex, ex.id),
                          onEdit: (name, sets, reps, rpe, note) => onUpdateExercise(weekIndex, dayIndex, ex.id, name: name, sets: sets, reps: reps, rpe: rpe, note: note),
                        ),
                      );
                    }),
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
    required this.onAddDay,
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
  final void Function(int, int, String, {String? name, String? sets, String? reps, String? rpe, String? note}) onUpdateExercise;
  final void Function(int) onAddDay;

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
            IconButton(icon: Icon(Icons.settings, size: 20, color: cs.onSurfaceVariant), onPressed: () {}),
          ],
        ),
        const SizedBox(height: 16),
        if (day != null) ...[
          if (superset)
            _SuperSetBlock(
              theme: theme,
              cs: cs,
              weekIndex: weekIndex,
              dayIndex: dayIndex,
              exercises: day.exercises,
              onAddExercise: () => onAddExercise(weekIndex, dayIndex),
              onRemoveExercise: onRemoveExercise,
              onUpdateExercise: onUpdateExercise,
            )
          else ...[
            ...day.exercises.asMap().entries.map((exEntry) {
              final ex = exEntry.value;
              final isLast = exEntry.key == day.exercises.length - 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ExerciseCard(
                  theme: theme,
                  cs: cs,
                  name: ex.name,
                  sets: ex.sets,
                  reps: ex.reps,
                  rpe: ex.rpe,
                  note: ex.note,
                  compact: false,
                  showAddExercise: isLast,
                  onAddExercise: isLast ? () => onAddExercise(weekIndex, dayIndex) : null,
                  onRemove: () => onRemoveExercise(weekIndex, dayIndex, ex.id),
                  onEdit: (name, sets, reps, rpe, note) => onUpdateExercise(weekIndex, dayIndex, ex.id, name: name, sets: sets, reps: reps, rpe: rpe, note: note),
                ),
              );
            }),
            if (day.exercises.isEmpty)
              _DashedButton(
                icon: Icons.add,
                label: 'Add Exercise',
                onPressed: () => onAddExercise(weekIndex, dayIndex),
              ),
          ],
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
    required this.onAddExercise,
    required this.onRemoveExercise,
    required this.onUpdateExercise,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final int weekIndex;
  final int dayIndex;
  final List<Exercise> exercises;
  final VoidCallback onAddExercise;
  final void Function(int, int, String) onRemoveExercise;
  final void Function(int, int, String, {String? name, String? sets, String? reps, String? rpe, String? note}) onUpdateExercise;

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
              name: ex.name,
              sets: ex.sets,
              reps: ex.reps,
              rpe: ex.rpe,
              note: ex.note,
              compact: false,
              linked: true,
              onRemove: () => onRemoveExercise(weekIndex, dayIndex, ex.id),
              onEdit: (name, sets, reps, rpe, note) => onUpdateExercise(weekIndex, dayIndex, ex.id, name: name, sets: sets, reps: reps, rpe: rpe, note: note),
            ),
          )),
          const SizedBox(height: 8),
          _DashedButton(icon: Icons.add, label: 'Add Exercise', onPressed: onAddExercise),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.theme,
    required this.cs,
    required this.name,
    required this.sets,
    required this.reps,
    required this.rpe,
    required this.compact,
    this.note = '',
    this.showAddExercise = false,
    this.linked = false,
    this.onAddExercise,
    this.onRemove,
    this.onEdit,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String name;
  final String sets;
  final String reps;
  final String rpe;
  final bool compact;
  final String note;
  final bool showAddExercise;
  final bool linked;
  final VoidCallback? onAddExercise;
  final VoidCallback? onRemove;
  final void Function(String name, String sets, String reps, String rpe, String note)? onEdit;

  @override
  Widget build(BuildContext context) {
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
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
              ),
              if (linked) Icon(Icons.link_off, size: 20, color: StitchM3Theme.accent),
              if (linked) const SizedBox(width: 8),
              if (onEdit != null)
                InkWell(
                  onTap: () => _showEditExerciseDialog(context, theme, cs, name, sets, reps, rpe, note, onEdit!),
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
          Row(
            children: [
              Expanded(child: _SetRepCell(theme: theme, cs: cs, label: 'Sets', value: sets, compact: compact)),
              const SizedBox(width: 12),
              Expanded(child: _SetRepCell(theme: theme, cs: cs, label: 'Reps', value: reps, compact: compact)),
              const SizedBox(width: 12),
              Expanded(child: _SetRepCell(theme: theme, cs: cs, label: 'RPE / Load', value: rpe, compact: compact)),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.add, size: 16, color: StitchM3Theme.accent),
              label: Text('Add Set', style: theme.textTheme.labelSmall?.copyWith(color: StitchM3Theme.accent, fontWeight: FontWeight.w700)),
            ),
          ],
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Add note...',
              hintStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              prefixIcon: Icon(Icons.notes, size: 16, color: cs.onSurfaceVariant),
              isDense: true,
              filled: true,
              fillColor: cs.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
