import '../../../core/storage/local_user_profile_store.dart';

export '../../../core/storage/local_user_profile_store.dart' show LocalUserProfileData;

/// Reads and writes the coach profile stored locally per authenticated user.
class LocalCoachProfileRepository {
  LocalCoachProfileRepository({LocalUserProfileStore? store})
    : _store = store ?? LocalUserProfileStore.instance;

  static final LocalCoachProfileRepository instance =
      LocalCoachProfileRepository._();

  LocalCoachProfileRepository._() : _store = LocalUserProfileStore.instance;

  final LocalUserProfileStore _store;

  Future<LocalUserProfileData> getProfile(String userId) => _store.read(userId);

  Future<void> saveProfile(String userId, LocalUserProfileData profile) =>
      _store.write(userId, profile);
}
