import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/data/customer_repository.dart';
import '../../../customers/data/models/customer.dart';
import '../../domain/session_execution_service.dart';
import '../../domain/workout_diary_filter.dart';
import '../../domain/workout_diary_metrics.dart';
import '../widgets/workout_diary_filters_bar.dart';
import '../widgets/workout_diary_header.dart';
import '../widgets/workout_diary_kpi_row.dart';
import '../widgets/workout_diary_timeline.dart';

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
      backgroundColor: MarketingDarkColors.stitchCard,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                l10n.workoutDiaryFilterAll,
                style: const TextStyle(color: MarketingDarkColors.text),
              ),
              trailing: _filterCustomerId == null
                  ? const Icon(
                      Icons.check,
                      color: MarketingDarkColors.cyanBright,
                    )
                  : null,
              onTap: () => Navigator.of(ctx).pop(''),
            ),
            ..._customers.map(
              (c) => ListTile(
                title: Text(
                  c.name,
                  style: const TextStyle(color: MarketingDarkColors.text),
                ),
                trailing: _filterCustomerId == c.id
                    ? const Icon(
                        Icons.check,
                        color: MarketingDarkColors.cyanBright,
                      )
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

  void _recordSession() {
    HapticFeedback.selectionClick();
    navigateTo(context, '/dashboard/calendar');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMMMd(locale);
    final visible = _visibleEntries;
    final hasSessionFilter =
        _filterSessionKey != null && _filterSessionKey!.isNotEmpty;
    final kpis = computeDiaryKpis(visible);
    final groups = groupDiaryEntriesByDay(visible);

    return Scaffold(
      backgroundColor: MarketingDarkColors.stitchPageBgAlt,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: MarketingDarkColors.cyanBright,
                ),
              )
            : _loadError != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Color(0xFFFB7185),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _loadError!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: MarketingDarkColors.slate400,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: MarketingDarkColors.cyanBright,
                          foregroundColor: MarketingDarkColors.cyanOn,
                        ),
                        onPressed: () => _load(reset: true),
                        child: Text(l10n.customersRetry),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                color: MarketingDarkColors.cyanBright,
                onRefresh: () => _load(reset: true),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: WorkoutDiaryHeader(onRecord: _recordSession),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: WorkoutDiaryKpiRow(kpis: kpis),
                      ),
                    ),
                    if (hasSessionFilter)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        sliver: SliverToBoxAdapter(
                          child: Material(
                            color: MarketingDarkColors.stitchCard,
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              dense: true,
                              leading: const Icon(
                                Icons.filter_alt_outlined,
                                color: MarketingDarkColors.cyanBright,
                              ),
                              title: Text(
                                l10n.workoutDiarySessionFilterActive,
                                style: const TextStyle(
                                  color: MarketingDarkColors.text,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: MarketingDarkColors.slate400,
                                ),
                                onPressed: () {
                                  setState(() => _filterSessionKey = null);
                                  _load(reset: true);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: WorkoutDiaryFiltersBar(
                          dateRange: _dateRange,
                          statusFilter: _statusFilter,
                          customers: _customers,
                          filterCustomerId: _filterCustomerId,
                          visibleCount: visible.length,
                          onDateRangeChanged: (value) {
                            setState(() => _dateRange = value);
                          },
                          onStatusChanged: (value) {
                            setState(() => _statusFilter = value);
                          },
                          onAthleteTap: () => _showCustomerFilter(l10n),
                        ),
                      ),
                    ),
                    if (visible.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              l10n.workoutDiaryEmpty,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: MarketingDarkColors.slate400,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        sliver: SliverToBoxAdapter(
                          child: WorkoutDiaryTimeline(
                            groups: groups,
                            dateFormat: dateFormat,
                            customerNameOf: _customerName,
                            onOpenEntry: _openEntry,
                            loadingMore: _loadingMore,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
