import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/data/customer_repository.dart';
import '../../domain/session_execution_service.dart';
import '../widgets/workout_diary_entry_body.dart';

/// Full-screen diary entry with deep links to plan and schedule.
class WorkoutDiaryEntryScreen extends StatefulWidget {
  const WorkoutDiaryEntryScreen({
    super.key,
    required this.planId,
    required this.sessionKey,
  });

  final String planId;
  final String sessionKey;

  @override
  State<WorkoutDiaryEntryScreen> createState() => _WorkoutDiaryEntryScreenState();
}

class _WorkoutDiaryEntryScreenState extends State<WorkoutDiaryEntryScreen> {
  final SessionExecutionService _executionService = SessionExecutionService();
  final CustomerRepository _customerRepo = CustomerRepository();

  bool _loading = true;
  SessionExecutionEntry? _entry;
  String _customerName = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final entry = await _executionService.getEntry(
        planId: widget.planId,
        sessionKey: widget.sessionKey,
      );
      var customerName = entry?.customerId ?? '';
      if (entry != null) {
        final customer = await _customerRepo.getById(entry.customerId);
        if (customer != null && customer.name.trim().isNotEmpty) {
          customerName = customer.name;
        }
      }
      if (!mounted) return;
      setState(() {
        _entry = entry;
        _customerName = customerName;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _entry = null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final entry = _entry;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(l10n.workoutDiaryDetailTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : entry == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.workoutDiaryEntryNotFound,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  Text(
                    _customerName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.planName,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'W${entry.execution.weekIndex + 1} D${entry.execution.dayIndex + 1} · '
                    '${diaryEntryStatusLabel(l10n, entry.execution.status)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.yMMMd(
                      Localizations.localeOf(context).toString(),
                    ).format(
                      entry.execution.completedAt ??
                          entry.execution.sessionDate,
                    ),
                  ),
                  const SizedBox(height: 24),
                  WorkoutDiaryEntryBody(
                    execution: entry.execution,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      navigateTo(
                        context,
                        customerWorkoutEditorPath(
                          entry.customerId,
                          planId: entry.planId,
                          weekIndex: entry.execution.weekIndex,
                          dayIndex: entry.execution.dayIndex,
                        ),
                      );
                    },
                    icon: const Icon(Icons.fitness_center_outlined),
                    label: Text(l10n.workoutDiaryOpenPlan),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      navigateTo(
                        context,
                        scheduleSessionDetailPath(
                          customerId: entry.customerId,
                          planId: entry.planId,
                          weekIndex: entry.execution.weekIndex,
                          dayIndex: entry.execution.dayIndex,
                          date: entry.execution.sessionDate,
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(l10n.workoutDiaryOpenSession),
                  ),
                ],
              ),
            ),
    );
  }
}
