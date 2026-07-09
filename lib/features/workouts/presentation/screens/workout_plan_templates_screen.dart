import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/constants/workout_plan_template_scope.dart';
import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import '../../../customers/data/customer_repository.dart';
import '../../../customers/data/models/customer.dart';
import '../../data/workout_plan_api_model.dart';
import '../../data/workout_plan_repository.dart';
import '../../domain/workout_template_list_helpers.dart';
import '../../domain/workout_template_preview_helpers.dart';
import '../workout_plan_display_helpers.dart';
import '../workout_template_display_helpers.dart';
import '../widgets/assign_template_customer_dialog.dart';
import '../widgets/assign_template_start_date_dialog.dart';
import '../widgets/workout_plan_name_prompt_dialog.dart';
import '../widgets/workout_plan_template_list.dart';
import '../widgets/workout_plan_template_list_tile.dart';
import '../widgets/workout_plan_template_preview_content.dart';

/// Library of reusable workout plan templates (`/workouts/templates`).
class WorkoutPlanTemplatesScreen extends StatefulWidget {
  const WorkoutPlanTemplatesScreen({super.key});

  @override
  State<WorkoutPlanTemplatesScreen> createState() =>
      _WorkoutPlanTemplatesScreenState();
}

class _WorkoutPlanTemplatesScreenState
    extends State<WorkoutPlanTemplatesScreen> {
  final WorkoutPlanRepository _planRepo = WorkoutPlanRepository();
  final CustomerRepository _customerRepo = CustomerRepository();

  List<WorkoutPlanApiModel> _templates = [];
  final Map<String, TemplateSummary> _summaryByPlanId = {};
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  TemplateSort _sort = TemplateSort.updatedDesc;

  List<WorkoutPlanApiModel> get _visibleTemplates => applyTemplateListQuery(
    templates: _templates,
    searchQuery: _searchQuery,
    sort: _sort,
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  TemplateSummary _summaryFor(WorkoutPlanApiModel plan) {
    return _summaryByPlanId.putIfAbsent(plan.id, () => summarizeTemplate(plan));
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
        _summaryByPlanId
          ..clear()
          ..addEntries(
            list.map((plan) => MapEntry(plan.id, summarizeTemplate(plan))),
          );
        _loading = false;
      });
    } catch (e, st) {
      await Sentry.captureException(e, stackTrace: st);
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
    } catch (e, st) {
      await Sentry.captureException(e, stackTrace: st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutTemplatesCustomersLoadError),
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

    final chosen = await showAssignTemplateCustomerDialog(
      context,
      customers: customers,
    );
    if (chosen == null || !mounted) return;

    final startDateChoice = await showAssignTemplateStartDateDialog(context);
    if (startDateChoice == null || startDateChoice.cancelled || !mounted) {
      return;
    }

    try {
      final created = await _planRepo.duplicateToCustomer(
        sourcePlanId: template.id,
        customerId: chosen.id,
        name: template.name,
      );
      if (startDateChoice.startDate != null) {
        await _planRepo.updateScheduleMarkers(
          planId: created.id,
          startDate: startDateChoice.startDate,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutTemplatesAssignedSnack),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    } catch (e, st) {
      await Sentry.captureException(e, stackTrace: st);
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
    final name = await showWorkoutPlanNamePromptDialog(
      context,
      title: l10n.workoutTemplatesDuplicateTitle,
      nameLabel: l10n.workoutTemplatesDuplicateHint,
      confirmLabel: l10n.workoutTemplatesDuplicate,
      initialName: '${template.name} (2)',
    );
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
    } catch (e, st) {
      await Sentry.captureException(e, stackTrace: st);
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
    } catch (e, st) {
      await Sentry.captureException(e, stackTrace: st);
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

  Future<void> _openTemplatePreview(WorkoutPlanApiModel template) async {
    final l10n = AppLocalizations.of(context);
    final summary = _summaryFor(template);
    final previewWeeks = parseTemplatePreviewWeeks(template.planData);
    await showAppBottomSheet<void>(
      context: context,
      title: l10n.workoutTemplatesPreviewTitle,
      fullScreen: true,
      bodyBuilder: (sheetContext) => WorkoutPlanTemplatePreviewContent(
        template: template,
        summary: summary,
        previewWeeks: previewWeeks,
        onAssign: () {
          Navigator.of(sheetContext).pop();
          _assignToCustomer(template);
        },
        onEdit: () {
          Navigator.of(sheetContext).pop();
          _openEditor(template);
        },
      ),
    );
  }

  void _openEditor(WorkoutPlanApiModel template) {
    HapticFeedback.mediumImpact();
    final uri = Uri(
      path: '/workouts/editor/${template.id}',
      queryParameters: const {'customerId': kWorkoutPlanTemplateScopeId},
    );
    navigateTo(context, uri.toString());
  }

  void _openNewTemplate() {
    HapticFeedback.mediumImpact();
    final uri = Uri(
      path: '/workouts/editor',
      queryParameters: const {'customerId': kWorkoutPlanTemplateScopeId},
    );
    navigateTo(context, uri.toString());
  }

  Widget _buildTemplateTile(
    BuildContext context,
    WorkoutPlanApiModel template,
  ) {
    final l10n = AppLocalizations.of(context);
    final title = template.name.trim().isEmpty
        ? l10n.customerUnnamedPlan
        : template.name;
    final summary = _summaryFor(template);
    return WorkoutPlanTemplateListTile(
      title: title,
      updatedAgo: formatPlanUpdatedAt(l10n, template.updatedAt),
      summaryText: l10n.workoutTemplatesStructureSummary(
        summary.weekCount,
        summary.dayCount,
        summary.exerciseCount,
      ),
      phase: summary.phase,
      onTap: () => _openTemplatePreview(template),
      onEdit: () => _openEditor(template),
      onAssign: () => _assignToCustomer(template),
      onDuplicate: () => _duplicateTemplate(template),
      onDelete: () => _confirmDelete(template),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final visible = _visibleTemplates;

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
              context.go('/workouts/builder');
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
        actions: [
          if (!_loading && _error == null && _templates.isNotEmpty)
            PopupMenuButton<TemplateSort>(
              tooltip: l10n.workoutTemplatesSortTitle,
              icon: Icon(Icons.sort, color: cs.onSurfaceVariant),
              onSelected: (value) => setState(() => _sort = value),
              itemBuilder: (context) => TemplateSort.values
                  .map(
                    (sort) => PopupMenuItem(
                      value: sort,
                      child: Row(
                        children: [
                          if (sort == _sort)
                            Icon(
                              Icons.check,
                              size: 18,
                              color: StitchM3Theme.accent,
                            )
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(templateSortLabel(l10n, sort))),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
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
                    FilledButton(
                      onPressed: _load,
                      child: Text(l10n.customersRetry),
                    ),
                  ],
                ),
              ),
            )
          : _templates.isEmpty
          ? const WorkoutPlanTemplateEmptyState()
          : RefreshIndicator(
              onRefresh: _load,
              child: WorkoutPlanTemplateList(
                templates: visible,
                onSearchQueryChanged: (value) =>
                    setState(() => _searchQuery = value),
                tileBuilder: _buildTemplateTile,
                semanticLabel: l10n.workoutTemplatesSemanticList,
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
