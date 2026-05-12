import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/workout_plan_template_scope.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../../../widgets/app_sheet.dart';
import '../../../customers/data/customer_repository.dart';
import '../../../customers/data/models/customer.dart';
import '../../data/workout_plan_api_model.dart';
import '../../data/workout_plan_repository.dart';

/// Library of reusable workout plan templates (`/workouts/templates`).
class WorkoutPlanTemplatesScreen extends StatefulWidget {
  const WorkoutPlanTemplatesScreen({super.key});

  @override
  State<WorkoutPlanTemplatesScreen> createState() => _WorkoutPlanTemplatesScreenState();
}

class _WorkoutPlanTemplatesScreenState extends State<WorkoutPlanTemplatesScreen> {
  final WorkoutPlanRepository _planRepo = WorkoutPlanRepository();
  final CustomerRepository _customerRepo = CustomerRepository();
  List<WorkoutPlanApiModel> _templates = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _planRepo.listTemplates();
      if (!mounted) return;
      setState(() {
        _templates = list;
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

  Future<void> _assignToCustomer(WorkoutPlanApiModel template) async {
    final l10n = AppLocalizations.of(context);
    List<Customer> customers;
    try {
      final all = await _customerRepo.getAll();
      customers = all.where((c) => !c.isArchived).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportError),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!mounted) return;
    if (customers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dashboardNoCustomersWithoutPlan),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final chosen = await showDialog<Customer>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.workoutTemplatesAssignTitle),
        content: SizedBox(
          width: double.maxFinite,
          height: 360,
          child: ListView.separated(
            itemCount: customers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final c = customers[i];
              return ListTile(
                title: Text(c.name),
                onTap: () => Navigator.of(ctx).pop(c),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
        ],
      ),
    );
    if (chosen == null || !mounted) return;
    try {
      await _planRepo.duplicateToCustomer(
        sourcePlanId: template.id,
        customerId: chosen.id,
        name: template.name,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutTemplatesAssignedSnack),
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

  Future<void> _duplicateTemplate(WorkoutPlanApiModel template) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: '${template.name} (2)');
    String? name;
    try {
      name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.workoutTemplatesDuplicateTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: l10n.workoutTemplatesDuplicateHint),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () {
                final s = controller.text.trim();
                if (s.isEmpty) return;
                Navigator.of(ctx).pop(s);
              },
              child: Text(l10n.workoutTemplatesDuplicate),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
    if (name == null || name.isEmpty || !mounted) return;
    try {
      await _planRepo.createTemplateFromPlan(
        sourcePlanId: template.id,
        templateName: name,
      );
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutTemplatesDuplicateSnack),
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

  Future<void> _confirmDelete(WorkoutPlanApiModel template) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showAppConfirmDialog(
      context: context,
      title: l10n.workoutTemplatesDeleteConfirmTitle,
      message: l10n.workoutTemplatesDeleteConfirmMessage,
      confirmLabel: l10n.workoutTemplatesDelete,
      cancelLabel: l10n.customerCancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      await _planRepo.delete(template.id);
      if (!mounted) return;
      await _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutDeleteError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  void _openEditor(WorkoutPlanApiModel template) {
    HapticFeedback.mediumImpact();
    context
        .push(
      '/workouts/editor/${template.id}?customerId=$kWorkoutPlanTemplateScopeId',
    )
        .then((_) {
      if (mounted) _load();
    });
  }

  void _openNewTemplate() {
    HapticFeedback.mediumImpact();
    context
        .push(
      '/workouts/editor?customerId=$kWorkoutPlanTemplateScopeId',
    )
        .then((_) {
      if (mounted) _load();
    });
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/workouts');
            }
          },
        ),
        title: Text(
          l10n.workoutTemplatesTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: cs.error),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        FilledButton(onPressed: _load, child: Text(l10n.customersRetry)),
                      ],
                    ),
                  ),
                )
              : _templates.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bookmark_outline, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text(
                              l10n.workoutTemplatesEmpty,
                              style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _templates.length,
                        itemBuilder: (context, index) {
                          final t = _templates[index];
                          final title = t.name.trim().isEmpty ? l10n.customerUnnamedPlan : t.name;
                          return Padding(
                            padding: EdgeInsets.only(bottom: index < _templates.length - 1 ? 12 : 0),
                            child: Material(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                                onTap: () => _openEditor(t),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                                    border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.bookmark_outline, color: StitchM3Theme.accent),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(
                                            title,
                                            style: theme.textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: cs.onSurface,
                                            ),
                                          ),
                                          subtitle: Text(
                                            DateFormat.yMMMd(l10n.localeName).format(t.updatedAt),
                                            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                          ),
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant),
                                        onSelected: (value) {
                                          HapticFeedback.mediumImpact();
                                          if (value == 'edit') {
                                            _openEditor(t);
                                          } else if (value == 'assign') {
                                            _assignToCustomer(t);
                                          } else if (value == 'dup') {
                                            _duplicateTemplate(t);
                                          } else if (value == 'del') {
                                            _confirmDelete(t);
                                          }
                                        },
                                        itemBuilder: (ctx) => [
                                          PopupMenuItem(value: 'edit', child: Text(l10n.workoutTemplatesEdit)),
                                          PopupMenuItem(value: 'assign', child: Text(l10n.workoutTemplatesAssign)),
                                          PopupMenuItem(value: 'dup', child: Text(l10n.workoutTemplatesDuplicate)),
                                          PopupMenuItem(value: 'del', child: Text(l10n.workoutTemplatesDelete)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewTemplate,
        icon: const Icon(Icons.add),
        label: Text(l10n.workoutTemplatesNew),
        backgroundColor: StitchM3Theme.accent,
      ),
    );
  }
}
