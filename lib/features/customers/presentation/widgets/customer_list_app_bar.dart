import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/routing/app_paths.dart';
import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../l10n/app_localizations.dart';

class CustomerListAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomerListAppBar({
    super.key,
    required this.title,
    this.showMenu = false,
  });

  final String title;
  final bool showMenu;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onDashboard = GoRouter.maybeOf(context) != null &&
        GoRouterState.of(context).uri.path == AppPaths.dashboard;

    return AppBar(
      backgroundColor: MarketingDarkColors.bgAlt,
      foregroundColor: MarketingDarkColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: showMenu
          ? Builder(
              builder: (drawerContext) => IconButton(
                icon: const Icon(Icons.menu),
                color: MarketingDarkColors.slate300,
                onPressed: () => Scaffold.of(drawerContext).openDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back),
              color: MarketingDarkColors.slate300,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () {
                HapticFeedback.mediumImpact();
                navigateBack(context, fallback: AppPaths.dashboard);
              },
            ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: MarketingDarkColors.text,
        ),
      ),
      centerTitle: false,
      actions: [
        if (!onDashboard)
          IconButton(
            icon: const Icon(Icons.home_outlined),
            color: MarketingDarkColors.slate300,
            tooltip: l10n.navHomeTooltip,
            onPressed: () {
              HapticFeedback.mediumImpact();
              navigateTo(context, AppPaths.dashboard);
            },
          ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: ColoredBox(
          color: MarketingDarkColors.border,
          child: SizedBox(height: 1, width: double.infinity),
        ),
      ),
    );
  }
}
