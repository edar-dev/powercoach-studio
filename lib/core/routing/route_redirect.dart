import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/routing/app_paths.dart';

bool isProtectedAppPath(String path) {
  return path.startsWith(AppPaths.customers) ||
      path.startsWith(AppPaths.dashboard) ||
      path.startsWith('/workouts') ||
      // Legacy bookmark paths: still require auth before redirecting.
      path == '/profile' ||
      path == '/gym' ||
      path.startsWith('/gym/') ||
      path == '/plans/diff' ||
      path.startsWith('/plans/') ||
      path.startsWith(AppPaths.settings) ||
      path == AppPaths.subscription ||
      path == AppPaths.exerciseLibrary;
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

/// Redirect target that preserves the original query string when present.
String redirectPreservingQuery(Uri uri, String targetPath) {
  final query = uri.query;
  return query.isEmpty ? targetPath : '$targetPath?$query';
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
        AppPaths.dashboard;
  }

  if (isLoggedIn && path == '/') {
    return AppPaths.dashboard;
  }

  if (path == '/workouts/library') {
    return redirectPreservingQuery(state.uri, AppPaths.exerciseLibrary);
  }

  // Legacy bookmarks from removed surfaces (Waves A–F).
  if (path == '/gym' || path.startsWith('/gym/')) {
    return redirectPreservingQuery(state.uri, AppPaths.dashboard);
  }
  if (path == '/profile') {
    return redirectPreservingQuery(state.uri, AppPaths.personalInfo);
  }
  if (path == '${AppPaths.dashboard}/schedule') {
    return redirectPreservingQuery(state.uri, AppPaths.calendar);
  }
  if (path == '/workouts/stats') {
    return redirectPreservingQuery(state.uri, AppPaths.workoutDiary);
  }
  if (path == '/workouts/templates') {
    return redirectPreservingQuery(state.uri, AppPaths.workoutBuilder);
  }
  if (path == '/plans/diff' || path.startsWith('/plans/')) {
    return redirectPreservingQuery(state.uri, AppPaths.customers);
  }
  if (path == '/settings/release-notes') {
    return redirectPreservingQuery(state.uri, AppPaths.settings);
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
