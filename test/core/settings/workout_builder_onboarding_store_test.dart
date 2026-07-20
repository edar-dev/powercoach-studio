import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/settings/workout_builder_onboarding_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('isDismissed returns false until marked', () async {
    final store = WorkoutBuilderOnboardingStore.instance;
    expect(await store.isDismissed('user-a'), isFalse);
    await store.markDismissed('user-a');
    expect(await store.isDismissed('user-a'), isTrue);
    expect(await store.isDismissed('user-b'), isFalse);
  });

  test('empty userId is treated as dismissed', () async {
    final store = WorkoutBuilderOnboardingStore.instance;
    expect(await store.isDismissed(''), isTrue);
  });
}
