import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/routing/auth_route_loading.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

import '../../data/customer_repository.dart';
import '../../data/models/customer.dart';
import '../customer_list_contacts_import.dart';
import '../widgets/customer_list_upgrade_banner.dart';
import '../widgets/customer_list_app_bar.dart';
import '../widgets/customer_list_empty_body.dart';
import '../widgets/customer_list_error_body.dart';
import '../widgets/customer_list_populated_body.dart';

/// Customer list – empty state (Stitch Empty Customer List) or populated (Stitch Customer List Populated).
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
  int _filterChipIndex = 0;

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

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: CustomerListAppBar(title: l10n.customersTitle),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomerListUpgradeBanner(activeCustomerCount: activeCount),
          Expanded(
            child: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
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
                theme: theme,
                colorScheme: colorScheme,
                onImportFromContacts: () => importCustomerFromContacts(context),
              )
            : CustomerListPopulatedBody(
                theme: theme,
                colorScheme: colorScheme,
                customers: _customers,
                searchQuery: _searchQuery,
                filterChipIndex: _filterChipIndex,
                onSearchChanged: (v) => setState(() => _searchQuery = v),
                onFilterChipSelected: (i) =>
                    setState(() => _filterChipIndex = i),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _error == null
          ? FloatingActionButton.extended(
              onPressed: () => navigateTo(context, '/customers/new'),
              icon: const Icon(Icons.add),
              label: Text(
                _customers.isEmpty
                    ? l10n.customersAddFirstClient
                    : l10n.customersAddCustomer,
              ),
              backgroundColor: _customers.isEmpty
                  ? StitchM3Theme.accent
                  : StitchM3Theme.accentLight,
              foregroundColor:
                  _customers.isEmpty ? Colors.white : StitchM3Theme.accent,
              elevation: _customers.isEmpty ? 4 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
              ),
            )
          : null,
    );
  }
}
