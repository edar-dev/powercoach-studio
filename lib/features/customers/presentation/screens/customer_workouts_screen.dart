import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/customer_workout_plans_body.dart';

/// Lista workout del cliente – route /customers/:id/workouts.
class CustomerWorkoutsScreen extends StatelessWidget {
  const CustomerWorkoutsScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            navigateBack(context, fallback: customerPath(customerId));
          },
        ),
        title: Text(
          l10n.workoutsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ),
      body: CustomerWorkoutPlansBody(customerId: customerId),
    );
  }
}
