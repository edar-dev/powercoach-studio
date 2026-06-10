import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/routing/route_redirect.dart';

/// Loading shell while Supabase restores the session on cold start / refresh.
class AuthRouteLoading extends StatelessWidget {
  const AuthRouteLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Returns the loading shell when auth is not ready yet or the router is
/// about to send the user to login.
Widget? authRouteLoadingOrNull() {
  if (!shouldShowAuthRouteLoading()) return null;
  return const AuthRouteLoading();
}
