import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalUserProfileData {
  const LocalUserProfileData({
    this.displayName = '',
    this.phone = '',
    this.bio = '',
    this.avatarUrl = '',
    this.website = '',
    this.subscriptionPlan = 'free',
  });

  final String displayName;
  final String phone;
  final String bio;
  final String avatarUrl;
  final String website;
  final String subscriptionPlan;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'displayName': displayName,
        'phone': phone,
        'bio': bio,
        'avatarUrl': avatarUrl,
        'website': website,
        'subscriptionPlan': subscriptionPlan,
      };

  factory LocalUserProfileData.fromJson(Map<String, dynamic> json) {
    return LocalUserProfileData(
      displayName: json['displayName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      subscriptionPlan: json['subscriptionPlan']?.toString() == 'pro' ? 'pro' : 'free',
    );
  }
}

class LocalUserProfileStore {
  LocalUserProfileStore._();

  static const _keyPrefix = 'local_user_profile_v1';
  static final LocalUserProfileStore instance = LocalUserProfileStore._();

  String _keyForUser(String userId) => '$_keyPrefix:$userId';

  Future<LocalUserProfileData> read(String userId) async {
    if (userId.isEmpty) return const LocalUserProfileData();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForUser(userId));
    if (raw == null || raw.isEmpty) return const LocalUserProfileData();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const LocalUserProfileData();
      }
      return LocalUserProfileData.fromJson(decoded.cast<String, dynamic>());
    } catch (_) {
      return const LocalUserProfileData();
    }
  }

  Future<void> write(String userId, LocalUserProfileData data) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyForUser(userId), jsonEncode(data.toJson()));
  }
}
