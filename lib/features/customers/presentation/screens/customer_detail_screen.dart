import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/app_snackbar.dart';
import '../../../../widgets/app_sheet.dart';
import '../../data/customer_repository.dart';
import '../../data/customer_exercise_record_repository.dart';
import '../../data/customer_measurement_repository.dart';
import '../../data/models/customer.dart';
import '../../data/models/customer_measurement.dart';
import '../../data/models/customer_exercise_record.dart';
import '../../../exercise_library/data/custom_exercise_item.dart';
import '../../../exercise_library/data/custom_exercise_repository.dart';
import '../../../workouts/data/workout_plan_api_model.dart';
import '../../../workouts/data/workout_plan_repository.dart';
import '../../../workouts/data/workout_routine_model.dart';
import 'customer_measurement_form_screen.dart';
import 'customer_exercise_record_form_screen.dart';

/// Customer Detail Page – Stitch screen ID 7a7f3b47bfa1435381554959ca9b72e7.
class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> with SingleTickerProviderStateMixin {
  final CustomerRepository _customerRepo = CustomerRepository();
  final CustomerMeasurementRepository _measurementRepo = CustomerMeasurementRepository();
  final CustomerExerciseRecordRepository _recordRepo = CustomerExerciseRecordRepository();
  final CustomExerciseRepository _exerciseRepo = CustomExerciseRepository();
  final WorkoutPlanRepository _planRepo = WorkoutPlanRepository();
  Customer? _customer;
  bool _loading = true;
  String? _error;
  List<CustomerMeasurement> _measurements = [];
  bool _measurementsLoading = false;
  List<CustomerExerciseRecord> _records = [];
  Map<String, String> _exerciseNameById = <String, String>{};
  bool _recordsLoading = false;
  List<WorkoutPlanApiModel> _workoutPlans = [];
  bool _workoutPlansLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkoutPlans() async {
    setState(() => _workoutPlansLoading = true);
    try {
      final list = await _planRepo.getByCustomerId(widget.customerId);
      if (mounted) {
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        setState(() {
          _workoutPlans = list;
          _workoutPlansLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _workoutPlansLoading = false);
    }
  }

  Future<void> _loadMeasurements() async {
    setState(() => _measurementsLoading = true);
    try {
      final list = await _measurementRepo.getByCustomerId(widget.customerId);
      if (mounted) {
        setState(() {
          _measurements = list;
          _measurementsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _measurementsLoading = false);
      }
    }
  }

  Future<void> _loadRecords() async {
    setState(() => _recordsLoading = true);
    try {
      final list = await _recordRepo.getByCustomerId(widget.customerId);
      final exerciseNameById = await _buildExerciseNameMap();
      if (mounted) {
        setState(() {
          _records = list;
          _exerciseNameById = exerciseNameById;
          _recordsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _recordsLoading = false);
    }
  }

  Future<Map<String, String>> _buildExerciseNameMap() async {
    final roots = await _exerciseRepo.getTree();
    final namesById = <String, String>{};
    void visit(CustomExerciseItem node, String? parentPath) {
      final displayName =
          parentPath == null ? node.name : '$parentPath › ${node.name}';
      namesById[node.id] = displayName;
      for (final child in node.children) {
        visit(child, displayName);
      }
    }

    for (final root in roots) {
      visit(root, null);
    }
    return namesById;
  }

  String _resolveRecordDisplayName(CustomerExerciseRecord record) {
    final fromRecord = record.displayName.trim();
    if (fromRecord.isNotEmpty && fromRecord != record.customExerciseId) {
      return fromRecord;
    }
    final fromMap = _exerciseNameById[record.customExerciseId];
    if (fromMap != null && fromMap.trim().isNotEmpty) return fromMap;
    return fromRecord.isEmpty ? record.customExerciseId : fromRecord;
  }

  Future<void> _load() async {
    final user = SupabaseBootstrap.currentUser;
    if (user == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _customerRepo.getById(widget.customerId);
      if (mounted) {
        setState(() {
          _customer = data;
          _loading = false;
          _error = null;
        });
        _loadMeasurements();
        _loadRecords();
        _loadWorkoutPlans();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: l10n.customerDeleteConfirmTitle,
      message: l10n.customerDeleteConfirmMessage,
      confirmLabel: l10n.customerDelete,
      cancelLabel: l10n.customerCancel,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    try {
      await _customerRepo.delete(widget.customerId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.customerDeletedMessage,
            style: TextStyle(color: colorScheme.onPrimaryContainer),
          ),
          backgroundColor: colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/customers');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.customerDeleteError,
            style: TextStyle(color: colorScheme.onErrorContainer),
          ),
          backgroundColor: colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseBootstrap.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return Scaffold(
        appBar: _detailAppBar(context, theme, l10n.customersTitle),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _customer == null) {
      return Scaffold(
        appBar: _detailAppBar(context, theme, l10n.customersTitle),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  _error ?? l10n.customersLoadError,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: Text(l10n.customerCancel),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final c = _customer!;
    final goalLabel = c.goals ?? '';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.pop();
          },
        ),
        title: Text(
          l10n.customerDetailTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: l10n.customerDetailOverview),
                  Tab(text: l10n.customerDetailMeasurements),
                  Tab(text: l10n.customerDetailRecords),
                ],
              ),
              Container(color: colorScheme.outline, height: 1),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
            onPressed: () {
              // More menu: edit / delete
              showAppBottomSheet<void>(
                context: context,
                title: l10n.actionsTitle,
                bodyBuilder: (sheetContext) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(l10n.customerEdit),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        context.push('/customers/${c.id}/edit');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.delete_outline, color: colorScheme.error),
                      title: Text(l10n.customerDelete, style: TextStyle(color: colorScheme.error)),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _delete();
                      },
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(context, c, theme, colorScheme, goalLabel),
            _buildMeasurementsTab(context, theme, colorScheme),
            _buildRecordsTab(context, theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    Customer c,
    ThemeData theme,
    ColorScheme colorScheme,
    String goalLabel,
  ) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile section (Stitch)
              Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: StitchM3Theme.accentLight,
                          border: Border.all(
                            color: StitchM3Theme.accent.withValues(alpha: 0.25),
                            width: 4,
                          ),
                        ),
                        child: Icon(Icons.person, size: 64, color: StitchM3Theme.accent.withValues(alpha: 0.6)),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: StitchM3Theme.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.surface, width: 2),
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    c.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (goalLabel.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: StitchM3Theme.accentLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${l10n.customerGoalLabel}: $goalLabel',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: StitchM3Theme.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/customers/${c.id}/edit'),
                          icon: const Icon(Icons.edit, size: 20),
                          label: Text(l10n.customerEditProfile),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            foregroundColor: colorScheme.onSurface,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => context.push('/workouts/editor?customerId=${c.id}'),
                          icon: const Icon(Icons.add_task, size: 20),
                          label: Text(l10n.customerAssignWorkout),
                          style: FilledButton.styleFrom(
                            backgroundColor: StitchM3Theme.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 2,
                            shadowColor: StitchM3Theme.accent.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Stats grid
              Row(
                children: [
                  Expanded(
                    child: _statCard(context, l10n.customerCurrentWeight, c.weightKg != null ? '${c.weightKg}' : '—', 'kg', '+1.2%'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _statCard(context, l10n.customerMuscleMass, '—', 'kg', '+0.5%'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Workout plans – in evidenza
              _buildWorkoutPlansSection(context, c, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildMeasurementsTab(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);
    if (_measurementsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_measurements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.straighten, size: 48, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                l10n.measurementsEmpty,
                style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.measurementsEmptyHint,
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () async {
                  final added = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (ctx) => CustomerMeasurementFormScreen(customerId: widget.customerId),
                    ),
                  );
                  if (added == true) _loadMeasurements();
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.measurementAdd),
              ),
            ],
          ),
        ),
      );
    }
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: _measurements.length,
          itemBuilder: (context, index) {
            final m = _measurements[index];
            final dateStr = CustomerMeasurement.toDateString(m.measurementDate);
            final summary = [
              if (m.squat1RM != null) 'S ${m.squat1RM}',
              if (m.benchPress1RM != null) 'B ${m.benchPress1RM}',
              if (m.deadlift1RM != null) 'D ${m.deadlift1RM}',
              if (m.bodyFatPercent != null) 'BF ${m.bodyFatPercent}%',
            ].join(' · ');
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(dateStr, style: theme.textTheme.titleMedium),
                subtitle: summary.isEmpty ? null : Text(summary, style: theme.textTheme.bodySmall),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final updated = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (ctx) => CustomerMeasurementFormScreen(
                        customerId: widget.customerId,
                        measurement: m,
                      ),
                    ),
                  );
                  if (updated == true) _loadMeasurements();
                },
                onLongPress: () async {
                  final confirm = await showAppConfirmDialog(
                    context: context,
                    title: l10n.measurementDeleteConfirm,
                    message: '',
                    confirmLabel: l10n.customerDelete,
                    cancelLabel: l10n.customerCancel,
                    destructive: true,
                  );
                  if (!confirm || !context.mounted) return;
                  try {
                    await _measurementRepo.delete(widget.customerId, m.id);
                    if (!context.mounted) return;
                    showAppSnackBar(context, content: Text(l10n.measurementDeleted));
                    _loadMeasurements();
                  } catch (_) {
                    if (!context.mounted) return;
                    showAppSnackBar(
                      context,
                      content: Text(l10n.measurementDeleteError),
                      backgroundColor: colorScheme.errorContainer,
                    );
                  }
                },
              ),
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () async {
              final added = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (ctx) => CustomerMeasurementFormScreen(customerId: widget.customerId),
                ),
              );
              if (added == true) _loadMeasurements();
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsTab(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);
    if (_recordsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fitness_center, size: 48, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                l10n.recordsEmpty,
                style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.recordsEmptyHint,
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () async {
                  final added = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (ctx) => CustomerExerciseRecordFormScreen(customerId: widget.customerId),
                    ),
                  );
                  if (added == true) _loadRecords();
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.recordAdd),
              ),
            ],
          ),
        ),
      );
    }
    // Group by resolved exercise display name.
    final grouped = <String, List<CustomerExerciseRecord>>{};
    for (final r in _records) {
      final key = _resolveRecordDisplayName(r);
      grouped.putIfAbsent(key, () => []).add(r);
    }
    for (final list in grouped.values) {
      list.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    }
    final sortedGroupKeys = grouped.keys.toList()..sort();

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: sortedGroupKeys.length,
          itemBuilder: (context, index) {
            final exerciseKey = sortedGroupKeys[index];
            final list = grouped[exerciseKey]!;
            final first = list.first;
            final exerciseName = _resolveRecordDisplayName(first);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exerciseName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final added = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (ctx) => CustomerExerciseRecordFormScreen(
                                  customerId: widget.customerId,
                                  initialCustomExerciseId: first.customExerciseId,
                                ),
                              ),
                            );
                            if (added == true) _loadRecords();
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(l10n.recordAddUpdate),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...list.map(
                      (r) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${r.value} ${r.unit}',
                          style: theme.textTheme.bodyLarge,
                        ),
                        subtitle: Text(
                          '${r.recordedAt.year}-${r.recordedAt.month.toString().padLeft(2, '0')}-${r.recordedAt.day.toString().padLeft(2, '0')}${r.note != null && r.note!.isNotEmpty ? ' · ${r.note}' : ''}',
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final updated = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (ctx) => CustomerExerciseRecordFormScreen(
                                customerId: widget.customerId,
                                record: r,
                              ),
                            ),
                          );
                          if (updated == true) _loadRecords();
                        },
                        onLongPress: () async {
                          final confirm = await showAppConfirmDialog(
                            context: context,
                            title: l10n.recordDeleteConfirm,
                            message: '',
                            confirmLabel: l10n.customerDelete,
                            cancelLabel: l10n.customerCancel,
                            destructive: true,
                          );
                          if (!confirm || !context.mounted) return;
                          try {
                            await _recordRepo.delete(widget.customerId, r.id);
                            if (!context.mounted) return;
                            showAppSnackBar(context, content: Text(l10n.recordDeleted));
                            _loadRecords();
                          } catch (_) {
                            if (!context.mounted) return;
                            showAppSnackBar(
                              context,
                              content: Text(l10n.recordDeleteError),
                              backgroundColor: colorScheme.errorContainer,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () async {
              final added = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (ctx) => CustomerExerciseRecordFormScreen(customerId: widget.customerId),
                ),
              );
              if (added == true) _loadRecords();
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _detailAppBar(BuildContext context, ThemeData theme, String title) {
    final cs = theme.colorScheme;
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.pop();
        },
      ),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: cs.outline, height: 1),
      ),
    );
  }

  Widget _statCard(BuildContext context, String label, String value, String unit, String trend) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusXl),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.trending_up, size: 14, color: StitchM3Theme.success),
              const SizedBox(width: 4),
              Text(
                trend,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: StitchM3Theme.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutPlansSection(
    BuildContext context,
    Customer c,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final l10n = AppLocalizations.of(context);
    const int maxRecent = 5;
    final recentPlans = _workoutPlans.take(maxRecent).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusXl),
        border: Border.all(color: StitchM3Theme.accent.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: StitchM3Theme.accent.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: StitchM3Theme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                ),
                child: Icon(Icons.fitness_center, color: StitchM3Theme.accent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.customerWorkoutPlans,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (_workoutPlans.isNotEmpty)
                TextButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    context.push('/customers/${widget.customerId}/workouts').then((_) {
                      if (mounted) _loadWorkoutPlans();
                    });
                  },
                  child: Text(l10n.customerViewAll, style: TextStyle(color: StitchM3Theme.accent, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_workoutPlansLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else if (_workoutPlans.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Text(
                    l10n.customerNoWorkoutPlansYet,
                    style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      context.push('/workouts/editor?customerId=${c.id}').then((_) {
                        if (mounted) _loadWorkoutPlans();
                      });
                    },
                    icon: const Icon(Icons.add_task, size: 20),
                    label: Text(l10n.customerAssignWorkout),
                    style: FilledButton.styleFrom(
                      backgroundColor: StitchM3Theme.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ],
              ),
            )
          else
            ...recentPlans.asMap().entries.map((e) {
              final plan = e.value;
              final isLast = e.key == recentPlans.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      context.push('/workouts/editor/${plan.id}?customerId=${widget.customerId}').then((_) {
                        if (mounted) _loadWorkoutPlans();
                      });
                    },
                    borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.name.isNotEmpty ? plan.name : l10n.customerUnnamedPlan,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatPlanUpdated(l10n, plan.updatedAt),
                                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant, size: 24),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 0),
                            onSelected: (value) {
                              HapticFeedback.mediumImpact();
                              if (value == 'follow_up') {
                                _createFollowUpWorkout(plan);
                              } else if (value == 'delete') {
                                _deletePlan(plan);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'follow_up',
                                child: Text(AppLocalizations.of(context).workoutCreateNewFromThis),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(AppLocalizations.of(context).workoutDelete),
                              ),
                            ],
                          ),
                          Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant, size: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  static String _formatPlanUpdated(AppLocalizations l10n, DateTime updatedAt) {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);
    if (diff.inDays > 0) return l10n.updatedDaysAgo(diff.inDays);
    if (diff.inHours > 0) return l10n.updatedHoursAgo(diff.inHours);
    if (diff.inMinutes > 0) return l10n.updatedMinutesAgo(diff.inMinutes);
    return l10n.updatedJustNow;
  }

  Future<void> _createFollowUpWorkout(WorkoutPlanApiModel plan) async {
    final l10n = AppLocalizations.of(context);
    try {
      final routine = planDataToRoutine(plan.planData);
      final numWeeks = routine.weeks.isEmpty ? 1 : routine.weeks.length;
      final newStartingWeek = plan.initialWeekNumber + numWeeks;
      final emptyPlanData = jsonEncode(WorkoutRoutine.empty().toJson());
      await _planRepo.create(
        customerId: widget.customerId,
        name: l10n.workoutNewPlanName,
        planDataJson: emptyPlanData,
        initialWeekNumber: newStartingWeek,
      );
      if (!mounted) return;
      _loadWorkoutPlans();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutDuplicatedMessage),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  Future<void> _deletePlan(WorkoutPlanApiModel plan) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: l10n.workoutDeleteConfirmTitle,
      message: l10n.workoutDeleteConfirmMessage,
      confirmLabel: l10n.customerDelete,
      cancelLabel: l10n.customerCancel,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await _planRepo.delete(plan.id);
      if (!mounted) return;
      _loadWorkoutPlans();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutDeletedMessage),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    } catch (e) {
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
}
