import 'package:shared_preferences/shared_preferences.dart';

/// Persists post-invite dashboard checklist dismiss + PDF-done flags per user.
class PostInviteOnboardingStore {
  PostInviteOnboardingStore._();

  static final PostInviteOnboardingStore instance =
      PostInviteOnboardingStore._();

  static String dismissedKeyFor(String userId) =>
      'post_invite_onboarding_dismissed_$userId';

  static String pdfDoneKeyFor(String userId) =>
      'post_invite_onboarding_pdf_done_$userId';

  Future<bool> isDismissed(String userId) async {
    if (userId.isEmpty) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(dismissedKeyFor(userId)) ?? false;
  }

  Future<void> markDismissed(String userId) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(dismissedKeyFor(userId), true);
  }

  Future<bool> isPdfDone(String userId) async {
    if (userId.isEmpty) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(pdfDoneKeyFor(userId)) ?? false;
  }

  Future<void> markPdfDone(String userId) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(pdfDoneKeyFor(userId), true);
  }
}
