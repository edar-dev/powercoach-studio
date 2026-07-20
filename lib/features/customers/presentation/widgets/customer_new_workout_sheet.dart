import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../core/ui/widgets/app_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../workouts/data/workout_plan_api_model.dart';
import '../../../workouts/data/workout_plan_repository.dart';
import '../../../workouts/presentation/widgets/workout_new_plan_wizard.dart';
import '../../../workouts/presentation/widgets/workout_plan_name_prompt_dialog.dart';

enum CustomerNewWorkoutChoice { blank, guided, fromTemplate, duplicateExisting }

/// Bottom sheet entry for creating a new customer workout plan.
Future<void> showCustomerNewWorkoutSheet(
  BuildContext context, {
  required String customerId,
  WorkoutPlanRepository? planRepo,
}) async {
  final l10n = AppLocalizations.of(context);
  final repository = planRepo ?? WorkoutPlanRepository();

  final choice = await showAppBottomSheet<CustomerNewWorkoutChoice>(
    context: context,
    title: l10n.customerNewWorkoutSheetTitle,
    bodyBuilder: (sheetContext) => _CustomerNewWorkoutSheetBody(
      l10n: l10n,
      onChoice: (value) => Navigator.of(sheetContext).pop(value),
    ),
  );
  if (!context.mounted || choice == null) return;

  switch (choice) {
    case CustomerNewWorkoutChoice.blank:
      HapticFeedback.mediumImpact();
      navigateTo(context, customerWorkoutEditorPath(customerId));
    case CustomerNewWorkoutChoice.guided:
      HapticFeedback.mediumImpact();
      await showWorkoutNewPlanWizard(
        context,
        customerId: customerId,
        planRepo: repository,
      );
    case CustomerNewWorkoutChoice.fromTemplate:
      HapticFeedback.mediumImpact();
      navigateTo(
        context,
        Uri(
          path: '/workouts/templates',
          queryParameters: {'customerId': customerId},
        ).toString(),
      );
    case CustomerNewWorkoutChoice.duplicateExisting:
      await _duplicateExistingPlan(
        context,
        customerId: customerId,
        planRepo: repository,
      );
  }
}

Future<void> _duplicateExistingPlan(
  BuildContext context, {
  required String customerId,
  required WorkoutPlanRepository planRepo,
}) async {
  final l10n = AppLocalizations.of(context);
  List<WorkoutPlanApiModel> plans;
  try {
    plans = await planRepo.getByCustomerId(customerId);
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  if (!context.mounted) return;
  if (plans.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.customerNewWorkoutNoPlansToDuplicate),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  final source = await showAppBottomSheet<WorkoutPlanApiModel>(
    context: context,
    title: l10n.customerNewWorkoutDuplicatePickTitle,
    bodyBuilder: (sheetContext) => ListView.separated(
      shrinkWrap: true,
      itemCount: plans.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, index) {
        final plan = plans[index];
        final title = plan.name.trim().isEmpty
            ? l10n.customerUnnamedPlan
            : plan.name;
        return ListTile(
          title: Text(title),
          onTap: () => Navigator.of(sheetContext).pop(plan),
        );
      },
    ),
  );
  if (source == null || !context.mounted) return;

  final name = await showWorkoutPlanNamePromptDialog(
    context,
    title: l10n.workoutDuplicateTitle,
    nameLabel: l10n.workoutDuplicateNameHint,
    confirmLabel: l10n.workoutDuplicateAction,
    initialName: '${source.name} (2)',
  );
  if (name == null || name.isEmpty || !context.mounted) return;

  try {
    final created = await planRepo.duplicateToCustomer(
      sourcePlanId: source.id,
      customerId: customerId,
      name: name,
    );
    if (!context.mounted) return;
    navigateTo(
      context,
      customerWorkoutEditorPath(customerId, planId: created.id),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      ),
    );
  }
}

class _CustomerNewWorkoutSheetBody extends StatelessWidget {
  const _CustomerNewWorkoutSheetBody({
    required this.l10n,
    required this.onChoice,
  });

  final AppLocalizations l10n;
  final ValueChanged<CustomerNewWorkoutChoice> onChoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ChoiceTile(
          icon: Icons.note_add_outlined,
          title: l10n.customerNewWorkoutBlank,
          subtitle: l10n.customerNewWorkoutBlankHint,
          colorScheme: cs,
          onTap: () => onChoice(CustomerNewWorkoutChoice.blank),
        ),
        const SizedBox(height: 8),
        _ChoiceTile(
          icon: Icons.auto_fix_high_outlined,
          title: l10n.customerNewWorkoutGuided,
          subtitle: l10n.customerNewWorkoutGuidedHint,
          colorScheme: cs,
          onTap: () => onChoice(CustomerNewWorkoutChoice.guided),
        ),
        const SizedBox(height: 8),
        _ChoiceTile(
          icon: Icons.bookmark_outline,
          title: l10n.customerNewWorkoutFromTemplate,
          subtitle: l10n.customerNewWorkoutFromTemplateHint,
          colorScheme: cs,
          onTap: () => onChoice(CustomerNewWorkoutChoice.fromTemplate),
        ),
        const SizedBox(height: 8),
        _ChoiceTile(
          icon: Icons.copy_outlined,
          title: l10n.customerNewWorkoutDuplicateExisting,
          subtitle: l10n.customerNewWorkoutDuplicateExistingHint,
          colorScheme: cs,
          onTap: () => onChoice(CustomerNewWorkoutChoice.duplicateExisting),
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.surfaceContainerHighest,
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
              Icon(icon, color: StitchM3Theme.accent),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
