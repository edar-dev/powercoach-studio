import 'package:flutter/material.dart';

import '../ui/breakpoints.dart';

/// Stitch Nov 2026 desktop primary rail width (extended / drawer-style).
const double kPrimaryShellRailExtendedWidth = 220;

/// Whether the primary shell shows [NavigationRail] (tablet+).
///
/// On wide layouts the extended rail owns brand Home + labeled Settings —
/// hub [AppBar]s should omit those duplicates via `showLogo: false` / no shell
/// settings action, and share [StitchAppBar] title density
/// (`titleLarge` + `kToolbarHeight`).
bool primaryShellUsesRail(BuildContext context) =>
    Breakpoints.isTabletOrWider(context);

/// Shared page background for primary-shell hubs.
///
/// Prefer [ColorScheme.surfaceContainerHighest] over one-off Marketing tokens
/// so Today / Clienti / Schede / Diario / Settings share one surface.
Color hubPageBackground(BuildContext context) =>
    Theme.of(context).colorScheme.surfaceContainerHighest;
