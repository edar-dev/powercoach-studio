import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/storage/local_user_profile_store.dart';
import 'package:powercoach_studio/features/auth/data/local_coach_profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalCoachProfileRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    repository = LocalCoachProfileRepository(
      store: LocalUserProfileStore.instance,
    );
  });

  test('returns empty profile when user id is empty', () async {
    final profile = await repository.getProfile('');
    expect(profile.displayName, isEmpty);
    expect(profile.subscriptionPlan, 'free');
  });

  test('persists and reads coach profile fields', () async {
    const userId = 'user-abc';
    const saved = LocalUserProfileData(
      displayName: 'Coach Ed',
      phone: '+39 333',
      bio: 'Strength coach',
      avatarUrl: 'https://example.com/a.png',
      website: 'https://example.com',
      subscriptionPlan: 'pro',
    );

    await repository.saveProfile(userId, saved);
    final loaded = await repository.getProfile(userId);

    expect(loaded.displayName, 'Coach Ed');
    expect(loaded.phone, '+39 333');
    expect(loaded.bio, 'Strength coach');
    expect(loaded.avatarUrl, 'https://example.com/a.png');
    expect(loaded.website, 'https://example.com');
    expect(loaded.subscriptionPlan, 'pro');
  });

  test('profiles are scoped per user id', () async {
    await repository.saveProfile(
      'user-a',
      const LocalUserProfileData(displayName: 'Alice'),
    );
    await repository.saveProfile(
      'user-b',
      const LocalUserProfileData(displayName: 'Bob'),
    );

    expect((await repository.getProfile('user-a')).displayName, 'Alice');
    expect((await repository.getProfile('user-b')).displayName, 'Bob');
  });
}
