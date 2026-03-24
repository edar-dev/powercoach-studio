import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/gymblog_api_client.dart';
import '../../../customers/data/customer_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';

/// Coach Dashboard – Stitch screen ID 285387f9d39c459a989d6060a1c486b0.
/// Weekly progress, stats (clients, programs), Add Client / Create Program, Today's Schedule.
class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  final CustomerRepository _customerRepo = CustomerRepository();
  int _clientCount = 0;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!GymBlogApiClient.isConfigured) {
      setState(() {
        _clientCount = 0;
        _loadingStats = false;
      });
      return;
    }
    try {
      final customers = await _customerRepo.getAll();
      final count = customers.length;
      if (mounted) {
        setState(() {
          _clientCount = count;
          _loadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _clientCount = 0;
          _loadingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerHighest,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: cs.surface,
        title: Text(
          'Dashboard',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              HapticFeedback.mediumImpact();
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.push('/profile');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: cs.outline, height: 1),
        ),
      ),
      drawer: _DashboardDrawer(theme: theme, cs: cs),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Weekly Progress
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up, size: 20, color: StitchM3Theme.accent),
                        const SizedBox(width: 8),
                        Text(
                          'Weekly Progress',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '88',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      'Workouts This Week',
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      theme: theme,
                      cs: cs,
                      value: _loadingStats ? '–' : '$_clientCount',
                      label: 'Total Clients',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      theme: theme,
                      cs: cs,
                      value: '15',
                      label: 'Active Programs',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Add Client / Create Program
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        context.push('/customers/new');
                      },
                      icon: const Icon(Icons.person_add, size: 20),
                      label: const Text('Add Client'),
                      style: FilledButton.styleFrom(
                        backgroundColor: StitchM3Theme.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        context.push('/workouts/builder');
                      },
                      icon: const Icon(Icons.fitness_center, size: 20),
                      label: const Text('Create Program'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: StitchM3Theme.accent,
                        side: const BorderSide(color: StitchM3Theme.accent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Today's Schedule
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Schedule",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      context.push('/dashboard/schedule');
                    },
                    child: Text('See All', style: TextStyle(color: StitchM3Theme.accent, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._todayScheduleItems(context, theme, cs),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _todayScheduleItems(BuildContext context, ThemeData theme, ColorScheme cs) {
    const items = [
      ('08:00', 'AM', 'Marcus Wright', 'Hypertrophy - Legs'),
      ('10:30', 'AM', 'Sarah Jenkins', 'Mobility & Core'),
      ('02:00', 'PM', 'David Chen', 'Push Day (A)'),
      ('05:15', 'PM', 'Emma Thompson', 'HIIT - Full Body'),
    ];
    return items.map((e) {
      final (time, period, client, program) = e;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _ScheduleCard(
          theme: theme,
          cs: cs,
          time: time,
          period: period,
          clientName: client,
          programName: program,
          onTap: () {
            HapticFeedback.mediumImpact();
            context.push(
              Uri(
                path: '/dashboard/schedule/detail',
                queryParameters: {'time': time, 'period': period, 'client': client, 'program': program},
              ).toString(),
            );
          },
        ),
      );
    }).toList();
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.theme,
    required this.cs,
    required this.value,
    required this.label,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.theme,
    required this.cs,
    required this.time,
    required this.period,
    required this.clientName,
    required this.programName,
    required this.onTap,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String time;
  final String period;
  final String clientName;
  final String programName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    period,
                    style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      programName,
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardDrawer extends StatelessWidget {
  const _DashboardDrawer({required this.theme, required this.cs});

  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) context.go('/dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Customers'),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) context.go('/customers');
              },
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Workout Builder'),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) context.push('/workouts/builder');
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books_outlined),
              title: Text(AppLocalizations.of(context).exerciseLibraryTitle),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) context.push('/exercise-library');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) context.push('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) context.push('/settings');
              },
            ),
          ],
        ),
      ),
    );
  }
}
