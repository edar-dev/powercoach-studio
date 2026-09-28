import 'package:flutter/material.dart';

/// PowerCoach Mobile Stitch M3 tokens (from stitch-mobile HTML prototypes).
///
/// Use for phone / narrow layouts of settings, subscription, calendar, diary.
abstract final class StitchMobileColors {
  static const Color surface = Color(0xFF0F131C);
  static const Color background = surface;
  static const Color surfaceContainer = Color(0xFF1C2028);
  static const Color surfaceContainerLow = Color(0xFF181C24);
  static const Color surfaceContainerHigh = Color(0xFF262A33);
  static const Color surfaceContainerHighest = Color(0xFF31353E);
  static const Color surfaceContainerLowest = Color(0xFF0A0E16);

  static const Color onSurface = Color(0xFFDFE2EE);
  static const Color onSurfaceVariant = Color(0xFFC2C6D6);

  static const Color primary = Color(0xFFADC6FF);
  static const Color primaryContainer = Color(0xFF4D8EFF);
  static const Color onPrimary = Color(0xFF002E6A);
  static const Color onPrimaryContainer = Color(0xFF00285D);

  static const Color secondary = Color(0xFF4CD7F6);
  static const Color secondaryContainer = Color(0xFF03B5D3);

  static const Color tertiary = Color(0xFF4EDEA3);
  static const Color tertiaryContainer = Color(0xFF00A572);

  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  static const Color outline = Color(0xFF8C909F);

  static const double radiusLg = 8;
  static const double radiusXl = 12;
  static const double marginMobile = 16;
  static const double gutterMobile = 12;
  static const double touchMin = 44;

  static const double headlineSize = 22;
  static const double metricSize = 24;
}
