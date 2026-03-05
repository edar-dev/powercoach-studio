import 'package:flutter/material.dart';

/// Theme Material 3 allineato al prototipo Stitch (POWERCOACH_STUDIO_DESIGN_SPEC).
/// Colori HEX, typography, spacing, radius da spec.
class StitchM3Theme {
  StitchM3Theme._();

  // HEX da spec Stitch (primary #0d59f2, background-light #f5f6f8)
  static const Color bg = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFF5F6F8);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color accent = Color(0xFF0D59F2);
  static const Color accentHover = Color(0xFF0A4CD6);
  static const Color accentLight = Color(0xFFE8EEFE);
  static const Color logoStart = Color(0xFF3B82F6);
  static const Color logoEnd = Color(0xFF9333EA);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  // Dark theme (Stitch background-dark #101622)
  static const Color bgDark = Color(0xFF101622);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceContainerDark = Color(0xFF1E293B);
  static const Color onSurfaceDark = Color(0xFFF1F5F9);
  static const Color onSurfaceVariantDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);

  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;

  /// Form spacing from Stitch (space-y-5 = 20px)
  static const double formFieldSpacing = 20;
  /// Auth card: max width from Stitch max-w-md
  static const double authCardMaxWidth = 448;
  /// Auth card inner: px-8 pb-12
  static const EdgeInsets authCardPadding = EdgeInsets.fromLTRB(32, 0, 32, 48);
  /// Auth header: pt-8 pb-6 px-6
  static const EdgeInsets authHeaderPadding = EdgeInsets.fromLTRB(24, 32, 24, 24);
  /// Input height from Stitch h-12 (48)
  static const double inputHeight = 48;

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
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMd)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: danger),
        ),
        labelStyle: const TextStyle(
          color: textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 16),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
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

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: accent,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF1E3A5F),
      onPrimaryContainer: accentLight,
      surface: bgDark,
      onSurface: onSurfaceDark,
      onSurfaceVariant: onSurfaceVariantDark,
      outline: borderDark,
      surfaceContainerHighest: surfaceContainerDark,
      error: Color(0xFFEF4444),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: bgDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: onSurfaceDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: onSurfaceDark),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: borderDark),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMd)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: danger),
        ),
        labelStyle: const TextStyle(
          color: onSurfaceVariantDark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(color: onSurfaceVariantDark, fontSize: 16),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
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
          side: const BorderSide(color: borderDark),
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: _textThemeDark,
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

  static const TextTheme _textThemeDark = TextTheme(
    displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: onSurfaceDark, letterSpacing: -0.5, height: 1.1),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: onSurfaceDark),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: onSurfaceDark),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: onSurfaceDark),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: onSurfaceDark),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: onSurfaceDark),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: onSurfaceDark),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: onSurfaceVariantDark),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: onSurfaceDark),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onSurfaceDark),
    labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: onSurfaceVariantDark),
  );
}
