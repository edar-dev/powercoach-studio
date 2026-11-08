import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/ui/haptics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppHaptics methods complete without throwing', () async {
    // On the test VM (non-web) these hit the platform channel; the test
    // binding absorbs missing plugins so calls should still complete.
    await AppHaptics.selection();
    await AppHaptics.light();
    await AppHaptics.medium();
    await AppHaptics.heavy();
    expect(kIsWeb, isFalse);
  });
}
