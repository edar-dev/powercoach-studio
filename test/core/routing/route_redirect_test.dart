import 'package:flutter_test/flutter_test.dart';
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
    expect(isProtectedAppPath('/workouts/builder/multiset'), isTrue);
    expect(isProtectedAppPath('/settings'), isTrue);
    expect(isProtectedAppPath('/settings/personal-info'), isTrue);
    expect(isProtectedAppPath('/subscription'), isTrue);
    expect(isProtectedAppPath('/settings/subscription'), isTrue);
    expect(isProtectedAppPath('/profile'), isTrue);
    expect(isProtectedAppPath('/dashboard/calendar'), isTrue);
    expect(isProtectedAppPath('/dashboard/schedule/detail'), isTrue);
    expect(isProtectedAppPath('/exercise-library'), isTrue);
    expect(isProtectedAppPath('/customers/cust-1/workouts'), isTrue);
    expect(isProtectedAppPath('/customers/cust-1/workouts/plan-9'), isTrue);
    expect(isProtectedAppPath('/customers/cust-1/workouts/new'), isTrue);
  });
}
