import 'package:flutter/material.dart';

void showAppSnackBar(
  BuildContext context, {
  required Widget content,
  Color? backgroundColor,
  Duration duration = const Duration(seconds: 3),
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: content,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
      ),
    );
}

