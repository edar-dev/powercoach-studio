import 'package:flutter/material.dart';

/// Shared UI breakpoints for responsive/adaptive layout.
///
/// Keep these constants centralized to avoid duplicating magic numbers across screens.
class AppBreakpoints {
  AppBreakpoints._();

  /// Convention already used in the app (e.g. Landing/Home): 600px.
  static const double tablet = 600;

  /// Wide layout threshold for two-pane workout builder (900px).
  static const double desktop = 900;

  /// Readable measure for session-sheet content on desktop.
  static const double sessionSheetMaxWidth = 840;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  static bool isTabletOrWider(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;
}

/// Alias for existing call sites that reference [Breakpoints].
typedef Breakpoints = AppBreakpoints;

