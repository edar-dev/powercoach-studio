import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/stitch_m3_theme.dart';
import '../../../workouts/data/workout_plan_api_model.dart';
import '../../../workouts/data/workout_plan_repository.dart';

/// Lista workout del cliente – route /customers/:id/workouts.
/// Carica i piani dall'API (WorkoutPlanRepository) e permette di aprirli in modifica.
class CustomerWorkoutsScreen extends StatefulWidget {
  const CustomerWorkoutsScreen({super.key, required this.customerId});

  final String customerId;

  @override
  State<CustomerWorkoutsScreen> createState() => _CustomerWorkoutsScreenState();
}

class _CustomerWorkoutsScreenState extends State<CustomerWorkoutsScreen> {
  final WorkoutPlanRepository _planRepo = WorkoutPlanRepository();
  List<WorkoutPlanApiModel> _plans = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _planRepo.getByCustomerId(widget.customerId);
      if (mounted) {
        setState(() {
          _plans = list;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/customers');
            }
          },
        ),
        title: Text(
          'Workouts',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: cs.error),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _loadPlans,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _plans.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fitness_center, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text(
                              'No workouts yet',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Assign a workout to this customer from the customer detail screen.',
                              style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPlans,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _plans.length,
                        itemBuilder: (context, index) {
                          final plan = _plans[index];
                          final subtitle = _formatPlanSubtitle(plan);
                          return Padding(
                            padding: EdgeInsets.only(bottom: index < _plans.length - 1 ? 12 : 0),
                            child: _WorkoutListCard(
                              theme: theme,
                              cs: cs,
                              title: plan.name.isNotEmpty ? plan.name : 'Unnamed plan',
                              subtitle: subtitle,
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                context.push(
                                  '/workouts/editor/${plan.id}?customerId=${widget.customerId}',
                                ).then((_) {
                                  if (mounted) _loadPlans();
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: !_loading && _error == null
          ? FloatingActionButton.extended(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await context.push('/workouts/editor?customerId=${widget.customerId}');
                if (mounted) _loadPlans();
              },
              icon: const Icon(Icons.add),
              label: const Text('Assign Workout'),
              backgroundColor: StitchM3Theme.accent,
            )
          : null,
    );
  }

  String _formatPlanSubtitle(WorkoutPlanApiModel plan) {
    final updated = plan.updatedAt;
    final now = DateTime.now();
    final diff = now.difference(updated);
    if (diff.inDays > 0) return 'Updated ${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    if (diff.inHours > 0) return 'Updated ${diff.inHours}h ago';
    if (diff.inMinutes > 0) return 'Updated ${diff.inMinutes}m ago';
    return 'Just now';
  }
}

class _WorkoutListCard extends StatelessWidget {
  const _WorkoutListCard({
    required this.theme,
    required this.cs,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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
