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
}
