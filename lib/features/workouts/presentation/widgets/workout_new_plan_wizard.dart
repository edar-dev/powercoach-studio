import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../core/ui/widgets/app_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/workout_plan_repository.dart';
import '../../domain/workout_routine_plan_encoder.dart';
import '../../domain/workout_split_presets.dart';

/// Guided wizard: plan name → weeks → days/week → split preset → create plan.
Future<void> showWorkoutNewPlanWizard(
  BuildContext context, {
  required String customerId,
  WorkoutPlanRepository? planRepo,
}) async {
  await showAppBottomSheet<void>(
    context: context,
    title: AppLocalizations.of(context).workoutNewPlanWizardTitle,
    fullScreen: true,
    bodyBuilder: (sheetContext) => _WorkoutNewPlanWizardBody(
      customerId: customerId,
      planRepo: planRepo ?? WorkoutPlanRepository(),
      l10n: AppLocalizations.of(sheetContext),
    ),
  );
}

class _WorkoutNewPlanWizardBody extends StatefulWidget {
  const _WorkoutNewPlanWizardBody({
    required this.customerId,
    required this.planRepo,
    required this.l10n,
  });

  final String customerId;
  final WorkoutPlanRepository planRepo;
  final AppLocalizations l10n;

  @override
  State<_WorkoutNewPlanWizardBody> createState() =>
      _WorkoutNewPlanWizardBodyState();
}

class _WorkoutNewPlanWizardBodyState extends State<_WorkoutNewPlanWizardBody> {
  final _nameController = TextEditingController();
  final _pageController = PageController();
  int _step = 0;
  int _weekCount = 4;
  int _daysPerWeek = 4;
  WorkoutSplitPreset _preset = WorkoutSplitPreset.upperLower;
  bool _creating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    if (_creating) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l10n.workoutNewPlanWizardNameRequired)),
      );
      _goToStep(0);
      return;
    }

    setState(() => _creating = true);
    try {
      final routine = buildWorkoutRoutineSkeleton(
        planName: name,
        weekCount: _weekCount,
        daysPerWeek: _daysPerWeek,
        preset: _preset,
      );
      final created = await widget.planRepo.create(
        customerId: widget.customerId,
        name: name,
        planDataJson: encodeWorkoutRoutinePlanData(routine),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      if (!context.mounted) return;
      navigateTo(
        context,
        customerWorkoutEditorPath(widget.customerId, planId: created.id),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _creating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          value: (_step + 1) / 4,
          backgroundColor: cs.surfaceContainerHighest,
          color: StitchM3Theme.accent,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _step = index),
            children: [
              _StepName(l10n: l10n, controller: _nameController),
              _StepWeekCount(
                l10n: l10n,
                weekCount: _weekCount,
                onChanged: (value) => setState(() => _weekCount = value),
              ),
              _StepDaysPerWeek(
                l10n: l10n,
                daysPerWeek: _daysPerWeek,
                onChanged: (value) => setState(() => _daysPerWeek = value),
              ),
              _StepPreset(
                l10n: l10n,
                preset: _preset,
                onChanged: (value) => setState(() => _preset = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (_step > 0)
              TextButton(
                onPressed: _creating ? null : () => _goToStep(_step - 1),
                child: Text(l10n.workoutNewPlanWizardBack),
              )
            else
              const SizedBox.shrink(),
            const Spacer(),
            if (_step < 3)
              FilledButton(
                onPressed: _creating
                    ? null
                    : () {
                        if (_step == 0 &&
                            _nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.workoutNewPlanWizardNameRequired),
                            ),
                          );
                          return;
                        }
                        HapticFeedback.selectionClick();
                        _goToStep(_step + 1);
                      },
                child: Text(l10n.workoutNewPlanWizardNext),
              )
            else
              FilledButton(
                onPressed: _creating ? null : _finish,
                child: _creating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.workoutNewPlanWizardCreate),
              ),
          ],
        ),
      ],
    );
  }
}

class _StepName extends StatelessWidget {
  const _StepName({required this.l10n, required this.controller});

  final AppLocalizations l10n;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.workoutNewPlanWizardStepNameTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.workoutNewPlanWizardStepNameHint,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.workoutNewPlanWizardNameLabel,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
        ),
      ],
    );
  }
}

class _StepWeekCount extends StatelessWidget {
  const _StepWeekCount({
    required this.l10n,
    required this.weekCount,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final int weekCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.workoutNewPlanWizardStepWeeksTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.workoutNewPlanWizardStepWeeksHint,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '$weekCount',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: StitchM3Theme.accent,
          ),
          textAlign: TextAlign.center,
        ),
        Slider(
          value: weekCount.toDouble(),
          min: 1,
          max: 12,
          divisions: 11,
          label: '$weekCount',
          onChanged: (value) => onChanged(value.round()),
        ),
      ],
    );
  }
}

class _StepDaysPerWeek extends StatelessWidget {
  const _StepDaysPerWeek({
    required this.l10n,
    required this.daysPerWeek,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final int daysPerWeek;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.workoutNewPlanWizardStepDaysTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.workoutNewPlanWizardStepDaysHint,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final count in const [3, 4, 5, 6])
              ChoiceChip(
                label: Text('$count'),
                selected: daysPerWeek == count,
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  onChanged(count);
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _StepPreset extends StatelessWidget {
  const _StepPreset({
    required this.l10n,
    required this.preset,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final WorkoutSplitPreset preset;
  final ValueChanged<WorkoutSplitPreset> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.workoutNewPlanWizardStepPresetTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.workoutNewPlanWizardStepPresetHint,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        _PresetTile(
          title: l10n.workoutNewPlanWizardPresetFullBody,
          subtitle: l10n.workoutNewPlanWizardPresetFullBodyHint,
          selected: preset == WorkoutSplitPreset.fullBody,
          onTap: () => onChanged(WorkoutSplitPreset.fullBody),
        ),
        const SizedBox(height: 8),
        _PresetTile(
          title: l10n.workoutNewPlanWizardPresetUpperLower,
          subtitle: l10n.workoutNewPlanWizardPresetUpperLowerHint,
          selected: preset == WorkoutSplitPreset.upperLower,
          onTap: () => onChanged(WorkoutSplitPreset.upperLower),
        ),
        const SizedBox(height: 8),
        _PresetTile(
          title: l10n.workoutNewPlanWizardPresetPpl,
          subtitle: l10n.workoutNewPlanWizardPresetPplHint,
          selected: preset == WorkoutSplitPreset.pushPullLegs,
          onTap: () => onChanged(WorkoutSplitPreset.pushPullLegs),
        ),
      ],
    );
  }
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected ? cs.onPrimaryContainer : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: selected
                            ? cs.onPrimaryContainer
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
