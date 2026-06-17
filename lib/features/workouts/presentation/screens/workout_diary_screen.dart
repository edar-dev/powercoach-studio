import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../../customers/data/customer_repository.dart';
import '../../../customers/data/models/customer.dart';
import '../../../dashboard/domain/plan_calendar_event.dart';
import '../../domain/session_execution_service.dart';

/// Chronological list of logged training sessions across clients.
class WorkoutDiaryScreen extends StatefulWidget {
  const WorkoutDiaryScreen({super.key});

  @override
  State<WorkoutDiaryScreen> createState() => _WorkoutDiaryScreenState();
}

class _WorkoutDiaryScreenState extends State<WorkoutDiaryScreen> {
  final SessionExecutionService _executionService = SessionExecutionService();
  final CustomerRepository _customerRepo = CustomerRepository();

  bool _loading = true;
  List<SessionExecutionEntry> _entries = const [];
  List<Customer> _customers = const [];
  String? _filterCustomerId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final entries = await _executionService.listAll();
      final customers = await _customerRepo.getAll();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _customers = customers;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _entries = const [];
        _loading = false;
      });
    }
  }

  String _customerName(String customerId) {
    for (final c in _customers) {
      if (c.id == customerId) return c.name.trim().isEmpty ? customerId : c.name;
    }
    return customerId;
  }

  List<SessionExecutionEntry> get _visibleEntries {
    if (_filterCustomerId == null) return _entries;
    return _entries
        .where((e) => e.customerId == _filterCustomerId)
        .toList();
  }

  Future<void> _showCustomerFilter(AppLocalizations l10n) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.workoutDiaryFilterAll),
              trailing: _filterCustomerId == null ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(ctx).pop(''),
            ),
            ..._customers.map(
              (c) => ListTile(
                title: Text(c.name),
                trailing: _filterCustomerId == c.id
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(ctx).pop(c.id),
              ),
            ),
          ],
        ),
      ),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _filterCustomerId = selected.isEmpty ? null : selected;
    });
  }

  Future<void> _showEntryDetail(
    BuildContext context,
    SessionExecutionEntry entry,
    AppLocalizations l10n,
  ) async {
    final execution = entry.execution;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${entry.planName} · W${execution.weekIndex + 1} D${execution.dayIndex + 1}',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              if (execution.notes.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(execution.notes),
              ],
              if (execution.exercises.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.sessionLogExercisesLabel,
                  style: Theme.of(ctx).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...execution.exercises.map(
                  (e) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      e.completed
                          ? Icons.check_circle_outline
                          : Icons.radio_button_unchecked,
                    ),
                    title: Text(e.name),
                    subtitle: e.sets.isEmpty
                        ? null
                        : Text(
                            e.sets
                                .map((s) => '${s.reps} ${s.load}'.trim())
                                .join(' · '),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final visible = _visibleEntries;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(l10n.workoutDiaryTitle),
        actions: [
          IconButton(
            tooltip: l10n.workoutDiaryFilterAll,
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showCustomerFilter(l10n),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : visible.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.workoutDiaryEmpty,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: visible.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final entry = visible[index];
                  final execution = entry.execution;
                  final date = execution.completedAt ?? execution.sessionDate;
                  final completedCount = execution.exercises
                      .where((e) => e.completed)
                      .length;
                  final totalExercises = execution.exercises.isEmpty
                      ? null
                      : execution.exercises.length;
                  final isSkipped =
                      execution.status == PlanSessionStatus.skipped;

                  return Card(
                    elevation: 0,
                    color: cs.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                    ),
                    child: ListTile(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _showEntryDetail(context, entry, l10n);
                      },
                      title: Text(
                        '${dateFormat.format(date)} · ${_customerName(entry.customerId)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        isSkipped
                            ? '${entry.planName} · ${l10n.sessionSkipped}'
                            : totalExercises == null
                            ? entry.planName
                            : '${entry.planName} · $completedCount/$totalExercises',
                      ),
                      trailing: Icon(
                        isSkipped
                            ? Icons.remove_circle_outline
                            : Icons.check_circle_outline,
                        color: isSkipped ? cs.outline : StitchM3Theme.success,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
