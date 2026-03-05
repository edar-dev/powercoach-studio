import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/stitch_m3_theme.dart';

/// Workout Builder variant: Enhanced Mobility (Stitch 694ace9b), Multi-set (9ffa631f), Super Set (e63b1ef6).
enum WorkoutBuilderVariant { mobility, multiset, superset }

/// Workout Builder – Enhanced Mobility Controls (Stitch 694ace9b83514965989f12ac2a3d54fa).
class WorkoutBuilderMobilityScreen extends StatefulWidget {
  const WorkoutBuilderMobilityScreen({super.key, this.variant = WorkoutBuilderVariant.mobility});

  final WorkoutBuilderVariant variant;

  @override
  State<WorkoutBuilderMobilityScreen> createState() => _WorkoutBuilderMobilityScreenState();
}

class _WorkoutBuilderMobilityScreenState extends State<WorkoutBuilderMobilityScreen> {
  final _routineNameController = TextEditingController(text: 'Hypertrophy Phase 1');
  int _mobilityTabIndex = 0;
  bool _trainingExpanded = true;
  bool _week1Expanded = true;

  bool _mobilityExpanded = true;

  @override
  void initState() {
    super.initState();
    if (widget.variant != WorkoutBuilderVariant.mobility) {
      _mobilityExpanded = false;
    }
  }

  bool get _showMobilityContent => widget.variant == WorkoutBuilderVariant.mobility && _mobilityExpanded;
  _TrainingVariant get _trainingVariant {
    switch (widget.variant) {
      case WorkoutBuilderVariant.mobility:
        return _TrainingVariant.mobility;
      case WorkoutBuilderVariant.multiset:
        return _TrainingVariant.multiset;
      case WorkoutBuilderVariant.superset:
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
              onPressed: () {},
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
      body: Column(
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
                                onPressed: () {},
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
                          _MobilityItem(title: 'T-Spine Rotation', subtitle: 'Focus on breathing and rib cage position'),
                          const SizedBox(height: 12),
                          _MobilityItem(title: '90/90 Hip Switch', subtitle: 'Keep torso upright, 10 reps per side'),
                          const SizedBox(height: 16),
                          _DashedButton(icon: Icons.add, label: 'Add Exercise'),
                        ],
                      ],
                    ),
                  ),
                  // Training Program
                  _TrainingSection(
                    theme: theme,
                    cs: cs,
                    expanded: _trainingExpanded,
                    week1Expanded: _week1Expanded,
                    onTrainingToggle: () => setState(() => _trainingExpanded = !_trainingExpanded),
                    onWeek1Toggle: () => setState(() => _week1Expanded = !_week1Expanded),
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
  const _MobilityItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

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
          Icon(Icons.drag_indicator, size: 20, color: cs.onSurfaceVariant),
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
          Icon(Icons.edit_outlined, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Icon(Icons.delete_outline, size: 20, color: StitchM3Theme.danger),
        ],
      ),
    );
  }
}

class _DashedButton extends StatelessWidget {
  const _DashedButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return OutlinedButton.icon(
      onPressed: () {},
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
    required this.week1Expanded,
    required this.onTrainingToggle,
    required this.onWeek1Toggle,
    required this.variant,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final bool expanded;
  final bool week1Expanded;
  final VoidCallback onTrainingToggle;
  final VoidCallback onWeek1Toggle;
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
              Container(
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
            ],
          ),
          if (expanded) ...[
            if (variant == _TrainingVariant.mobility) _WeekAccordion(expanded: week1Expanded, onToggle: onWeek1Toggle, theme: theme, cs: cs),
            if (variant == _TrainingVariant.multiset) _WeekDayChipsAndCards(theme: theme, cs: cs, superset: false),
            if (variant == _TrainingVariant.superset) _WeekDayChipsAndCards(theme: theme, cs: cs, superset: true),
          ],
        ],
      ),
    );
  }
}

class _WeekAccordion extends StatelessWidget {
  const _WeekAccordion({required this.expanded, required this.onToggle, required this.theme, required this.cs});

  final bool expanded;
  final VoidCallback onToggle;
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
                      'WEEK 1: ACCLIMATION',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {},
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DAY 1 - Lower Body Push',
                      style: theme.textTheme.titleSmall?.copyWith(color: StitchM3Theme.accent, fontWeight: FontWeight.w700),
                    ),
                    Icon(Icons.settings, size: 18, color: cs.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: 12),
                _ExerciseCard(theme: theme, cs: cs, name: 'Barbell Back Squat', sets: '3', reps: '8-10', rpe: '@8', compact: true),
                const SizedBox(height: 12),
                _ExerciseCard(theme: theme, cs: cs, name: 'Leg Press', sets: '3', reps: '12', rpe: '315lb', compact: true, showAddExercise: true),
                const SizedBox(height: 16),
                _DashedButton(icon: Icons.calendar_today, label: 'Add Day to Week 1'),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _WeekDayChipsAndCards extends StatelessWidget {
  const _WeekDayChipsAndCards({required this.theme, required this.cs, required this.superset});

  final ThemeData theme;
  final ColorScheme cs;
  final bool superset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _Chip(label: 'Week 1', selected: true),
              const SizedBox(width: 8),
              _Chip(label: 'Week 2', selected: false),
              const SizedBox(width: 8),
              _Chip(label: 'Week 3', selected: false),
              const SizedBox(width: 8),
              _Chip(label: 'Week 4', selected: false),
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
                    _DayChip(label: 'Day 1', selected: true),
                    const SizedBox(width: 8),
                    _DayChip(label: 'Day 2', selected: false),
                    const SizedBox(width: 8),
                    _DayChip(label: 'Day 3', selected: false),
                    const SizedBox(width: 8),
                    _DayChip(label: 'Day 4', selected: false),
                  ],
                ),
              ),
            ),
            IconButton(icon: Icon(Icons.settings, size: 20, color: cs.onSurfaceVariant), onPressed: () {}),
          ],
        ),
        const SizedBox(height: 16),
        if (superset)
          _SuperSetBlock(
            theme: theme,
            cs: cs,
            children: [
              _ExerciseCard(theme: theme, cs: cs, name: 'Barbell Back Squat', sets: '3', reps: '8-10', rpe: '@8', compact: false, linked: true),
              const SizedBox(height: 12),
              _ExerciseCard(theme: theme, cs: cs, name: 'Leg Press', sets: '3', reps: '12', rpe: '315lb', compact: false, linked: true),
            ],
          )
        else ...[
          _ExerciseCard(theme: theme, cs: cs, name: 'Barbell Back Squat', sets: '3', reps: '8-10', rpe: '@8', compact: false),
          const SizedBox(height: 16),
          _ExerciseCard(theme: theme, cs: cs, name: 'Leg Press', sets: '3', reps: '12', rpe: '315lb', compact: false, showAddExercise: true),
        ],
        const SizedBox(height: 16),
        _DashedButton(icon: Icons.calendar_today, label: 'Add Day to Week 1'),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: selected ? StitchM3Theme.accent : cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: () {},
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
  const _DayChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
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
    );
  }
}

class _SuperSetBlock extends StatelessWidget {
  const _SuperSetBlock({required this.theme, required this.cs, required this.children});

  final ThemeData theme;
  final ColorScheme cs;
  final List<Widget> children;

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
          ...children,
          const SizedBox(height: 8),
          _DashedButton(icon: Icons.add, label: 'Add Exercise'),
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
    this.showAddExercise = false,
    this.linked = false,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String name;
  final String sets;
  final String reps;
  final String rpe;
  final bool compact;
  final bool showAddExercise;
  final bool linked;

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
            _DashedButton(icon: Icons.add, label: 'Add Exercise'),
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
