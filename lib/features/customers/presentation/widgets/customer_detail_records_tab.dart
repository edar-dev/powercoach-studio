import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import 'package:powercoach_studio/core/ui/widgets/app_snackbar.dart';
import 'package:powercoach_studio/features/customers/data/customer_exercise_record_repository.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_exercise_record.dart';
import 'package:powercoach_studio/features/customers/presentation/screens/customer_exercise_record_form_screen.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

class CustomerDetailRecordsTab extends StatelessWidget {
  const CustomerDetailRecordsTab({
    super.key,
    required this.customerId,
    required this.records,
    required this.exerciseNameById,
    required this.loading,
    required this.recordRepo,
    required this.onReload,
  });

  final String customerId;
  final List<CustomerExerciseRecord> records;
  final Map<String, String> exerciseNameById;
  final bool loading;
  final CustomerExerciseRecordRepository recordRepo;
  final VoidCallback onReload;

  String _resolveRecordDisplayName(CustomerExerciseRecord record) {
    final fromRecord = record.displayName.trim();
    if (fromRecord.isNotEmpty && fromRecord != record.customExerciseId) {
      return fromRecord;
    }
    final fromMap = exerciseNameById[record.customExerciseId];
    if (fromMap != null && fromMap.trim().isNotEmpty) return fromMap;
    return fromRecord.isEmpty ? record.customExerciseId : fromRecord;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (records.isEmpty) {
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
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.recordsEmptyHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _openForm(context),
                icon: const Icon(Icons.add),
                label: Text(l10n.recordAdd),
              ),
            ],
          ),
        ),
      );
    }

    final grouped = <String, List<CustomerExerciseRecord>>{};
    for (final r in records) {
      grouped.putIfAbsent(_resolveRecordDisplayName(r), () => []).add(r);
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
                                  customerId: customerId,
                                  initialCustomExerciseId: first.customExerciseId,
                                ),
                              ),
                            );
                            if (added == true) onReload();
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
                                customerId: customerId,
                                record: r,
                              ),
                            ),
                          );
                          if (updated == true) onReload();
                        },
                        onLongPress: () => _confirmDelete(context, r),
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
        builder: (ctx) => CustomerExerciseRecordFormScreen(customerId: customerId),
      ),
    );
    if (added == true) onReload();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CustomerExerciseRecord record,
  ) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
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
      await recordRepo.delete(customerId, record.id);
      if (!context.mounted) return;
      showAppSnackBar(context, content: Text(l10n.recordDeleted));
      onReload();
    } catch (_) {
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        content: Text(l10n.recordDeleteError),
        backgroundColor: colorScheme.errorContainer,
      );
    }
  }
}
