import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../workouts/data/workout_plan_api_model.dart';
import '../../../workouts/domain/workout_plan_list_helpers.dart';
import 'customer_workout_plan_filter_bar.dart';

typedef CustomerWorkoutPlanTileBuilder =
    Widget Function(BuildContext context, WorkoutPlanApiModel plan);

class CustomerWorkoutPlanList extends StatelessWidget {
  const CustomerWorkoutPlanList({
    super.key,
    required this.plans,
    required this.selectedFilter,
    required this.onSearchQueryChanged,
    required this.onFilterChanged,
    required this.tileBuilder,
  });

  final List<WorkoutPlanApiModel> plans;
  final WorkoutPlanFilter selectedFilter;
  final ValueChanged<String> onSearchQueryChanged;
  final ValueChanged<WorkoutPlanFilter> onFilterChanged;
  final CustomerWorkoutPlanTileBuilder tileBuilder;

  @override
  Widget build(BuildContext context) {
    final filterBar = CustomerWorkoutPlanFilterBar(
      selectedFilter: selectedFilter,
      onSearchQueryChanged: onSearchQueryChanged,
      onFilterChanged: onFilterChanged,
    );
    return CustomScrollView(
      slivers: [
        ...filterBar.buildSlivers(context),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index.isOdd) return const SizedBox(height: 12);
              final planIndex = index ~/ 2;
              return tileBuilder(context, plans[planIndex]);
            }, childCount: plans.isEmpty ? 0 : plans.length * 2 - 1),
          ),
        ),
      ],
    );
  }
}

class CustomerWorkoutPlanEmptyState extends StatelessWidget {
  const CustomerWorkoutPlanEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.workoutsNoWorkoutsYet,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.workoutsAssignHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerWorkoutPlanNoMatchState extends StatelessWidget {
  const CustomerWorkoutPlanNoMatchState({
    super.key,
    required this.selectedFilter,
    required this.onSearchQueryChanged,
    required this.onFilterChanged,
  });

  final WorkoutPlanFilter selectedFilter;
  final ValueChanged<String> onSearchQueryChanged;
  final ValueChanged<WorkoutPlanFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final filterBar = CustomerWorkoutPlanFilterBar(
      selectedFilter: selectedFilter,
      onSearchQueryChanged: onSearchQueryChanged,
      onFilterChanged: onFilterChanged,
    );
    return CustomScrollView(
      slivers: [
        ...filterBar.buildSlivers(context),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.customerWorkoutsNoMatch,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
