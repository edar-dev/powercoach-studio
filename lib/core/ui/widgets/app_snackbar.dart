import 'package:flutter/material.dart';

void showAppSnackBar(
  BuildContext context, {
  required Widget content,
  Color? backgroundColor,
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
  bool persistUntilDismissed = false,
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

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: content,
        duration: effectiveDuration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        action: effectiveAction,
      ),
    );
}
