import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../theme/stitch_m3_theme.dart';
import '../../../../core/network/gymblog_api_client.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/customer.dart';

/// Customer Detail Page – Stitch screen ID 7a7f3b47bfa1435381554959ca9b72e7.
class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final GymBlogApiClient _api = GymBlogApiClient();
  Customer? _customer;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.get('/api/customers/${widget.customerId}');
      if (mounted) {
        setState(() {
          _customer = Customer.fromJson(data);
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e is GymBlogApiException ? e.message : e.toString();
        });
      }
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.customerDeleteConfirmTitle),
        content: Text(l10n.customerDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.customerCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.customerDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    try {
      await _api.delete('/api/customers/${widget.customerId}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.customerDeletedMessage,
            style: TextStyle(color: colorScheme.onPrimaryContainer),
          ),
          backgroundColor: colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/customers');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is GymBlogApiException ? e.message : l10n.customerDeleteError,
            style: TextStyle(color: colorScheme.onErrorContainer),
          ),
          backgroundColor: colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
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

    if (_loading) {
      return Scaffold(
        appBar: _detailAppBar(context, theme, l10n.customersTitle),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _customer == null) {
      return Scaffold(
        appBar: _detailAppBar(context, theme, l10n.customersTitle),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  _error ?? l10n.customersLoadError,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: Text(l10n.customerCancel),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final c = _customer!;
    final goalLabel = c.goals ?? '';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.pop();
          },
        ),
        title: Text(
          'Customer Detail',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: colorScheme.outline, height: 1),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // More menu: edit / delete
              showModalBottomSheet(
                context: context,
                builder: (ctx) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit_outlined),
                        title: Text(l10n.customerEdit),
                        onTap: () {
                          Navigator.pop(ctx);
                          context.push('/customers/${c.id}/edit');
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.delete_outline, color: colorScheme.error),
                        title: Text(l10n.customerDelete, style: TextStyle(color: colorScheme.error)),
                        onTap: () {
                          Navigator.pop(ctx);
                          _delete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile section (Stitch)
              Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: StitchM3Theme.accentLight,
                          border: Border.all(
                            color: StitchM3Theme.accent.withValues(alpha: 0.25),
                            width: 4,
                          ),
                        ),
                        child: Icon(Icons.person, size: 64, color: StitchM3Theme.accent.withValues(alpha: 0.6)),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: StitchM3Theme.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.surface, width: 2),
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    c.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (goalLabel.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: StitchM3Theme.accentLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Goal: $goalLabel',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: StitchM3Theme.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/customers/${c.id}/edit'),
                          icon: const Icon(Icons.edit, size: 20),
                          label: const Text('Edit Profile'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            foregroundColor: colorScheme.onSurface,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => context.push('/workouts/builder?customerId=${c.id}'),
                          icon: const Icon(Icons.add_task, size: 20),
                          label: const Text('Assign Workout'),
                          style: FilledButton.styleFrom(
                            backgroundColor: StitchM3Theme.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 2,
                            shadowColor: StitchM3Theme.accent.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Stats grid
              Row(
                children: [
                  Expanded(
                    child: _statCard(context, 'Current Weight', c.weightKg != null ? '${c.weightKg}' : '—', 'kg', '+1.2%'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _statCard(context, 'Muscle Mass', '—', 'kg', '+0.5%'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Progress overview
              Text(
                'Progress Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 192,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(StitchM3Theme.radiusXl),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [40, 55, 50, 75, 65, 85, 70].map((h) => Container(
                    width: 24,
                    height: h * 1.2,
                    decoration: BoxDecoration(
                      color: h == 75 ? StitchM3Theme.accent : StitchM3Theme.accent.withValues(alpha: 0.25),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                    .map((d) => Text(d, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700)))
                    .toList(),
              ),
              const SizedBox(height: 24),
              // Recent workouts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Workouts',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('View All', style: TextStyle(color: StitchM3Theme.accent, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _workoutCard(context, 'Heavy Upper Body A', 'Yesterday • 65 mins', 'Completed', 'NEW PR', true),
              const SizedBox(height: 12),
              _workoutCard(context, 'Leg Day Focus', '3 days ago • 72 mins', 'Completed', '14,200 KG VOLUME', false),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _detailAppBar(BuildContext context, ThemeData theme, String title) {
    final cs = theme.colorScheme;
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
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

  Widget _statCard(BuildContext context, String label, String value, String unit, String trend) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusXl),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.trending_up, size: 14, color: StitchM3Theme.success),
              const SizedBox(width: 4),
              Text(
                trend,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: StitchM3Theme.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _workoutCard(BuildContext context, String title, String subtitle, String status, String extra, bool isNewPr) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusXl),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: StitchM3Theme.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            ),
            child: Icon(Icons.fitness_center, color: StitchM3Theme.accent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                status,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              Text(
                extra,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isNewPr ? StitchM3Theme.success : cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
