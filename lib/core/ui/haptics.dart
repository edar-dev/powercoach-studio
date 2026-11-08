import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Native-only light haptics; no-op on web.
abstract final class AppHaptics {
  static Future<void> selection() async {
    if (kIsWeb) return;
    await HapticFeedback.selectionClick();
  }

  static Future<void> light() async {
    if (kIsWeb) return;
    await HapticFeedback.lightImpact();
  }

  static Future<void> medium() async {
    if (kIsWeb) return;
    await HapticFeedback.mediumImpact();
  }

  static Future<void> heavy() async {
    if (kIsWeb) return;
    await HapticFeedback.heavyImpact();
  }
}
