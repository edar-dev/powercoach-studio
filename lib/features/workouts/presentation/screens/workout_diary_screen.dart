import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../../customers/data/customer_repository.dart';
import '../../../customers/data/models/customer.dart';
import '../../../dashboard/domain/plan_calendar_event.dart';
import '../../domain/session_execution_service.dart';
import '../../domain/workout_diary_filter.dart';

const _diaryPageSize = 50;

/// Chronological list of logged training sessions across clients.
class WorkoutDiaryScreen extends StatefulWidget {
  const WorkoutDiaryScreen({super.key});

  @override
  State<WorkoutDiaryScreen> createState() => _WorkoutDiaryScreenState();
}

class _WorkoutDiaryScreenState extends State<WorkoutDiaryScreen> {
  final SessionExecutionService _executionService = SessionExecutionService();
  final CustomerRepository _customerRepo = CustomerRepository();
  final ScrollController _scrollController = ScrollController();

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  String? _loadError;
  List<SessionExecutionEntry> _entries = const [];
  List<Customer> _customers = const [];
  String? _filterCustomerId;
  String? _filterPlanId;
  String? _filterSessionKey;
  DiaryDateRange _dateRange = DiaryDateRange.all;
  DiaryStatusFilter _statusFilter = DiaryStatusFilter.all;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final params = GoRouterState.of(context).uri.queryParameters;
      final customerId = params['customerId'];
      if (customerId != null && customerId.isNotEmpty) {
        _filterCustomerId = customerId;
      }
      final planId = params['planId'];
      if (planId != null && planId.isNotEmpty) {
        _filterPlanId = planId;
      }
      final sessionKey = params['sessionKey'];
      if (sessionKey != null && sessionKey.isNotEmpty) {
        _filterSessionKey = sessionKey;
      }
      _load(reset: true);
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore || _loading) return;
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    _loadMore();
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _loadError = null;
        _entries = const [];
        _hasMore = false;
      });
    }
    try {
      final page = await _executionService.listEntries(
        planId: _filterPlanId,
        customerId: _filterCustomerId,
        sessionKey: _filterSessionKey,
        limit: _diaryPageSize,
        offset: 0,
      );
      final customers = await _customerRepo.getAll();
      if (!mounted) return;
      setState(() {
        _entries = page.entries;
        _customers = customers;
        _loading = false;
        _loadError = null;
        _hasMore = page.hasMore;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _entries = const [];
        _loading = false;
        _loadError = AppLocalizations.of(context).workoutDiaryLoadError;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final page = await _executionService.listEntries(
        planId: _filterPlanId,
        customerId: _filterCustomerId,
        sessionKey: _filterSessionKey,
        limit: _diaryPageSize,
        offset: _entries.length,
      );
      if (!mounted) return;
      setState(() {
        _entries = [..._entries, ...page.entries];
        _hasMore = page.hasMore;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  String _customerName(String customerId) {
    for (final c in _customers) {
      if (c.id == customerId) return c.name.trim().isEmpty ? customerId : c.name;
    }
    return customerId;
  }

  List<SessionExecutionEntry> get _visibleEntries => filterDiaryEntries(
        _entries,
        customerId: _filterCustomerId,
        planId: _filterPlanId,
        sessionKey: _filterSessionKey,
        dateRange: _dateRange,
        statusFilter: _statusFilter,
      );

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
    setState(() => _filterCustomerId = selected.isEmpty ? null : selected);
    await _load(reset: true);
  }

  void _openEntry(SessionExecutionEntry entry) {
    HapticFeedback.selectionClick();
    navigateTo(
      context,
      workoutDiaryEntryPath(
        planId: entry.planId,
        sessionKey: entry.execution.sessionKey,
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
    final hasSessionFilter =
        _filterSessionKey != null && _filterSessionKey!.isNotEmpty;

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
          : _loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: cs.error),
                    const SizedBox(height: 16),
                    Text(
                      _loadError!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => _load(reset: true),
                      child: Text(l10n.customersRetry),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasSessionFilter)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Material(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.filter_alt_outlined),
                        title: Text(l10n.workoutDiarySessionFilterActive),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() => _filterSessionKey = null);
                            _load(reset: true);
                          },
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.workoutDiaryFilterDate,
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<DiaryDateRange>(
                        segments: [
                          ButtonSegment(
                            value: DiaryDateRange.last7,
                            label: Text(l10n.coachStatsPeriod7d),
                          ),
                          ButtonSegment(
                            value: DiaryDateRange.last30,
                            label: Text(l10n.coachStatsPeriod30d),
                          ),
                          ButtonSegment(
                            value: DiaryDateRange.all,
                            label: Text(l10n.workoutDiaryFilterDateAll),
                          ),
                        ],
                        selected: {_dateRange},
                        onSelectionChanged: (values) {
                          if (values.isEmpty) return;
                          setState(() => _dateRange = values.first);
                        },
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: Text(l10n.workoutDiaryFilterStatusAll),
                            selected: _statusFilter == DiaryStatusFilter.all,
                            onSelected: (_) => setState(
                              () => _statusFilter = DiaryStatusFilter.all,
                            ),
                          ),
                          FilterChip(
                            label: Text(l10n.sessionCompleted),
                            selected:
                                _statusFilter == DiaryStatusFilter.completed,
                            onSelected: (_) => setState(
                              () => _statusFilter = DiaryStatusFilter.completed,
                            ),
                          ),
                          FilterChip(
                            label: Text(l10n.sessionSkipped),
                            selected:
                                _statusFilter == DiaryStatusFilter.skipped,
                            onSelected: (_) => setState(
                              () => _statusFilter = DiaryStatusFilter.skipped,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: visible.isEmpty
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
                          onRefresh: () => _load(reset: true),
                          child: ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                            itemCount: visible.length + (_loadingMore ? 1 : 0),
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              if (index >= visible.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final entry = visible[index];
                              final execution = entry.execution;
                              final date =
                                  execution.completedAt ?? execution.sessionDate;
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
                                  borderRadius:
                                      BorderRadius.circular(StitchM3Theme.radiusLg),
                                ),
                                child: ListTile(
                                  onTap: () => _openEntry(entry),
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
                                    color: isSkipped
                                        ? cs.outline
                                        : StitchM3Theme.success,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
