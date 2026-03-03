import 'package:flutter/material.dart';

/// Design system from POWERCOACH_STUDIO_DESIGN_SPEC.md (Stitch).
/// Colors, typography, and component tokens for 100% prototype match.
class AppTheme {
  AppTheme._();

  // Light palette (design spec)
  static const Color bg = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFF9FAFB);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color accent = Color(0xFF2563EB);
  static const Color accentHover = Color(0xFF1D4ED8);
  static const Color accentLight = Color(0xFFDBEAFE);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color logoStart = Color(0xFF3B82F6);
  static const Color logoEnd = Color(0xFF9333EA);

  static const double radiusMd = 8;
  static const double radiusLg = 12;

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: accent,
      onPrimary: Colors.white,
      primaryContainer: accentLight,
      onPrimaryContainer: accentHover,
      secondary: Color(0xFF6B7280),
      onSecondary: Colors.white,
      surface: bg,
      onSurface: textPrimary,
      onSurfaceVariant: textMuted,
      outline: border,
      outlineVariant: Color(0xFFF3F4F6),
      error: danger,
      onError: Colors.white,
      errorContainer: Color(0xFFFEE2E2),
      onErrorContainer: Color(0xFF991B1B),
      surfaceContainerHighest: bgSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: textPrimary, size: 24),
      ),
      cardTheme: CardThemeData(
        color: bg,
        elevation: 0,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusLg)),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusLg)),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusLg)),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusLg)),
          borderSide: BorderSide(color: danger),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: textMuted, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: textMuted),
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
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
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
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
      textTheme: _textTheme,
      fontFamily: null, // system: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto
    );
  }

  static TextTheme get _textTheme => TextTheme(
    displayMedium: const TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.1,
    ),
    headlineMedium: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  );

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: accent,
        onPrimary: Colors.white,
        surface: const Color(0xFF1F2937),
        onSurface: const Color(0xFFF9FAFB),
        onSurfaceVariant: textMuted,
      ),
      scaffoldBackgroundColor: const Color(0xFF111827),
    );
  }
}
