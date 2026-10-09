import 'dart:async';

import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/routing/auth_route_loading.dart';
import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import 'package:powercoach_studio/core/ui/widgets/cloud_save_feedback.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

import '../../data/customer_measurement_repository.dart';
import '../../data/models/customer.dart';
import '../../data/models/customer_measurement.dart';
import '../../domain/customer_progress_metrics.dart';
import '../../../workouts/data/workout_plan_api_model.dart';
import '../customer_detail_data_loader.dart';
import '../customer_detail_delete_handler.dart';
import '../customer_detail_navigation.dart';
import '../widgets/customer_detail_app_bars.dart';
import '../widgets/customer_detail_error_body.dart';
import '../widgets/customer_detail_measurements_tab.dart';
import '../widgets/customer_detail_overview_tab.dart';
import '../widgets/customer_new_workout_sheet.dart';
import '../widgets/customer_workout_plans_body.dart';

/// Customer Detail Page – Stitch screen ID 7a7f3b47bfa1435381554959ca9b72e7.
class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen>
    with SingleTickerProviderStateMixin {
  final CustomerDetailDataLoader _loader = CustomerDetailDataLoader();
  final CustomerMeasurementRepository _measurementRepo =
      CustomerMeasurementRepository();

  Customer? _customer;
  bool _loading = true;
  String? _error;
  List<CustomerMeasurement> _measurements = [];
  bool _measurementsLoading = false;
  List<WorkoutPlanApiModel> _workoutPlans = [];
  bool _workoutPlansLoading = false;
  CustomerProgressSnapshot? _progressSnapshot;
  bool _progressLoading = false;
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

  Future<void> _loadWorkoutPlans() async {
    setState(() => _workoutPlansLoading = true);
    try {
      final list = await _loader.loadWorkoutPlans(widget.customerId);
      if (mounted) {
        setState(() {
          _workoutPlans = list;
          _workoutPlansLoading = false;
        });
        unawaited(_loadProgress());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _workoutPlansLoading = false);
      final l10n = AppLocalizations.of(context);
      showCloudSaveErrorSnackBar(
        context,
        e,
        fallbackMessage: l10n.workoutPlansLoadError,
      );
    }
  }

  Future<void> _loadUnreadNotes() async {
    try {
      final count = await _loader.loadUnreadNotesCount(widget.customerId);
      if (mounted) {
        setState(() => _unreadNotesCount = count);
      }
    } catch (_) {}
  }

  Future<void> _loadMeasurements() async {
    setState(() => _measurementsLoading = true);
    try {
      final list = await _loader.loadMeasurements(widget.customerId);
      if (mounted) {
        setState(() {
          _measurements = list;
          _measurementsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _measurementsLoading = false);
    }
  }

  Future<void> _loadProgress() async {
    setState(() => _progressLoading = true);
    try {
      final snapshot = await _loader.loadProgress(
        customerId: widget.customerId,
        plans: _workoutPlans,
      );
      if (!mounted) return;
      setState(() {
        _progressSnapshot = snapshot;
        _progressLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _progressLoading = false);
    }
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
      final data = await _loader.loadCustomer(widget.customerId);
      if (mounted) {
        setState(() {
          _customer = data;
          _loading = false;
          _error = null;
        });
        unawaited(_loadMeasurements());
        unawaited(_loadWorkoutPlans());
        unawaited(_loadUnreadNotes());
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

  @override
  Widget build(BuildContext context) {
    final authLoading = authRouteLoadingOrNull();
    if (authLoading != null) return authLoading;

    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return Scaffold(
        backgroundColor: MarketingDarkColors.bgAlt,
        appBar: CustomerDetailFallbackAppBar(title: l10n.customersTitle),
        body: const Center(
          child: CircularProgressIndicator(
            color: MarketingDarkColors.brandLight,
          ),
        ),
      );
    }

    if (_error != null || _customer == null) {
      return Scaffold(
        backgroundColor: MarketingDarkColors.bgAlt,
        appBar: CustomerDetailFallbackAppBar(title: l10n.customersTitle),
        body: CustomerDetailErrorBody(l10n: l10n, errorMessage: _error),
      );
    }

    final c = _customer!;
    final goalLabel = c.goals ?? '';

    return Scaffold(
      backgroundColor: MarketingDarkColors.bgAlt,
      appBar: CustomerDetailLoadedAppBar(
        l10n: l10n,
        tabController: _tabController,
        customer: c,
        unreadNotesCount: _unreadNotesCount,
        onOpenNotes: () => openCustomerDetailNotes(
          context: context,
          customerId: widget.customerId,
          customerName: c.name,
          onReturn: _loadUnreadNotes,
        ),
        onEdit: () => navigateTo(context, '/customers/${c.id}/edit'),
        onDelete: () => deleteCustomerDetail(
          context: context,
          customerId: widget.customerId,
        ),
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
              onAssignWorkout: ({String? planId}) {
                if (planId != null) {
                  openCustomerWorkoutEditor(
                    context: context,
                    customerId: widget.customerId,
                    planId: planId,
                  );
                  return;
                }
                showCustomerNewWorkoutSheet(
                  context,
                  customerId: widget.customerId,
                );
              },
              onOpenMeasurementHistory: () => openCustomerMeasurementHistory(
                context: context,
                customerId: widget.customerId,
                customerName: c.name,
              ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: CustomerWorkoutPlansBody(
                customerId: widget.customerId,
                embeddedInTab: true,
                onPlansChanged: _loadWorkoutPlans,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
