import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../data/workout_plan_api_model.dart';
import '../../data/workout_plan_repository.dart';
import '../../domain/density_block.dart';
import '../../domain/workout_plan_list_helpers.dart';
import '../../domain/workout_routine_diff.dart';
import '../workout_plan_display_helpers.dart';

/// Compares Plan A (the plan the coach came from) against another plan for
/// the same customer (Plan B), including archived plans.
class PlanDiffScreen extends StatefulWidget {
  const PlanDiffScreen({super.key});

  @override
  State<PlanDiffScreen> createState() => _PlanDiffScreenState();
}

class _PlanDiffScreenState extends State<PlanDiffScreen> {
  final WorkoutPlanRepository _planRepo = WorkoutPlanRepository();

  bool _loading = true;
  String? _error;
  String _customerId = '';
  String _planIdA = '';
  List<WorkoutPlanApiModel> _plans = const [];
  WorkoutPlanApiModel? _planA;
  WorkoutPlanApiModel? _planB;
  WorkoutRoutineDiffResult? _diffResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _load();
    });
  }

  Future<void> _load() async {
    final l10n = AppLocalizations.of(context);
    final uri = GoRouterState.of(context).uri;
    _customerId = uri.queryParameters['customerId'] ?? '';
    _planIdA = uri.queryParameters['planIdA'] ?? '';
    final planIdB = uri.queryParameters['planIdB'];

    if (_customerId.isEmpty || _planIdA.isEmpty) {
      setState(() {
        _loading = false;
        _error = l10n.workoutPlanDiffLoadError;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plans = await _planRepo.getByCustomerId(_customerId);
      final planA = _findPlan(plans, _planIdA);
      if (planA == null) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = l10n.workoutPlanDiffLoadError;
        });
        return;
      }
      final planB = planIdB == null ? null : _findPlan(plans, planIdB);
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _planA = planA;
        _planB = planB;
        _diffResult = planB == null ? null : _computeDiff(planA, planB);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  WorkoutPlanApiModel? _findPlan(List<WorkoutPlanApiModel> plans, String id) {
    for (final plan in plans) {
      if (plan.id == id) return plan;
    }
    return null;
  }

  WorkoutRoutineDiffResult _computeDiff(
    WorkoutPlanApiModel planA,
    WorkoutPlanApiModel planB,
  ) {
    return diffWorkoutRoutines(
      planA: planDataToRoutine(planA.planData),
      planB: planDataToRoutine(planB.planData),
    );
  }

  void _selectPlanB(WorkoutPlanApiModel plan) {
    final planA = _planA;
    if (planA == null) return;
    setState(() {
      _planB = plan;
      _diffResult = _computeDiff(planA, plan);
    });
    navigateReplace(
      context,
      planDiffPath(customerId: _customerId, planIdA: _planIdA, planIdB: plan.id),
    );
  }

  void _reopenPicker() {
    setState(() {
      _planB = null;
      _diffResult = null;
    });
    navigateReplace(
      context,
      planDiffPath(customerId: _customerId, planIdA: _planIdA),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        title: Text(
          l10n.workoutPlanDiffTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        actions: [
          if (_planB != null)
            TextButton(
              onPressed: _reopenPicker,
              child: Text(l10n.workoutPlanDiffChangePlanB),
            ),
        ],
      ),
      body: _buildBody(context, theme, cs, l10n),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    AppLocalizations l10n,
  ) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final planA = _planA;
    if (_error != null || planA == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error ?? l10n.workoutPlanDiffLoadError,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final planB = _planB;
    final diffResult = _diffResult;
    if (planB == null || diffResult == null) {
      return _PlanBPicker(
        l10n: l10n,
        theme: theme,
        colorScheme: cs,
        planA: planA,
        otherPlans: _plans.where((p) => p.id != planA.id).toList(),
        onSelected: _selectPlanB,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _PlanDiffHeader(
          l10n: l10n,
          theme: theme,
          colorScheme: cs,
          planA: planA,
          planB: planB,
        ),
        const SizedBox(height: 16),
        _PlanDiffSummary(l10n: l10n, theme: theme, colorScheme: cs, diff: diffResult),
        const SizedBox(height: 16),
        if (!diffResult.hasChanges)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                l10n.workoutPlanDiffEmpty,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          for (final weekDiff in diffResult.weekDiffs)
            if (weekDiff.hasChange)
              _PlanDiffWeekSection(
                l10n: l10n,
                theme: theme,
                colorScheme: cs,
                weekDiff: weekDiff,
              ),
      ],
    );
  }
}

class _PlanBPicker extends StatelessWidget {
  const _PlanBPicker({
    required this.l10n,
    required this.theme,
    required this.colorScheme,
    required this.planA,
    required this.otherPlans,
    required this.onSelected,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final WorkoutPlanApiModel planA;
  final List<WorkoutPlanApiModel> otherPlans;
  final ValueChanged<WorkoutPlanApiModel> onSelected;

  @override
  Widget build(BuildContext context) {
    if (otherPlans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.workoutPlanDiffNoOtherPlans,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(
          l10n.workoutPlanDiffPickPlanBTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${l10n.workoutPlanDiffPlanALabel}: ${planA.name}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        for (final plan in otherPlans)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
              child: InkWell(
                onTap: () => onSelected(plan),
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name.isEmpty
                                  ? l10n.workoutNewPlanName
                                  : plan.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatPlanUpdatedAt(l10n, plan.updatedAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isArchivedPlan(plan))
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Chip(
                            label: Text(l10n.workoutPlanStatusArchived),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PlanDiffHeader extends StatelessWidget {
  const _PlanDiffHeader({
    required this.l10n,
    required this.theme,
    required this.colorScheme,
    required this.planA,
    required this.planB,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final WorkoutPlanApiModel planA;
  final WorkoutPlanApiModel planB;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PlanDiffHeaderCard(
            label: l10n.workoutPlanDiffPlanALabel,
            planName: planA.name,
            theme: theme,
            colorScheme: colorScheme,
          ),
        ),
        const SizedBox(width: 12),
        Icon(Icons.compare_arrows, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: _PlanDiffHeaderCard(
            label: l10n.workoutPlanDiffPlanBLabel,
            planName: planB.name,
            theme: theme,
            colorScheme: colorScheme,
          ),
        ),
      ],
    );
  }
}

class _PlanDiffHeaderCard extends StatelessWidget {
  const _PlanDiffHeaderCard({
    required this.label,
    required this.planName,
    required this.theme,
    required this.colorScheme,
  });

  final String label;
  final String planName;
  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            planName,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PlanDiffSummary extends StatelessWidget {
  const _PlanDiffSummary({
    required this.l10n,
    required this.theme,
    required this.colorScheme,
    required this.diff,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final WorkoutRoutineDiffResult diff;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      if (diff.addedDayCount > 0)
        _summaryChip(l10n.workoutPlanDiffSummaryDaysAdded(diff.addedDayCount)),
      if (diff.removedDayCount > 0)
        _summaryChip(
          l10n.workoutPlanDiffSummaryDaysRemoved(diff.removedDayCount),
        ),
      if (diff.changedDayCount > 0)
        _summaryChip(
          l10n.workoutPlanDiffSummaryDaysChanged(diff.changedDayCount),
        ),
      if (diff.addedExerciseCount > 0)
        _summaryChip(
          l10n.workoutPlanDiffSummaryExercisesAdded(diff.addedExerciseCount),
        ),
      if (diff.removedExerciseCount > 0)
        _summaryChip(
          l10n.workoutPlanDiffSummaryExercisesRemoved(
            diff.removedExerciseCount,
          ),
        ),
      if (diff.changedExerciseCount > 0)
        _summaryChip(
          l10n.workoutPlanDiffSummaryExercisesChanged(
            diff.changedExerciseCount,
          ),
        ),
    ];
    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }

  Widget _summaryChip(String label) => Chip(
    label: Text(label),
    visualDensity: VisualDensity.compact,
  );
}

class _PlanDiffWeekSection extends StatelessWidget {
  const _PlanDiffWeekSection({
    required this.l10n,
    required this.theme,
    required this.colorScheme,
    required this.weekDiff,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final WeekDiff weekDiff;

  @override
  Widget build(BuildContext context) {
    final changedDays = weekDiff.dayDiffs.where((d) => d.hasChange).toList();
    if (changedDays.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'W${weekDiff.weekIndex + 1}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          for (final dayDiff in changedDays)
            _PlanDiffDayCard(
              l10n: l10n,
              theme: theme,
              colorScheme: colorScheme,
              dayDiff: dayDiff,
            ),
        ],
      ),
    );
  }
}

class _PlanDiffDayCard extends StatelessWidget {
  const _PlanDiffDayCard({
    required this.l10n,
    required this.theme,
    required this.colorScheme,
    required this.dayDiff,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final DayDiff dayDiff;

  String _badgeLabel(WorkoutRoutineDiffKind kind) => switch (kind) {
    WorkoutRoutineDiffKind.added => l10n.workoutPlanDiffBadgeAdded,
    WorkoutRoutineDiffKind.removed => l10n.workoutPlanDiffBadgeRemoved,
    _ => l10n.workoutPlanDiffBadgeChanged,
  };

  @override
  Widget build(BuildContext context) {
    final changedExercises = dayDiff.exerciseDiffs
        .where((e) => e.hasChange)
        .toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dayDiff.name.isEmpty
                      ? 'D${dayDiff.dayIndex + 1}'
                      : dayDiff.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (dayDiff.kind != WorkoutRoutineDiffKind.unchanged)
                Chip(
                  label: Text(_badgeLabel(dayDiff.kind)),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          if (dayDiff.coachingNoteChanged) ...[
            const SizedBox(height: 8),
            Text(
              l10n.workoutPlanDiffCoachingNoteLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if ((dayDiff.coachingNoteBefore ?? '').trim().isNotEmpty)
              Text(
                '− ${dayDiff.coachingNoteBefore!.trim()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            if ((dayDiff.coachingNoteAfter ?? '').trim().isNotEmpty)
              Text(
                '+ ${dayDiff.coachingNoteAfter!.trim()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
          ],
          if (dayDiff.densityBlockDiffs.any((d) => d.hasChange)) ...[
            const SizedBox(height: 8),
            for (final densityDiff
                in dayDiff.densityBlockDiffs.where((d) => d.hasChange))
              _PlanDiffDensityRow(
                l10n: l10n,
                theme: theme,
                colorScheme: colorScheme,
                densityDiff: densityDiff,
              ),
          ],
          if (changedExercises.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final exerciseDiff in changedExercises)
              _PlanDiffExerciseRow(
                l10n: l10n,
                theme: theme,
                colorScheme: colorScheme,
                exerciseDiff: exerciseDiff,
              ),
          ],
        ],
      ),
    );
  }
}

class _PlanDiffDensityRow extends StatelessWidget {
  const _PlanDiffDensityRow({
    required this.l10n,
    required this.theme,
    required this.colorScheme,
    required this.densityDiff,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final DensityBlockDiff densityDiff;

  String _typeLabel(DensityBlockConfig config) => switch (config.type) {
        DensityBlockType.circuit => l10n.densityBlockTypeCircuit,
        DensityBlockType.emom => l10n.densityBlockTypeEmom,
        DensityBlockType.superset => l10n.densityBlockTypeSuperset,
      };

  String _line(DensityBlockConfig config) {
    final type = _typeLabel(config);
    final detail = densityBlockExportDetail(config);
    if (detail.isEmpty) return type;
    return '$type · $detail';
  }

  @override
  Widget build(BuildContext context) {
    final before = densityDiff.before;
    final after = densityDiff.after;
    final String text;
    final Color color;
    switch (densityDiff.kind) {
      case WorkoutRoutineDiffKind.added:
        text = '+ ${_line(after!)}';
        color = colorScheme.primary;
      case WorkoutRoutineDiffKind.removed:
        text = '− ${_line(before!)}';
        color = colorScheme.error;
      default:
        text =
            '${before == null ? '—' : _line(before)} → ${after == null ? '—' : _line(after)}';
        color = colorScheme.onSurfaceVariant;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(color: color),
      ),
    );
  }
}

class _PlanDiffExerciseRow extends StatelessWidget {
  const _PlanDiffExerciseRow({
    required this.l10n,
    required this.theme,
    required this.colorScheme,
    required this.exerciseDiff,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final ExerciseDiff exerciseDiff;

  String _badgeLabel(WorkoutRoutineDiffKind kind) => switch (kind) {
    WorkoutRoutineDiffKind.added => l10n.workoutPlanDiffBadgeAdded,
    WorkoutRoutineDiffKind.removed => l10n.workoutPlanDiffBadgeRemoved,
    _ => l10n.workoutPlanDiffBadgeChanged,
  };

  @override
  Widget build(BuildContext context) {
    final changedSets = exerciseDiff.setDiffs.where((s) => s.hasChange).toList();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exerciseDiff.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (exerciseDiff.kind != WorkoutRoutineDiffKind.unchanged)
                Text(
                  _badgeLabel(exerciseDiff.kind),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          for (final setDiff in changedSets)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 2),
              child: Text(
                _setDiffLine(setDiff),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _setDiffLine(ExerciseSetDiff setDiff) {
    final label = 'Set ${setDiff.setIndex + 1}';
    final before = setDiff.before?.displayText ?? '';
    final after = setDiff.after?.displayText ?? '';
    switch (setDiff.kind) {
      case WorkoutRoutineDiffKind.added:
        return '$label: + ${after.isEmpty ? '—' : after}';
      case WorkoutRoutineDiffKind.removed:
        return '$label: − ${before.isEmpty ? '—' : before}';
      default:
        return '$label: ${before.isEmpty ? '—' : before} → ${after.isEmpty ? '—' : after}';
    }
  }
}
