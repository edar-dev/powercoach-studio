import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:powercoach_studio/core/billing/plan_gate.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import 'package:powercoach_studio/features/customers/data/models/customer.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_exercise_record.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_measurement.dart';
import 'package:powercoach_studio/features/customers/domain/customer_overview_metrics.dart';
import 'package:powercoach_studio/features/customers/domain/customer_progress_export_labels_l10n.dart';
import 'package:powercoach_studio/features/customers/domain/customer_progress_export_service.dart';
import 'package:powercoach_studio/features/customers/domain/customer_progress_metrics.dart';
import 'package:powercoach_studio/features/customers/presentation/customer_list_filter.dart';
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
    final locale = Localizations.localeOf(context).toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AthleteHeroCard(
            customer: customer,
            goalLabel: goalLabel,
            progressSnapshot: progressSnapshot,
            l10n: l10n,
            locale: locale,
            onAssignWorkout: () => onAssignWorkout(),
            onEditProfile: () =>
                navigateTo(context, '/customers/$customerId/edit'),
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
          exerciseRecords: exerciseRecords,
          labels: l10n.toCustomerProgressExportLabels(),
        ),
      ),
    );
  }
}

class _AthleteHeroCard extends StatelessWidget {
  const _AthleteHeroCard({
    required this.customer,
    required this.goalLabel,
    required this.progressSnapshot,
    required this.l10n,
    required this.locale,
    required this.onAssignWorkout,
    required this.onEditProfile,
  });

  final Customer customer;
  final String goalLabel;
  final CustomerProgressSnapshot? progressSnapshot;
  final AppLocalizations l10n;
  final String locale;
  final VoidCallback onAssignWorkout;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final age = customerAgeYears(customer.dateOfBirth);
    final dob = customer.dateOfBirth != null
        ? DateTime.tryParse(customer.dateOfBirth!)
        : null;
    final email = customer.email?.trim();
    final phone = customer.phone?.trim();
    final lastCheckIn = progressSnapshot?.lastSessionDate;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D1629),
            Color(0xFF0F1B32),
            Color(0xFF0C1426),
          ],
        ),
        borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl),
        border: Border.all(color: const Color(0xFF1B2A45)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 560;
              final identity = _IdentityBlock(
                customer: customer,
                goalLabel: goalLabel,
                age: age,
                dob: dob,
                email: email,
                phone: phone,
                lastCheckIn: lastCheckIn,
                l10n: l10n,
                locale: locale,
              );
              final actions = _HeroActions(
                l10n: l10n,
                onAssignWorkout: onAssignWorkout,
                onEditProfile: onEditProfile,
              );
              if (stacked) {
                return Column(
                  children: [
                    identity,
                    const SizedBox(height: 20),
                    actions,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: identity),
                  const SizedBox(width: 20),
                  SizedBox(width: 220, child: actions),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IdentityBlock extends StatelessWidget {
  const _IdentityBlock({
    required this.customer,
    required this.goalLabel,
    required this.age,
    required this.dob,
    required this.email,
    required this.phone,
    required this.lastCheckIn,
    required this.l10n,
    required this.locale,
  });

  final Customer customer;
  final String goalLabel;
  final int? age;
  final DateTime? dob;
  final String? email;
  final String? phone;
  final DateTime? lastCheckIn;
  final AppLocalizations l10n;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDBEAFE), Color(0xFFBFDBFE)],
                    ),
                    border: Border.all(
                      color: const Color(0xFF1B2B48),
                      width: 4,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    customerInitials(customer.name),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: MarketingDarkColors.brand,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0D1629),
                        width: 2,
                      ),
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: MarketingDarkColors.text,
                        ),
                      ),
                      if (goalLabel.trim().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF172554).withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0xFF1E40AF).withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.flag_outlined,
                                size: 14,
                                color: MarketingDarkColors.brandLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${l10n.customerGoalLabel}: $goalLabel',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: MarketingDarkColors.brandLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      if (age != null && dob != null)
                        _MetaIconText(
                          icon: Icons.calendar_today_outlined,
                          text: l10n.customerAgeWithDob(
                            age!,
                            DateFormat.yMMMd(locale).format(dob!),
                          ),
                        ),
                      if (email != null && email!.isNotEmpty)
                        _MetaIconText(
                          icon: Icons.mail_outline,
                          text: email!,
                        ),
                      if (phone != null && phone!.isNotEmpty)
                        _MetaIconText(
                          icon: Icons.phone_outlined,
                          text: phone!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        label: l10n.customerJourneyStart,
                        value: DateFormat.yMMMd(locale).format(customer.createdAt),
                      ),
                      if (lastCheckIn != null)
                        _MetaChip(
                          label: l10n.customerLastCheckIn,
                          value: DateFormat.yMMMd(locale).format(lastCheckIn!),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetaIconText extends StatelessWidget {
  const _MetaIconText({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: MarketingDarkColors.slate500),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: MarketingDarkColors.slate400,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF090F1D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1B2940)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: MarketingDarkColors.slate500,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 11,
                color: MarketingDarkColors.slate300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroActions extends StatelessWidget {
  const _HeroActions({
    required this.l10n,
    required this.onAssignWorkout,
    required this.onEditProfile,
  });

  final AppLocalizations l10n;
  final VoidCallback onAssignWorkout;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onAssignWorkout,
          icon: const Icon(Icons.calendar_month_outlined, size: 18),
          label: Text(l10n.customerAssignWorkout),
          style: FilledButton.styleFrom(
            backgroundColor: MarketingDarkColors.brand,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onEditProfile,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(l10n.customerEditProfile),
          style: OutlinedButton.styleFrom(
            foregroundColor: MarketingDarkColors.slate300,
            side: const BorderSide(color: Color(0xFF233352)),
            backgroundColor: const Color(0xFF131C30),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
            ),
          ),
        ),
      ],
    );
  }
}
