import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/settings/post_invite_onboarding_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('isDismissed returns false until marked, per user', () async {
    final store = PostInviteOnboardingStore.instance;
    expect(await store.isDismissed('user-a'), isFalse);
    await store.markDismissed('user-a');
    expect(await store.isDismissed('user-a'), isTrue);
    expect(await store.isDismissed('user-b'), isFalse);
  });

  test('isPdfDone returns false until marked, per user', () async {
    final store = PostInviteOnboardingStore.instance;
    expect(await store.isPdfDone('user-a'), isFalse);
    await store.markPdfDone('user-a');
    expect(await store.isPdfDone('user-a'), isTrue);
    expect(await store.isPdfDone('user-b'), isFalse);
  });

  test('empty userId is treated as dismissed and pdf done; writes no-op',
      () async {
    final store = PostInviteOnboardingStore.instance;
    expect(await store.isDismissed(''), isTrue);
    expect(await store.isPdfDone(''), isTrue);
    await store.markDismissed('');
    await store.markPdfDone('');
    expect(await store.isDismissed('user-a'), isFalse);
    expect(await store.isPdfDone('user-a'), isFalse);
  });
}
