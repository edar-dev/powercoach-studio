import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/gymblog_api_client.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/customer.dart';

/// Customer list – empty state (Stitch Empty Customer List) or populated (Stitch Customer List Populated).
class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final GymBlogApiClient _api = GymBlogApiClient();
  List<Customer> _customers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!GymBlogApiClient.isConfigured) {
      setState(() {
        _loading = false;
        _error = null;
        _customers = [];
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _api.getList('/api/customers');
      final customers = list
          .whereType<Map<String, dynamic>>()
          .map((e) => Customer.fromJson(e))
          .toList();
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
          _error = e is GymBlogApiException ? e.message : e.toString();
          _customers = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!GymBlogApiClient.isConfigured) {
      return Scaffold(
        backgroundColor: AppTheme.bgSecondary,
        appBar: _customerListAppBar(context, theme, l10n.customersTitle),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.customersApiNotConfigured,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgSecondary,
      appBar: _customerListAppBar(context, theme, l10n.customersTitle),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _errorBody(context, l10n, theme, colorScheme)
                : _customers.isEmpty
                    ? _emptyBody(context, l10n, theme, colorScheme)
                    : _listBody(context, l10n, theme, colorScheme),
      ),
      floatingActionButton: GymBlogApiClient.isConfigured && _error == null
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/customers/new'),
              icon: const Icon(Icons.add),
              label: Text(l10n.customersAddCustomer),
            )
          : null,
    );
  }

  Widget _errorBody(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  l10n.customersLoadError,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _load,
                  child: Text(l10n.customersRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyBody(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 80,
                  color: colorScheme.outline,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.customersEmptyTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.customersEmptyMessage,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => context.push('/customers/new'),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.customersAddCustomer),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listBody(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _customers.length,
      itemBuilder: (context, index) {
        final c = _customers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(c.name),
            subtitle: Text(
              [
                if (c.email != null && c.email!.isNotEmpty) c.email!,
                if (c.phone != null && c.phone!.isNotEmpty) c.phone!,
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/customers/${c.id}'),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _customerListAppBar(
    BuildContext context,
    ThemeData theme,
    String title,
  ) {
    return AppBar(
      backgroundColor: AppTheme.bg,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black26,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.pop();
        },
      ),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppTheme.border, height: 1),
      ),
    );
  }
}
