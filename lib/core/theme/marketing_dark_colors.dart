import 'package:flutter/material.dart';

/// Shared dark marketing palette (landing + auth) from Stitch dark HTML themes.
///
/// Logged-in app surfaces keep [StitchM3Theme] tokens unchanged.
abstract final class MarketingDarkColors {
  static const Color bg = Color(0xFF070B13);
  static const Color bgAlt = Color(0xFF080C14);
  static const Color bgDeep = Color(0xFF070A12);
  static const Color surface = Color(0xFF0F172A);
  static const Color surfaceElevated = Color(0xFF0C1220);
  static const Color surfaceSubtle = Color(0xFF182235);
  static const Color surfaceRow = Color(0xFF0E1628);
  static const Color surfaceInput = Color(0xFF131E33);
  static const Color surface900 = Color(0xFF070B13);
  static const Color surface800 = Color(0xFF11192B);
  static const Color surface700 = Color(0xFF1A243A);

  static const Color border = Color(0xFF1E293B);
  static const Color borderMuted = Color(0xFF334155);
  static const Color borderSubtle = Color(0xFF24344D);

  static const Color text = Color(0xFFF1F5F9);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textDim = Color(0xFF64748B);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);

  static const Color brand = Color(0xFF2563EB);
  static const Color brandMid = Color(0xFF3B82F6);
  static const Color brandLight = Color(0xFF60A5FA);
  static const Color brandSoft = Color(0xFF93C5FD);

  static const Color emerald = Color(0xFF34D399);
  static const Color emeraldBorder = Color(0x3334D399);
  static const Color emeraldBg = Color(0x66064E3B);

  static const Color amber = Color(0xFFFBBF24);
  static const Color amberSoft = Color(0xFFFCD34D);

  static const Color indigo = Color(0xFF818CF8);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color cyanBright = Color(0xFF06B6D4);
  static const Color cyanHover = Color(0xFF0891B2);
  static const Color cyanOn = Color(0xFF09101A);

  /// Stitch redesign page canvases — aligned with [StitchMobileColors] M3 tokens.
  static const Color stitchPageBg = Color(0xFF0F131C);
  static const Color stitchPageBgAlt = Color(0xFF0A0E16);
  static const Color stitchCard = Color(0xFF1C2028);
  static const Color stitchCardElevated = Color(0xFF262A33);
  static const Color stitchInput = Color(0xFF181C24);
  static const Color stitchBorder = Color(0xFF8C909F);
  static const Color stitchBorderMuted = Color(0xFF31353E);

  static const double radiusXl = 12;
  static const double radius2xl = 16;
  static const double radius3xl = 24;

  static const double authCardMaxWidthLogin = 480;
  static const double authCardMaxWidthRegister = 560;
}
