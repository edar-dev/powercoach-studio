import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/customers/data/models/customer.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_exercise_record.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_measurement.dart';
import 'package:powercoach_studio/features/customers/domain/customer_overview_metrics.dart';
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
    required this.exerciseRecords,
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
  final List<CustomerExerciseRecord> exerciseRecords;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                    child: Icon(
                      Icons.person,
                      size: 64,
                      color: StitchM3Theme.accent.withValues(alpha: 0.6),
                    ),
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
                customer.name,
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
                      onPressed: () =>
                          navigateTo(context, '/customers/$customerId/edit'),
                      icon: const Icon(Icons.edit, size: 20),
                      label: Text(l10n.customerEditProfile),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        foregroundColor: colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(StitchM3Theme.radiusLg),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => onAssignWorkout(),
                      icon: const Icon(Icons.add_task, size: 20),
                      label: Text(l10n.customerAssignWorkout),
                      style: FilledButton.styleFrom(
                        backgroundColor: StitchM3Theme.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 2,
                        shadowColor: StitchM3Theme.accent.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(StitchM3Theme.radiusLg),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          CustomerOverviewMetricsPanel(
            snapshot: CustomerOverviewMetrics.build(
              customer: customer,
              measurements: measurements,
              muscleMassLabel: l10n.customerMuscleMass,
              bodyFatLabel: l10n.measurementBodyFat,
            ),
            loading: measurementsLoading,
            onAddMeasurement: () async {
              final added = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (ctx) =>
                      CustomerMeasurementFormScreen(customerId: customerId),
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
                  recentPrs: [],
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

  Future<void> _exportProgress(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
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
          exerciseRecords: exerciseRecords,
        ),
      ),
    );
  }
}
