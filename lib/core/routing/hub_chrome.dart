import 'package:flutter/material.dart';

import '../ui/breakpoints.dart';

/// Whether the primary shell shows [NavigationRail] (tablet+).
///
/// On wide layouts the rail already provides logo-equivalent Home (Today tab)
/// and Settings — hub [AppBar]s should omit those duplicates.
bool primaryShellUsesRail(BuildContext context) =>
    Breakpoints.isTabletOrWider(context);

/// Shared page background for primary-shell hubs.
///
/// Prefer [ColorScheme.surfaceContainerHighest] over one-off Marketing tokens
/// so Today / Clienti / Schede / Diario / Settings share one surface.
Color hubPageBackground(BuildContext context) =>
    Theme.of(context).colorScheme.surfaceContainerHighest;
