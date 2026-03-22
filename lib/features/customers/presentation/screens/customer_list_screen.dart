import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/gymblog_api_client.dart';
import '../../../../theme/stitch_m3_theme.dart';
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
  String _searchQuery = '';
  int _filterChipIndex = 0; // 0 = All, 1 = Weight Loss, 2 = Muscle Gain, etc.
  static const List<String> _filterChips = ['All', 'Weight Loss', 'Muscle Gain', 'Endurance', 'Rehab'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _importFromContacts() async {
    final granted = await FlutterContacts.requestPermission();
    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).customersImportContactsDenied),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final contact = await FlutterContacts.openExternalPick();
    if (!mounted || contact == null) return;
    final name = contact.displayName.isNotEmpty
        ? contact.displayName
        : '${contact.name.first} ${contact.name.last}'.trim();
    final phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';
    final uri = Uri(
      path: '/customers/new',
      queryParameters: <String, String>{
        if (name.isNotEmpty) 'name': name,
        if (phone.isNotEmpty) 'phone': phone,
      },
    );
    context.push(uri.toString());
  }

  Future<void> _load({bool skipCache = false}) async {
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
      final list = await _api.getList('/api/customers', skipCache: skipCache);
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
        backgroundColor: colorScheme.surfaceContainerHighest,
        appBar: _customerListAppBar(context, theme, l10n.customersTitle, showMenu: false),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.customersApiNotConfigured,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: _customerListAppBar(context, theme, l10n.customersTitle, showMenu: false),
      body: RefreshIndicator(
        onRefresh: () => _load(skipCache: true),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _errorBody(context, l10n, theme, colorScheme)
            : _customers.isEmpty
            ? _emptyBody(context, l10n, theme, colorScheme)
            : _listBodyWithSearch(context, l10n, theme, colorScheme),
      ),
      floatingActionButton: GymBlogApiClient.isConfigured && _error == null
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/customers/new'),
              icon: const Icon(Icons.add),
              label: Text(_customers.isEmpty ? l10n.customersAddFirstClient : l10n.customersAddCustomer),
              backgroundColor: _customers.isEmpty ? StitchM3Theme.accent : StitchM3Theme.accentLight,
              foregroundColor: _customers.isEmpty ? Colors.white : StitchM3Theme.accent,
              elevation: _customers.isEmpty ? 4 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
              ),
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
                  onPressed: () => _load(skipCache: true),
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
        height: MediaQuery.of(context).size.height * 0.75,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Illustration: gradient circles + icon (Stitch empty state)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 256,
                      height: 256,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            StitchM3Theme.accent.withValues(alpha: 0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 192,
                      height: 192,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: StitchM3Theme.accent.withValues(alpha: 0.06),
                        border: Border.all(
                          color: StitchM3Theme.accent.withValues(alpha: 0.2),
                          width: 1,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: Icon(
                        Icons.group_add,
                        size: 80,
                        color: StitchM3Theme.accent.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.customersEmptyTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.customersEmptyMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: _importFromContacts,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(l10n.customersImportContacts),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Customer> get _filteredCustomers {
    var list = _customers;
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((c) => c.name.toLowerCase().contains(q) || (c.goals?.toLowerCase().contains(q) ?? false)).toList();
    }
    if (_filterChipIndex > 0) {
      final goal = _filterChips[_filterChipIndex].toLowerCase();
      list = list.where((c) => (c.goals?.toLowerCase().contains(goal) ?? false)).toList();
    }
    return list;
  }

  Widget _listBodyWithSearch(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final filtered = _filteredCustomers;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search clients by name or goal',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant, size: 22),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filterChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == _filterChipIndex;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _filterChipIndex = i),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? StitchM3Theme.accent : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _filterChips[i],
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: selected ? Colors.white : colorScheme.onSurface,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index.isOdd) return const SizedBox(height: 12);
                final itemIndex = index ~/ 2;
                final c = filtered[itemIndex];
                final subtitle = [
                  if (c.email != null && c.email!.isNotEmpty) c.email!,
                  if (c.phone != null && c.phone!.isNotEmpty) c.phone!,
                ].join(' · ');
                final goalLabel = c.goals ?? '';
                return Padding(
                  padding: EdgeInsets.only(bottom: itemIndex < filtered.length - 1 ? 12 : 0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                    onTap: () => context.push('/customers/${c.id}'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                        border: Border.all(color: colorScheme.outline),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                if (goalLabel.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      goalLabel,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: StitchM3Theme.accent,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                if (subtitle.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: filtered.isEmpty ? 0 : filtered.length * 2 - 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final cs = theme.colorScheme;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: cs.primaryContainer),
            child: Text(
              l10n.appTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: Text(l10n.customersTitle),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center_outlined),
            title: Text(l10n.exerciseLibraryTitle),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/exercise-library');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(l10n.settingsTitle),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/settings');
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _customerListAppBar(
    BuildContext context,
    ThemeData theme,
    String title, {
    bool showMenu = false,
  }) {
    final cs = theme.colorScheme;
    return AppBar(
      backgroundColor: cs.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: showMenu
          ? Builder(
              builder: (drawerContext) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(drawerContext).openDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                HapticFeedback.mediumImpact();
                final router = GoRouter.of(context);
                if (router.canPop()) {
                  router.pop();
                } else {
                  router.go('/');
                }
              },
            ),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: cs.outline, height: 1),
      ),
    );
  }
}
