import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/routing/auth_route_loading.dart';
import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

import '../../data/customer_repository.dart';
import '../../data/models/customer.dart';
import '../customer_list_contacts_import.dart';
import '../customer_list_filter.dart';
import '../customer_list_metrics.dart';
import '../widgets/customer_list_upgrade_banner.dart';
import '../widgets/customer_list_app_bar.dart';
import '../widgets/customer_list_empty_body.dart';
import '../widgets/customer_list_error_body.dart';
import '../widgets/customer_list_metrics_bar.dart';
import '../widgets/customer_list_populated_body.dart';
import '../widgets/customer_list_toolbar.dart';

/// Customer list – empty state (Stitch empty dark) or populated list.
class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final CustomerRepository _repo = CustomerRepository();
  List<Customer> _customers = [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  CustomerListStatusFilter _statusFilter = CustomerListStatusFilter.all;
  CustomerListSort _sort = CustomerListSort.recent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final customers = await _repo.getAll();
      if (mounted) {
        setState(() {
          _customers = customers;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
          _customers = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authLoading = authRouteLoadingOrNull();
    if (authLoading != null) return authLoading;

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final activeCount = _customers.where((c) => !c.isArchived).length;
    final showToolbar = !_loading && _error == null;
    final showMetrics = showToolbar && _customers.isNotEmpty;
    final metrics =
        showMetrics ? computeCustomerListMetrics(_customers) : null;

    return Scaffold(
      backgroundColor: MarketingDarkColors.bgAlt,
      appBar: CustomerListAppBar(title: l10n.customersTitle),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomerListUpgradeBanner(activeCustomerCount: activeCount),
          if (metrics != null) CustomerListMetricsBar(metrics: metrics),
          if (showToolbar)
            CustomerListToolbar(
              customers: _customers,
              searchQuery: _searchQuery,
              statusFilter: _statusFilter,
              sort: _sort,
              onSearchChanged: (v) => setState(() => _searchQuery = v),
              onStatusFilterSelected: (f) =>
                  setState(() => _statusFilter = f),
              onSortChanged: (s) => setState(() => _sort = s),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              color: MarketingDarkColors.brandLight,
              backgroundColor: MarketingDarkColors.surface,
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: MarketingDarkColors.brandLight,
                      ),
                    )
                  : _error != null
                      ? CustomerListErrorBody(
                          l10n: l10n,
                          theme: theme,
                          colorScheme: colorScheme,
                          error: _error,
                          onRetry: _load,
                        )
                      : _customers.isEmpty
                          ? CustomerListEmptyBody(
                              l10n: l10n,
                              onImportFromContacts: () =>
                                  importCustomerFromContacts(context),
                            )
                          : CustomerListPopulatedBody(
                              theme: theme,
                              colorScheme: colorScheme,
                              customers: _customers,
                              searchQuery: _searchQuery,
                              statusFilter: _statusFilter,
                              sort: _sort,
                            ),
            ),
          ),
        ],
      ),
    );
  }
}
