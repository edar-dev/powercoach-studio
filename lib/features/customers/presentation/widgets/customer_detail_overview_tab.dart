import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/billing/plan_gate.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import 'package:powercoach_studio/features/customers/data/models/customer.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_measurement.dart';
import 'package:powercoach_studio/features/customers/domain/customer_overview_metrics.dart';
import 'package:powercoach_studio/features/customers/domain/customer_progress_export_labels_l10n.dart';
import 'package:powercoach_studio/features/customers/domain/customer_progress_export_service.dart';
import 'package:powercoach_studio/features/customers/domain/customer_progress_metrics.dart';
import 'package:powercoach_studio/features/customers/presentation/customer_progress_export.dart';
import 'package:powercoach_studio/features/customers/presentation/screens/customer_measurement_form_screen.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/customer_detail_workout_plans_section.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/customer_overview_metrics_panel.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/customer_progress_panel.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

class CustomerDetailOverviewTab extends StatelessWidget {
  const CustomerDetailOverviewTab({
    super.key,
    required this.customer,
    required this.customerId,
    required this.goalLabel,
    required this.measurements,
    required this.measurementsLoading,
    required this.progressSnapshot,
    required this.progressLoading,
    required this.workoutPlans,
    required this.workoutPlansLoading,
    required this.onAssignWorkout,
    required this.onOpenMeasurementHistory,
    required this.onReloadMeasurements,
    required this.onReloadWorkoutPlans,
  });

  final Customer customer;
  final String customerId;
  final String goalLabel;
  final List<CustomerMeasurement> measurements;
  final bool measurementsLoading;
  final CustomerProgressSnapshot? progressSnapshot;
  final bool progressLoading;
  final List<WorkoutPlanApiModel> workoutPlans;
  final bool workoutPlansLoading;
  final void Function({String? planId}) onAssignWorkout;
  final VoidCallback onOpenMeasurementHistory;
  final VoidCallback onReloadMeasurements;
  final VoidCallback onReloadWorkoutPlans;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomerOverviewMetricsPanel(
            snapshot: CustomerOverviewMetrics.build(
              customer: customer,
              measurements: measurements,
              muscleMassLabel: l10n.customerMuscleMass,
              bodyFatLabel: l10n.measurementBodyFat,
            ),
            loading: measurementsLoading,
            onAddMeasurement: () async {
              final previous = _previousForNew(measurements);
              final added = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (ctx) => CustomerMeasurementFormScreen(
                    customerId: customerId,
                    customerName: customer.name,
                    previousMeasurement: previous,
                  ),
                ),
              );
              if (added == true) onReloadMeasurements();
            },
            onViewHistory: onOpenMeasurementHistory,
          ),
          const SizedBox(height: 24),
          CustomerProgressPanel(
            snapshot: progressSnapshot ??
                const CustomerProgressSnapshot(
                  adherencePercent: null,
                  completedSessions30d: 0,
                  skippedSessions30d: 0,
                  lastSessionDate: null,
                  last4Weeks: [],
                  hasAnyData: false,
                ),
            loading: progressLoading,
            onExport: _canExportProgress
                ? () => _exportProgress(context, l10n)
                : null,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => navigateTo(
                context,
                workoutDiaryPath(customerId: customerId),
              ),
              icon: const Icon(Icons.menu_book_outlined, size: 18),
              label: Text(l10n.customerOpenDiary),
              style: OutlinedButton.styleFrom(
                foregroundColor: MarketingDarkColors.slate300,
                side: const BorderSide(color: MarketingDarkColors.borderMuted),
                backgroundColor: MarketingDarkColors.surfaceElevated,
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomerDetailWorkoutPlansSection(
            customerId: customerId,
            plans: workoutPlans,
            loading: workoutPlansLoading,
            onOpenEditor: onAssignWorkout,
            onPlansChanged: onReloadWorkoutPlans,
          ),
        ],
      ),
    );
  }

  bool get _canExportProgress {
    final snapshot = progressSnapshot;
    if (snapshot == null || progressLoading) return false;
    return snapshot.hasAnyData || measurements.isNotEmpty;
  }

  CustomerMeasurement? _previousForNew(List<CustomerMeasurement> list) {
    if (list.isEmpty) return null;
    final sorted = List<CustomerMeasurement>.from(list)
      ..sort((a, b) => b.measurementDate.compareTo(a.measurementDate));
    return sorted.first;
  }

  Future<void> _exportProgress(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    if (!await PlanGate.requirePro(context, feature: PaywallFeature.exportProgress)) {
      return;
    }
    if (!context.mounted) return;

    final snapshot = progressSnapshot;
    if (snapshot == null) return;

    await shareCustomerProgressExport(
      context: context,
      l10n: l10n,
      export: () => exportCustomerProgressToCsv(
        CustomerProgressExportInput(
          customerName: customer.name,
          progress: snapshot,
          measurements: measurements,
          overview: CustomerOverviewMetrics.build(
            customer: customer,
            measurements: measurements,
            muscleMassLabel: l10n.customerMuscleMass,
            bodyFatLabel: l10n.measurementBodyFat,
          ),
          labels: l10n.toCustomerProgressExportLabels(),
        ),
      ),
    );
  }
}
