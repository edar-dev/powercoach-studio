/// Stitch registration password rules: min 8 chars, 1 digit, 1 special.
abstract final class RegistrationPasswordRules {
  static final digit = RegExp(r'[0-9]');
  static final special = RegExp(r'[^A-Za-z0-9]');

  static bool hasMinLength(String value) => value.length >= 8;

  static bool hasDigit(String value) => digit.hasMatch(value);

  static bool hasSpecial(String value) => special.hasMatch(value);

  static bool isValid(String value) =>
      hasMinLength(value) && hasDigit(value) && hasSpecial(value);

  /// 0–4 segment strength for the meter UI.
  static int strengthScore(String value) {
    if (value.isEmpty) return 0;
    var score = 0;
    if (value.length >= 8) score++;
    if (hasDigit(value)) score++;
    if (hasSpecial(value)) score++;
    if (value.length >= 12 ||
        (RegExp(r'[a-z]').hasMatch(value) &&
            RegExp(r'[A-Z]').hasMatch(value))) {
      score++;
    }
    return score.clamp(0, 4);
  }
}
