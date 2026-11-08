import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/export/export_share.dart';
import '../../../../core/routing/app_navigation.dart';
import '../../../../core/routing/app_paths.dart';
import '../../../../core/routing/hub_chrome.dart';
import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../core/ui/haptics.dart';
import '../../../../core/ui/widgets/app_snackbar.dart';
import '../../../../core/ui/widgets/inline_error_banner.dart';
import '../../../../core/ui/widgets/list_skeleton.dart';
import '../../../../core/ui/widgets/shell_utility_actions.dart';
import '../../../../core/ui/widgets/stitch_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/data/customer_repository.dart';
import '../../../customers/data/models/customer.dart';
import '../../domain/session_execution_service.dart';
import '../../domain/workout_diary_export_service.dart';
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
    final phone = !Breakpoints.isTabletOrWider(context);
    final selected = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: phone
          ? StitchMobileColors.surfaceContainer
          : MarketingDarkColors.stitchCard,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                l10n.workoutDiaryFilterAll,
                style: TextStyle(
                  color: phone
                      ? StitchMobileColors.onSurface
                      : MarketingDarkColors.text,
                ),
              ),
              trailing: _filterCustomerId == null
                  ? Icon(
                      Icons.check,
                      color: phone
                          ? StitchMobileColors.primary
                          : MarketingDarkColors.cyanBright,
                    )
                  : null,
              onTap: () => Navigator.of(ctx).pop(''),
            ),
            ..._customers.map(
              (c) => ListTile(
                title: Text(
                  c.name,
                  style: TextStyle(
                    color: phone
                        ? StitchMobileColors.onSurface
                        : MarketingDarkColors.text,
                  ),
                ),
                trailing: _filterCustomerId == c.id
                    ? Icon(
                        Icons.check,
                        color: phone
                            ? StitchMobileColors.primary
                            : MarketingDarkColors.cyanBright,
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
    AppHaptics.selection();
    navigateTo(
      context,
      workoutDiaryEntryPath(
        planId: entry.planId,
        sessionKey: entry.execution.sessionKey,
      ),
    );
  }

  void _recordSession() {
    AppHaptics.selection();
    navigateTo(context, AppPaths.calendar);
  }

  Future<void> _exportVisible() async {
    final l10n = AppLocalizations.of(context);
    final visible = _visibleEntries;
    await AppHaptics.selection();
    try {
      final artifact = await exportWorkoutDiaryToCsv(
        entries: visible,
        customerNameOf: _customerName,
      );
      await downloadExportArtifact(artifact);
      if (!mounted) return;
      showAppSnackBar(
        context,
        content: Text(l10n.workoutDiaryExportSuccess),
      );
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
      if (!mounted) return;
      showAppSnackBar(
        context,
        content: Text(l10n.workoutDiaryExportFailed),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      );
    }
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
    final phone = !Breakpoints.isTabletOrWider(context);
    final slimHub = primaryShellUsesRail(context);

    return Scaffold(
      backgroundColor: hubPageBackground(context),
      // Page H1 lives in [WorkoutDiaryHeader] — avoid a second "Storico" bar.
      appBar: StitchAppBar(
        title: l10n.workoutDiaryDesktopTitle,
        showLogo: !slimHub,
        showTitle: false,
        actions: slimHub
            ? null
            : phoneHubUtilityActions(includeSettings: true),
      ),
      body: SafeArea(
        child: _loading
            ? const CardListSkeleton(rowCount: 5)
            : _loadError != null
            ? Center(
                child: InlineErrorBanner(
                  message: _loadError!,
                  onRetry: () => _load(reset: true),
                  retryLabel: l10n.customersRetry,
                ),
              )
            : RefreshIndicator(
                color: Theme.of(context).colorScheme.primary,
                onRefresh: () => _load(reset: true),
                child: CustomScrollView(
                  key: const PageStorageKey<String>('workout-diary-scroll'),
                  restorationId: 'workout-diary-scroll',
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        StitchMobileColors.marginMobile,
                        12,
                        StitchMobileColors.marginMobile,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: WorkoutDiaryHeader(
                          onRecord: _recordSession,
                          onExport: _exportVisible,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        StitchMobileColors.marginMobile,
                        phone ? 8 : 12,
                        StitchMobileColors.marginMobile,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: WorkoutDiaryKpiRow(kpis: kpis),
                      ),
                    ),
                    if (hasSessionFilter)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          StitchMobileColors.marginMobile,
                          12,
                          StitchMobileColors.marginMobile,
                          0,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Material(
                            color: phone
                                ? StitchMobileColors.surfaceContainer
                                : MarketingDarkColors.stitchCard,
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.filter_alt_outlined,
                                color: phone
                                    ? StitchMobileColors.primary
                                    : MarketingDarkColors.cyanBright,
                              ),
                              title: Text(
                                l10n.workoutDiarySessionFilterActive,
                                style: TextStyle(
                                  color: phone
                                      ? StitchMobileColors.onSurface
                                      : MarketingDarkColors.text,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: phone
                                      ? StitchMobileColors.onSurfaceVariant
                                      : MarketingDarkColors.slate400,
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
                      padding: EdgeInsets.fromLTRB(
                        StitchMobileColors.marginMobile,
                        phone ? 8 : 12,
                        StitchMobileColors.marginMobile,
                        0,
                      ),
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
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                          child: Column(
                            children: [
                              const Spacer(),
                              Text(
                                l10n.workoutDiaryEmpty,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: phone
                                      ? StitchMobileColors.onSurfaceVariant
                                      : MarketingDarkColors.slate400,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _recordSession,
                                  icon: const Icon(Icons.add, size: 18),
                                  label: Text(l10n.workoutDiaryRecordAction),
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(0, 48),
                                    backgroundColor: phone
                                        ? StitchMobileColors.primaryContainer
                                        : MarketingDarkColors.cyanBright,
                                    foregroundColor: phone
                                        ? StitchMobileColors.onPrimaryContainer
                                        : MarketingDarkColors.cyanOn,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...WorkoutDiaryTimeline.buildSlivers(
                        context: context,
                        groups: groups,
                        dateFormat: dateFormat,
                        customerNameOf: _customerName,
                        onOpenEntry: _openEntry,
                        loadingMore: _loadingMore,
                        padding: EdgeInsets.fromLTRB(
                          StitchMobileColors.marginMobile,
                          phone ? 12 : 14,
                          StitchMobileColors.marginMobile,
                          phone ? 32 : 24,
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
