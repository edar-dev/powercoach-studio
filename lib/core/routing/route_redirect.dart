import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/routing/app_paths.dart';

bool isProtectedAppPath(String path) {
  return path.startsWith('/customers') ||
      path.startsWith('/dashboard') ||
      path.startsWith('/workouts') ||
      path == '/profile' ||
      path.startsWith('/settings') ||
      path == AppPaths.subscription ||
      path == '/exercise-library' ||
      path.startsWith(AppPaths.gym);
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
    final from = _protectedRouteRedirectTarget(state);
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

  if (path == '/workouts/library') {
    return '/exercise-library';
  }

  return null;
}

bool shouldShowAuthRouteLoading() {
  return !SupabaseBootstrap.authReady;
}

String _protectedRouteRedirectTarget(GoRouterState state) {
  final uri = state.uri.toString();
  if (uri.isNotEmpty && uri != '/') {
    return uri;
  }
  final matched = state.matchedLocation;
  if (matched.isNotEmpty && matched != '/') {
    return matched;
  }
  return uri;
}
