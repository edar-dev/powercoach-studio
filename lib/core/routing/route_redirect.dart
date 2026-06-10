import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';

bool isProtectedAppPath(String path) {
  return path.startsWith('/customers') ||
      path.startsWith('/dashboard') ||
      path.startsWith('/workouts') ||
      path == '/profile' ||
      path.startsWith('/settings') ||
      path == '/exercise-library';
}

/// Returns a safe in-app path from a post-login redirect query parameter.
String? safePostLoginRedirect(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final uri = Uri.tryParse(raw);
  if (uri == null) return null;
  if (uri.hasScheme || uri.hasAuthority) return null;
  if (!uri.path.startsWith('/')) return null;
  if (uri.path == '/' || uri.path == '/login') return null;
  return uri.toString();
}

String? resolveAppRouteRedirect(GoRouterState state) {
  if (!SupabaseBootstrap.authReady) {
    return null;
  }

  final path = state.uri.path;
  final isLoggedIn = SupabaseBootstrap.currentUser != null;
  final isProtectedRoute = isProtectedAppPath(path);

  if (isProtectedRoute && !isLoggedIn) {
    final from = state.uri.toString();
    if (from.isNotEmpty && from != '/login') {
      return '/login?redirect=${Uri.encodeComponent(from)}';
    }
    return '/login';
  }

  if (isLoggedIn && path == '/login') {
    return safePostLoginRedirect(state.uri.queryParameters['redirect']) ??
        '/dashboard';
  }

  if (isLoggedIn && path == '/') {
    return '/dashboard';
  }

  return null;
}

bool shouldShowAuthRouteLoading() {
  return !SupabaseBootstrap.authReady ||
      SupabaseBootstrap.currentUser == null;
}
