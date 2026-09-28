import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/routing/app_paths.dart';
import 'package:powercoach_studio/core/routing/route_redirect.dart';

void main() {
  test('isProtectedAppPath covers customer and dashboard routes', () {
    expect(isProtectedAppPath('/customers'), isTrue);
    expect(isProtectedAppPath('/customers/local_customer_1'), isTrue);
    expect(isProtectedAppPath('/dashboard'), isTrue);
    expect(isProtectedAppPath('/login'), isFalse);
    expect(isProtectedAppPath('/'), isFalse);
  });

  test('safePostLoginRedirect accepts in-app paths only', () {
    expect(safePostLoginRedirect('/customers/abc'), '/customers/abc');
    expect(
      safePostLoginRedirect('/customers/abc/notes?customerName=Mario'),
      '/customers/abc/notes?customerName=Mario',
    );
    expect(safePostLoginRedirect('https://evil.test/customers'), isNull);
    expect(safePostLoginRedirect('/login'), isNull);
    expect(safePostLoginRedirect('/'), isNull);
  });

  test('isProtectedAppPath covers workout and settings deep links', () {
    expect(isProtectedAppPath('/workouts/editor'), isTrue);
    expect(isProtectedAppPath('/workouts/editor/plan-1'), isTrue);
    expect(isProtectedAppPath('/workouts/templates'), isTrue);
    expect(isProtectedAppPath('/workouts/builder'), isTrue);
    expect(isProtectedAppPath('/settings'), isTrue);
    expect(isProtectedAppPath('/settings/personal-info'), isTrue);
    expect(isProtectedAppPath('/subscription'), isTrue);
    expect(isProtectedAppPath('/settings/subscription'), isTrue);
    expect(isProtectedAppPath('/profile'), isTrue);
    expect(isProtectedAppPath('/gym'), isTrue);
    expect(isProtectedAppPath('/gym/session'), isTrue);
    expect(isProtectedAppPath('/plans/diff'), isTrue);
    expect(isProtectedAppPath('/dashboard/calendar'), isTrue);
    expect(isProtectedAppPath('/dashboard/schedule/detail'), isTrue);
    expect(isProtectedAppPath('/exercise-library'), isTrue);
    expect(isProtectedAppPath('/customers/cust-1/workouts'), isTrue);
    expect(isProtectedAppPath('/customers/cust-1/workouts/plan-9'), isTrue);
    expect(isProtectedAppPath('/customers/cust-1/workouts/new'), isTrue);
  });

  group('redirectPreservingQuery', () {
    test('appends query string when present', () {
      expect(
        redirectPreservingQuery(Uri.parse('/gym?from=today'), '/dashboard'),
        '/dashboard?from=today',
      );
    });

    test('returns bare path when query is empty', () {
      expect(
        redirectPreservingQuery(Uri.parse('/gym'), '/dashboard'),
        '/dashboard',
      );
    });
  });

  group('legacy URL redirect targets', () {
    // Pure helpers mirror resolveAppRouteRedirect destinations for removed
    // surfaces. Full GoRouter redirect needs auth bootstrap; path mapping is
    // what bookmarks must keep stable.
    test('maps removed surfaces to canonical destinations', () {
      const cases = <(String path, String target)>[
        ('/gym', '/dashboard'),
        ('/gym/session', '/dashboard'),
        ('/profile', AppPaths.personalInfo),
        ('/plans/diff', '/customers'),
        ('/workouts/stats', '/workouts/diary'),
        ('/dashboard/schedule', '/dashboard/calendar'),
        ('/settings/release-notes', AppPaths.settings),
        ('/workouts/library', '/exercise-library'),
        ('/workouts/templates', '/workouts/builder'),
      ];

      for (final (path, target) in cases) {
        final uri = Uri.parse(path);
        final redirected = _legacyRedirectTarget(uri);
        expect(redirected, target, reason: path);
      }
    });

    test('preserves query strings on legacy redirects', () {
      expect(
        _legacyRedirectTarget(Uri.parse('/gym/session?planId=p1')),
        '/dashboard?planId=p1',
      );
      expect(
        _legacyRedirectTarget(Uri.parse('/profile?tab=bio')),
        '${AppPaths.personalInfo}?tab=bio',
      );
      expect(
        _legacyRedirectTarget(Uri.parse('/plans/diff?a=1&b=2')),
        '/customers?a=1&b=2',
      );
      expect(
        _legacyRedirectTarget(Uri.parse('/workouts/stats?period=30d')),
        '/workouts/diary?period=30d',
      );
      expect(
        _legacyRedirectTarget(Uri.parse('/dashboard/schedule?week=1')),
        '/dashboard/calendar?week=1',
      );
      expect(
        _legacyRedirectTarget(Uri.parse('/settings/release-notes?v=1')),
        '${AppPaths.settings}?v=1',
      );
    });
  });
}

/// Mirrors legacy branches in [resolveAppRouteRedirect] for unit testing
/// without Supabase auth bootstrap.
String? _legacyRedirectTarget(Uri uri) {
  final path = uri.path;
  if (path == '/workouts/library') {
    return redirectPreservingQuery(uri, '/exercise-library');
  }
  if (path == '/gym' || path.startsWith('/gym/')) {
    return redirectPreservingQuery(uri, '/dashboard');
  }
  if (path == '/profile') {
    return redirectPreservingQuery(uri, AppPaths.personalInfo);
  }
  if (path == '/dashboard/schedule') {
    return redirectPreservingQuery(uri, '/dashboard/calendar');
  }
  if (path == '/workouts/stats') {
    return redirectPreservingQuery(uri, '/workouts/diary');
  }
  if (path == '/workouts/templates') {
    return redirectPreservingQuery(uri, '/workouts/builder');
  }
  if (path == '/plans/diff' || path.startsWith('/plans/')) {
    return redirectPreservingQuery(uri, '/customers');
  }
  if (path == '/settings/release-notes') {
    return redirectPreservingQuery(uri, AppPaths.settings);
  }
  return null;
}
