import 'package:flutter/material.dart';

/// Theme Material 3 allineato al prototipo Stitch (POWERCOACH_STUDIO_DESIGN_SPEC).
/// Colori HEX, typography, spacing, radius da spec.
class StitchM3Theme {
  StitchM3Theme._();

  // HEX da spec
  static const Color bg = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFF9FAFB);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color accent = Color(0xFF2563EB);
  static const Color accentHover = Color(0xFF1D4ED8);
  static const Color accentLight = Color(0xFFDBEAFE);
  static const Color logoStart = Color(0xFF3B82F6);
  static const Color logoEnd = Color(0xFF9333EA);

  static const double radiusMd = 8;
  static const double radiusLg = 12;

  /// Padding da spec: 16, 24
  static const EdgeInsets padding16 = EdgeInsets.all(16);
  static const EdgeInsets padding24 = EdgeInsets.all(24);
  static const EdgeInsets paddingHorizontal24 = EdgeInsets.symmetric(horizontal: 24);
  static const EdgeInsets paddingVertical24 = EdgeInsets.symmetric(vertical: 24);

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: accent,
      onPrimary: Colors.white,
      primaryContainer: accentLight,
      onPrimaryContainer: accentHover,
      surface: bg,
      onSurface: textPrimary,
      onSurfaceVariant: textMuted,
      outline: border,
      error: Color(0xFFEF4444),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: bg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: const BorderSide(color: border),
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: _textTheme,
    );
  }

  static const TextTheme _textTheme = TextTheme(
    displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.5, height: 1.1),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textMuted),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
  );
}
