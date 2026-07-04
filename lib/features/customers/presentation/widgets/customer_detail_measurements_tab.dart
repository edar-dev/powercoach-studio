import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import 'package:powercoach_studio/core/ui/widgets/app_snackbar.dart';
import 'package:powercoach_studio/features/customers/data/customer_measurement_repository.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_measurement.dart';
import 'package:powercoach_studio/features/customers/presentation/screens/customer_measurement_form_screen.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

class CustomerDetailMeasurementsTab extends StatelessWidget {
  const CustomerDetailMeasurementsTab({
    super.key,
    required this.customerId,
    required this.measurements,
    required this.loading,
    required this.measurementRepo,
    required this.onReload,
    this.customerName,
  });

  final String customerId;
  final List<CustomerMeasurement> measurements;
  final bool loading;
  final CustomerMeasurementRepository measurementRepo;
  final VoidCallback onReload;
  final String? customerName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (measurements.isEmpty) {
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
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.measurementsEmptyHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _openForm(context),
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
          padding: const EdgeInsets.fromLTRB(16, 72, 16, 80),
          itemCount: measurements.length,
          itemBuilder: (context, index) {
            final m = measurements[index];
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
                subtitle: summary.isEmpty
                    ? null
                    : Text(summary, style: theme.textTheme.bodySmall),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final updated = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (ctx) => CustomerMeasurementFormScreen(
                        customerId: customerId,
                        measurement: m,
                      ),
                    ),
                  );
                  if (updated == true) onReload();
                },
                onLongPress: () => _confirmDelete(context, m),
              ),
            );
          },
        ),
        Positioned(
          top: 8,
          left: 16,
          right: 16,
          child: Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () {
                final name = customerName?.trim();
                final uri = name == null || name.isEmpty
                    ? '/customers/$customerId/measurements/history'
                    : '/customers/$customerId/measurements/history?customerName=${Uri.encodeComponent(name)}';
                navigateTo(context, uri);
              },
              icon: const Icon(Icons.show_chart),
              label: Text(l10n.measurementHistoryOpen),
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _openForm(context),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Future<void> _openForm(BuildContext context) async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (ctx) => CustomerMeasurementFormScreen(customerId: customerId),
      ),
    );
    if (added == true) onReload();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CustomerMeasurement measurement,
  ) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
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
      await measurementRepo.delete(customerId, measurement.id);
      if (!context.mounted) return;
      showAppSnackBar(context, content: Text(l10n.measurementDeleted));
      onReload();
    } catch (_) {
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        content: Text(l10n.measurementDeleteError),
        backgroundColor: colorScheme.errorContainer,
      );
    }
  }
}
