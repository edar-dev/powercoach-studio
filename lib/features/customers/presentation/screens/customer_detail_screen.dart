import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/routing/auth_route_loading.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/customer_detail_measurements_tab.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/customer_detail_overview_tab.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/customer_detail_records_tab.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/customer_reminder_sheet.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../domain/customer_progress_metrics.dart';
import '../../data/customer_repository.dart';
import '../../data/customer_exercise_record_repository.dart';
import '../../data/customer_notes_repository.dart';
import '../../data/customer_measurement_repository.dart';
import '../../data/models/customer.dart';
import '../../data/models/customer_measurement.dart';
import '../../data/models/customer_exercise_record.dart';
import '../../../exercise_library/data/custom_exercise_item.dart';
import '../../../exercise_library/data/custom_exercise_repository.dart';
import '../../../workouts/data/workout_plan_api_model.dart';
import '../../../workouts/data/workout_plan_repository.dart';
import '../../../workouts/domain/session_execution_service.dart';
import '../../../workouts/domain/workout_plan_list_helpers.dart';

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
  final CustomerNotesRepository _notesRepo = CustomerNotesRepository();
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
  CustomerProgressSnapshot? _progressSnapshot;
  bool _progressLoading = false;
  final SessionExecutionService _executionService = SessionExecutionService();
  int _unreadNotesCount = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    SupabaseBootstrap.refreshTick.addListener(_onAuthRefresh);
    _load();
  }

  @override
  void dispose() {
    SupabaseBootstrap.refreshTick.removeListener(_onAuthRefresh);
    _tabController.dispose();
    super.dispose();
  }

  void _onAuthRefresh() {
    if (!SupabaseBootstrap.authReady || SupabaseBootstrap.currentUser == null) {
      return;
    }
    if (_customer != null || _error != null) return;
    _load();
  }

  void _openWorkoutEditor({String? planId}) {
    navigateTo(
      context,
      customerWorkoutEditorPath(widget.customerId, planId: planId),
    );
  }

  Future<void> _loadWorkoutPlans() async {
    setState(() => _workoutPlansLoading = true);
    try {
      final list = await _planRepo.getByCustomerId(widget.customerId);
      if (mounted) {
        setState(() {
          _workoutPlans = sortWorkoutPlans(list, WorkoutPlanSort.startDateDesc);
          _workoutPlansLoading = false;
        });
        _loadProgress();
      }
    } catch (_) {
      if (mounted) setState(() => _workoutPlansLoading = false);
    }
  }

  Future<void> _loadUnreadNotes() async {
    try {
      final count = await _notesRepo.unreadCount(widget.customerId);
      if (mounted) {
        setState(() => _unreadNotesCount = count);
      }
    } catch (_) {}
  }

  Future<void> _openNotes(Customer customer) async {
    final name = customer.name.trim();
    final uri = name.isEmpty
        ? '/customers/${widget.customerId}/notes'
        : '/customers/${widget.customerId}/notes?customerName=${Uri.encodeComponent(name)}';
    await context.push(uri);
    if (mounted) {
      await _loadUnreadNotes();
    }
  }

  void _openMeasurementHistory(Customer customer) {
    final name = customer.name.trim();
    final uri = name.isEmpty
        ? '/customers/${widget.customerId}/measurements/history'
        : '/customers/${widget.customerId}/measurements/history?customerName=${Uri.encodeComponent(name)}';
    navigateTo(context, uri);
  }

  Future<void> _loadMeasurements() async {
    setState(() => _measurementsLoading = true);
    try {
      final list = await _measurementRepo.getByCustomerId(widget.customerId);
      if (mounted) {
        list.sort((a, b) => b.measurementDate.compareTo(a.measurementDate));
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
        _loadProgress();
      }
    } catch (_) {
      if (mounted) setState(() => _recordsLoading = false);
    }
  }

  Future<void> _loadProgress() async {
    setState(() => _progressLoading = true);
    try {
      final allExecutions = await _executionService.listAll();
      if (!mounted) return;
      setState(() {
        _progressSnapshot = CustomerProgressMetrics.build(
          customerId: widget.customerId,
          plans: _workoutPlans,
          exerciseRecords: _records,
          allExecutions: allExecutions,
        );
        _progressLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _progressLoading = false);
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

  Future<void> _load() async {
    if (!SupabaseBootstrap.authReady) return;
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
        _loadUnreadNotes();
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
    final authLoading = authRouteLoadingOrNull();
    if (authLoading != null) return authLoading;

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
            navigateBack(context, fallback: '/customers');
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
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: Text(l10n.customerNotesOpen),
                      trailing: _unreadNotesCount > 0
                          ? Badge(label: Text('$_unreadNotesCount'))
                          : null,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _openNotes(c);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.alarm_add_outlined),
                      title: Text(l10n.customerReminderAction),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        showCustomerReminderComposer(
                          context,
                          customerId: c.id,
                          customerName: c.name,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(l10n.customerEdit),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        navigateTo(context, '/customers/${c.id}/edit');
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
            CustomerDetailOverviewTab(
              customer: c,
              customerId: widget.customerId,
              goalLabel: goalLabel,
              measurements: _measurements,
              measurementsLoading: _measurementsLoading,
              progressSnapshot: _progressSnapshot,
              progressLoading: _progressLoading,
              workoutPlans: _workoutPlans,
              workoutPlansLoading: _workoutPlansLoading,
              onAssignWorkout: _openWorkoutEditor,
              onOpenMeasurementHistory: () => _openMeasurementHistory(c),
              onReloadMeasurements: _loadMeasurements,
              onReloadWorkoutPlans: _loadWorkoutPlans,
            ),
            CustomerDetailMeasurementsTab(
              customerId: widget.customerId,
              measurements: _measurements,
              loading: _measurementsLoading,
              measurementRepo: _measurementRepo,
              onReload: _loadMeasurements,
              customerName: c.name,
            ),
            CustomerDetailRecordsTab(
              customerId: widget.customerId,
              records: _records,
              exerciseNameById: _exerciseNameById,
              loading: _recordsLoading,
              recordRepo: _recordRepo,
              onReload: _loadRecords,
            ),
          ],
        ),
      ),
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
          navigateBack(context, fallback: '/customers');
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
}
