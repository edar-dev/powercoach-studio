import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/constants/workout_plan_template_scope.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import '../../../customers/data/customer_repository.dart';
import '../../../customers/data/models/customer.dart';
import '../../data/workout_plan_api_model.dart';
import '../../data/workout_plan_repository.dart';
import '../../domain/workout_template_list_helpers.dart';

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

    final chosen = await showDialog<Customer>(
      context: context,
      builder: (ctx) => _AssignTemplateCustomerDialog(customers: customers),
    );
    if (chosen == null || !mounted) return;

    final startDateChoice = await showDialog<_AssignStartDateResult>(
      context: context,
      builder: (ctx) => const _AssignStartDateDialog(),
    );
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
    final controller = TextEditingController(text: '${template.name} (2)');
    String? name;
    try {
      name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.workoutTemplatesDuplicateTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: l10n.workoutTemplatesDuplicateHint,
            ),
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
      bodyBuilder: (sheetContext) => _TemplatePreviewContent(
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
    context.push(uri.toString()).then((_) {
      if (mounted) _load();
    });
  }

  void _openNewTemplate() {
    HapticFeedback.mediumImpact();
    final uri = Uri(
      path: '/workouts/editor',
      queryParameters: const {'customerId': kWorkoutPlanTemplateScopeId},
    );
    context.push(uri.toString()).then((_) {
      if (mounted) _load();
    });
  }

  String _formatUpdatedAgo(AppLocalizations l10n, DateTime updated) {
    final diff = DateTime.now().difference(updated);
    if (diff.inDays > 0) return l10n.updatedDaysAgo(diff.inDays);
    if (diff.inHours > 0) return l10n.updatedHoursAgo(diff.inHours);
    if (diff.inMinutes > 0) return l10n.updatedMinutesAgo(diff.inMinutes);
    return l10n.updatedJustNow;
  }

  String _sortLabel(AppLocalizations l10n, TemplateSort sort) {
    switch (sort) {
      case TemplateSort.nameAsc:
        return l10n.workoutTemplatesSortNameAsc;
      case TemplateSort.updatedDesc:
        return l10n.workoutTemplatesSortUpdatedDesc;
      case TemplateSort.weekCountDesc:
        return l10n.workoutTemplatesSortWeekCountDesc;
    }
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
                          Expanded(child: Text(_sortLabel(l10n, sort))),
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
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_outline,
                      size: 64,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.workoutTemplatesEmpty,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: Semantics(
                container: true,
                label: l10n.workoutTemplatesSemanticList,
                explicitChildNodes: true,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: TextField(
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: l10n.workoutTemplatesSearchHint,
                            hintStyle: TextStyle(color: cs.onSurfaceVariant),
                            prefixIcon: Icon(
                              Icons.search,
                              color: cs.onSurfaceVariant,
                              size: 22,
                            ),
                            filled: true,
                            fillColor: cs.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                StitchM3Theme.radiusLg,
                              ),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (visible.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l10n.workoutTemplatesNoMatch,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            if (index.isOdd) return const SizedBox(height: 12);
                            final plan = visible[index ~/ 2];
                            final title = plan.name.trim().isEmpty
                                ? l10n.customerUnnamedPlan
                                : plan.name;
                            final summary = _summaryFor(plan);
                            return _TemplateCard(
                              title: title,
                              updatedAgo: _formatUpdatedAgo(
                                l10n,
                                plan.updatedAt,
                              ),
                              summaryText: l10n
                                  .workoutTemplatesStructureSummary(
                                    summary.weekCount,
                                    summary.dayCount,
                                    summary.exerciseCount,
                                  ),
                              phase: summary.phase,
                              onTap: () => _openTemplatePreview(plan),
                              onEdit: () => _openEditor(plan),
                              onAssign: () => _assignToCustomer(plan),
                              onDuplicate: () => _duplicateTemplate(plan),
                              onDelete: () => _confirmDelete(plan),
                            );
                          }, childCount: visible.length * 2 - 1),
                        ),
                      ),
                  ],
                ),
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

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.title,
    required this.updatedAgo,
    required this.summaryText,
    required this.onTap,
    required this.onEdit,
    required this.onAssign,
    required this.onDuplicate,
    required this.onDelete,
    this.phase,
  });

  final String title;
  final String updatedAgo;
  final String summaryText;
  final String? phase;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onAssign;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final cleanPhase = phase?.trim();
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.bookmark_outline, color: StitchM3Theme.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      summaryText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      updatedAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    if (cleanPhase != null && cleanPhase.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: StitchM3Theme.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          cleanPhase,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: StitchM3Theme.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant),
                onSelected: (value) {
                  HapticFeedback.mediumImpact();
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'assign') {
                    onAssign();
                  } else if (value == 'dup') {
                    onDuplicate();
                  } else if (value == 'del') {
                    onDelete();
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(l10n.workoutTemplatesEdit),
                  ),
                  PopupMenuItem(
                    value: 'assign',
                    child: Text(l10n.workoutTemplatesAssign),
                  ),
                  PopupMenuItem(
                    value: 'dup',
                    child: Text(l10n.workoutTemplatesDuplicate),
                  ),
                  PopupMenuItem(
                    value: 'del',
                    child: Text(l10n.workoutTemplatesDelete),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplatePreviewContent extends StatelessWidget {
  const _TemplatePreviewContent({
    required this.template,
    required this.summary,
    required this.previewWeeks,
    required this.onEdit,
    required this.onAssign,
  });

  final WorkoutPlanApiModel template;
  final TemplateSummary summary;
  final List<TemplatePreviewWeek> previewWeeks;
  final VoidCallback onEdit;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          template.name.trim().isEmpty
              ? l10n.customerUnnamedPlan
              : template.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.workoutTemplatesStructureSummary(
            summary.weekCount,
            summary.dayCount,
            summary.exerciseCount,
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        if (previewWeeks.isEmpty)
          Text(
            l10n.workoutTemplatesPreviewEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          )
        else
          ...previewWeeks.map(
            (week) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      week.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...week.days.map(
                      (day) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day.name,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ...day.exercises.map(
                              (exercise) => Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  '\u2022 $exercise',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            if (day.remainingExercises > 0)
                              Text(
                                l10n.workoutTemplatesPreviewExercisesMore(
                                  day.remainingExercises,
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
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
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onEdit,
                child: Text(l10n.workoutTemplatesEdit),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: onAssign,
                child: Text(l10n.workoutTemplatesAssign),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AssignTemplateCustomerDialog extends StatefulWidget {
  const _AssignTemplateCustomerDialog({required this.customers});

  final List<Customer> customers;

  @override
  State<_AssignTemplateCustomerDialog> createState() =>
      _AssignTemplateCustomerDialogState();
}

class _AssignTemplateCustomerDialogState
    extends State<_AssignTemplateCustomerDialog> {
  final TextEditingController _queryController = TextEditingController();
  String _queryLower = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  List<Customer> get _filtered {
    final q = _queryLower;
    if (q.isEmpty) return widget.customers;
    return widget.customers
        .where((c) => c.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filtered = _filtered;
    return AlertDialog(
      title: Text(l10n.workoutTemplatesAssignTitle),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                hintText: l10n.workoutTemplatesAssignSearchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (v) {
                setState(() => _queryLower = v.trim().toLowerCase());
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        l10n.workoutTemplatesAssignNoMatch,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final c = filtered[i];
                        return ListTile(
                          title: Text(c.name),
                          onTap: () => Navigator.of(context).pop(c),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
      ],
    );
  }
}

class _AssignStartDateResult {
  const _AssignStartDateResult._({
    required this.cancelled,
    required this.startDate,
  });

  const _AssignStartDateResult.cancelled()
    : this._(cancelled: true, startDate: null);
  const _AssignStartDateResult.confirmed(DateTime? startDate)
    : this._(cancelled: false, startDate: startDate);

  final bool cancelled;
  final DateTime? startDate;
}

class _AssignStartDateDialog extends StatefulWidget {
  const _AssignStartDateDialog();

  @override
  State<_AssignStartDateDialog> createState() => _AssignStartDateDialogState();
}

class _AssignStartDateDialogState extends State<_AssignStartDateDialog> {
  DateTime? _selectedStartDate;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial =
        _selectedStartDate ?? DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 10, 12, 31),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedStartDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final materialL10n = MaterialLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.workoutTemplatesAssignStartDate),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(
              _selectedStartDate == null
                  ? l10n.workoutTemplatesAssignStartDateHint
                  : materialL10n.formatFullDate(_selectedStartDate!),
            ),
            trailing: _selectedStartDate == null
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: l10n.workoutFollowUpStartDateClear,
                    onPressed: () => setState(() => _selectedStartDate = null),
                  ),
            onTap: _pickDate,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(const _AssignStartDateResult.cancelled()),
          child: Text(materialL10n.cancelButtonLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(const _AssignStartDateResult.confirmed(null)),
          child: Text(l10n.workoutTemplatesAssignStartDateSkip),
        ),
        FilledButton(
          onPressed: _selectedStartDate == null
              ? null
              : () => Navigator.of(
                  context,
                ).pop(_AssignStartDateResult.confirmed(_selectedStartDate)),
          child: Text(l10n.workoutTemplatesAssign),
        ),
      ],
    );
  }
}

class TemplatePreviewWeek {
  const TemplatePreviewWeek({required this.name, required this.days});

  final String name;
  final List<TemplatePreviewDay> days;
}

class TemplatePreviewDay {
  const TemplatePreviewDay({
    required this.name,
    required this.exercises,
    required this.remainingExercises,
  });

  final String name;
  final List<String> exercises;
  final int remainingExercises;
}

List<TemplatePreviewWeek> parseTemplatePreviewWeeks(
  String planData, {
  int maxWeeks = 5,
  int maxExercisesPerDay = 3,
}) {
  try {
    final decoded = jsonDecode(planData);
    if (decoded is! Map<String, dynamic>) return const [];
    final rawWeeks = decoded['weeks'];
    if (rawWeeks is! List) return const [];

    final weeks = <TemplatePreviewWeek>[];
    final safeWeekCount = rawWeeks.length < maxWeeks
        ? rawWeeks.length
        : maxWeeks;

    for (var weekIndex = 0; weekIndex < safeWeekCount; weekIndex++) {
      final weekMap = rawWeeks[weekIndex];
      if (weekMap is! Map) continue;
      final weekNameRaw = weekMap['name']?.toString().trim();
      final weekName = (weekNameRaw == null || weekNameRaw.isEmpty)
          ? 'Week ${weekIndex + 1}'
          : weekNameRaw;

      final rawDays = weekMap['days'];
      final days = <TemplatePreviewDay>[];
      if (rawDays is List) {
        for (var dayIndex = 0; dayIndex < rawDays.length; dayIndex++) {
          final dayMap = rawDays[dayIndex];
          if (dayMap is! Map) continue;
          final dayNameRaw = dayMap['name']?.toString().trim();
          final dayName = (dayNameRaw == null || dayNameRaw.isEmpty)
              ? 'Day ${dayIndex + 1}'
              : dayNameRaw;

          final rawExercises = dayMap['exercises'];
          final exerciseNames = <String>[];
          var remaining = 0;
          if (rawExercises is List) {
            final takeCount = rawExercises.length < maxExercisesPerDay
                ? rawExercises.length
                : maxExercisesPerDay;
            for (var i = 0; i < takeCount; i++) {
              final exercise = rawExercises[i];
              if (exercise is! Map) continue;
              final name = exercise['name']?.toString().trim();
              if (name != null && name.isNotEmpty) {
                exerciseNames.add(name);
              }
            }
            remaining = rawExercises.length - takeCount;
          }

          days.add(
            TemplatePreviewDay(
              name: dayName,
              exercises: exerciseNames,
              remainingExercises: remaining < 0 ? 0 : remaining,
            ),
          );
        }
      }

      weeks.add(TemplatePreviewWeek(name: weekName, days: days));
    }

    return weeks;
  } catch (_) {
    return const [];
  }
}
