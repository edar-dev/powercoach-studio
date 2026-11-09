import 'package:flutter/material.dart';

import '../breakpoints.dart';

/// Default clearance above phone NavigationBar (incl. typical safe-area fudge).
const double kAppSnackBarNavBarClearance = 80;

/// Extra clearance for sticky Salva / unsaved bars sitting above the nav bar.
const double kAppSnackBarStickyFooterClearance = 72;

/// Computes floating snackbar bottom margin so it clears phone chrome.
double resolveAppSnackBarBottomMargin(
  BuildContext context, {
  double? bottomOffset,
  double extraBottomOffset = 0,
}) {
  if (bottomOffset != null) {
    return bottomOffset + extraBottomOffset;
  }
  if (Breakpoints.isTabletOrWider(context)) {
    return 16 + extraBottomOffset;
  }
  final safeBottom = MediaQuery.paddingOf(context).bottom;
  final navClearance =
      (safeBottom + kBottomNavigationBarHeight).clamp(
        kAppSnackBarNavBarClearance,
        120.0,
      );
  return navClearance + extraBottomOffset;
}

void showAppSnackBar(
  BuildContext context, {
  required Widget content,
  Color? backgroundColor,
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
  bool persistUntilDismissed = false,
  /// Absolute bottom margin override (skips default phone NavBar math).
  double? bottomOffset,
  /// Added on top of the resolved default (e.g. sticky Salva ~64–72).
  double extraBottomOffset = 0,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  final effectiveDuration = persistUntilDismissed
      ? const Duration(days: 1)
      : duration;

  final effectiveAction = action ??
      (persistUntilDismissed
          ? SnackBarAction(
              label: MaterialLocalizations.of(context).closeButtonLabel,
              onPressed: messenger.hideCurrentSnackBar,
            )
          : null);

  final marginBottom = resolveAppSnackBarBottomMargin(
    context,
    bottomOffset: bottomOffset,
    extraBottomOffset: extraBottomOffset,
  );

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: content,
        duration: effectiveDuration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        action: effectiveAction,
        margin: EdgeInsets.fromLTRB(16, 0, 16, marginBottom),
      ),
    );
}
