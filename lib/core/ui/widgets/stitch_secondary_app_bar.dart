import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../routing/app_navigation.dart';
import '../../routing/app_paths.dart';
import '../../../l10n/app_localizations.dart';

/// App bar per schermate secondarie (profilo, impostazioni, login, ecc.):
/// pulsante indietro, titolo, bordo inferiore. Usa i colori del tema (light/dark).
///
/// Empty-stack back and Home fall back to [AppPaths.dashboard] (authenticated hub).
class StitchSecondaryAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const StitchSecondaryAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
    this.showHome = true,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  /// When true (default), shows a Home affordance unless already on dashboard.
  final bool showHome;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  bool _isOnDashboard(BuildContext context) {
    // Widget tests often mount screens under MaterialApp without GoRouter.
    if (GoRouter.maybeOf(context) == null) return false;
    return GoRouterState.of(context).uri.path == AppPaths.dashboard;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final materialL10n = MaterialLocalizations.of(context);
    final onDashboard = _isOnDashboard(context);

    final homeAction = showHome && !onDashboard
        ? IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: l10n.navHomeTooltip,
            onPressed: () {
              HapticFeedback.mediumImpact();
              navigateTo(context, AppPaths.dashboard);
            },
          )
        : null;

    final mergedActions = <Widget>[
      ?homeAction,
      ...?actions,
    ];

    return AppBar(
      backgroundColor: cs.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: materialL10n.backButtonTooltip,
        onPressed: () {
          HapticFeedback.mediumImpact();
          if (onBack != null) {
            onBack!();
          } else if (context.canPop()) {
            context.pop();
          } else {
            navigateBack(context, fallback: AppPaths.dashboard);
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
      actions: mergedActions.isEmpty ? null : mergedActions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: cs.outline, height: 1),
      ),
    );
  }
}
