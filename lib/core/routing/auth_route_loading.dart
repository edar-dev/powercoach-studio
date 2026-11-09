import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/routing/route_redirect.dart';
import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

/// Loading shell while Supabase restores the session on cold start / refresh.
///
/// Branded dark canvas (not a login flash) so protected deep links stay on-path
/// until [SupabaseBootstrap.authReady].
class AuthRouteLoading extends StatelessWidget {
  const AuthRouteLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: MarketingDarkColors.bgAlt,
      body: Center(
        child: CircularProgressIndicator(
          color: StitchM3Theme.accent,
        ),
      ),
    );
  }
}

/// Returns the loading shell when auth is not ready yet or the router is
/// about to send the user to login.
Widget? authRouteLoadingOrNull() {
  if (!shouldShowAuthRouteLoading()) return null;
  return const AuthRouteLoading();
}
