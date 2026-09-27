export '../../../core/theme/marketing_dark_colors.dart';

import 'package:flutter/material.dart';

import '../../../core/theme/marketing_dark_colors.dart';

/// Landing-only alias for [MarketingDarkColors] (Stitch landing dark theme).
///
/// Prefer [MarketingDarkColors] in new shared marketing/auth code.
abstract final class LandingColors {
  /// Landing page base (Stitch landing-dark); auth uses [MarketingDarkColors.bg].
  static const bg = Color(0xFF090D16);
  static const bgDeep = MarketingDarkColors.bgDeep;
  static const surface = MarketingDarkColors.surface;
  static const surfaceElevated = MarketingDarkColors.surfaceElevated;
  static const surfaceSubtle = MarketingDarkColors.surfaceSubtle;
  static const surfaceRow = MarketingDarkColors.surfaceRow;
  static const border = MarketingDarkColors.border;
  static const borderMuted = MarketingDarkColors.borderMuted;

  static const text = MarketingDarkColors.text;
  static const textMuted = MarketingDarkColors.textMuted;
  static const textDim = MarketingDarkColors.textDim;
  static const slate300 = MarketingDarkColors.slate300;

  static const brand = MarketingDarkColors.brand;
  static const brandMid = MarketingDarkColors.brandMid;
  static const brandLight = MarketingDarkColors.brandLight;
  static const brandSoft = MarketingDarkColors.brandSoft;

  static const emerald = MarketingDarkColors.emerald;
  static const emeraldBorder = MarketingDarkColors.emeraldBorder;
  static const emeraldBg = MarketingDarkColors.emeraldBg;

  static const indigo = MarketingDarkColors.indigo;
  static const cyan = MarketingDarkColors.cyan;

  static const radiusXl = MarketingDarkColors.radiusXl;
  static const radius2xl = MarketingDarkColors.radius2xl;
  static const radius3xl = MarketingDarkColors.radius3xl;
}
