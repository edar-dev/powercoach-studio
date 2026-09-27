import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';

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
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: MarketingDarkColors.text,
        ),
      ),
      centerTitle: false,
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
