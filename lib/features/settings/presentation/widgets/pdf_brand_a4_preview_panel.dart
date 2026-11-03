import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Live A4-style PDF preview driven by brand kit fields.
class PdfBrandA4PreviewPanel extends StatelessWidget {
  const PdfBrandA4PreviewPanel({
    super.key,
    required this.studioName,
    required this.accentColor,
    required this.disclaimer,
    required this.hidePowerCoachBranding,
    this.logoBytes,
  });

  final String studioName;
  final Color accentColor;
  final String disclaimer;
  final bool hidePowerCoachBranding;
  final Uint8List? logoBytes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat.yMMMd(locale).format(DateTime.now());
    final resolvedName =
        studioName.trim().isEmpty ? l10n.pdfBrandName : studioName.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.pdfBrandPreviewTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: MarketingDarkColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: MarketingDarkColors.stitchCardElevated,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: MarketingDarkColors.stitchBorderMuted,
                ),
              ),
              child: Text(
                l10n.pdfBrandPreviewA4Badge,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: MarketingDarkColors.slate300,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 210 / 297,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: MarketingDarkColors.stitchBorderMuted),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 4,
                    color: accentColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LogoMark(
                          logoBytes: logoBytes,
                          accentColor: accentColor,
                          studioName: resolvedName,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resolvedName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.pdfBrandPreviewDocType,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              l10n.pdfBrandPreviewDateLabel.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 7,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateLabel,
                              style: const TextStyle(
                                color: Color(0xFF374151),
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        for (var i = 0; i < 3; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 5,
                                  width: 36,
                                  color: const Color(0xFFD1D5DB),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 7,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < 6; i++) ...[
                            if (i > 0) const SizedBox(height: 8),
                            FractionallySizedBox(
                              widthFactor: i.isEven ? 1 : 0.72,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          for (var i = 0; i < 3; i++) ...[
                            const SizedBox(height: 6),
                            Container(
                              height: 22,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        const SizedBox(height: 8),
                        Text(
                          disclaimer.trim().isNotEmpty
                              ? disclaimer.trim()
                              : (hidePowerCoachBranding
                                  ? resolvedName
                                  : l10n.pdfBrandName),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.pdfBrandPreviewLiveNote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: MarketingDarkColors.slate400,
          ),
        ),
      ],
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({
    required this.logoBytes,
    required this.accentColor,
    required this.studioName,
  });

  final Uint8List? logoBytes;
  final Color accentColor;
  final String studioName;

  @override
  Widget build(BuildContext context) {
    if (logoBytes != null && logoBytes!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.memory(
          logoBytes!,
          width: 34,
          height: 34,
          fit: BoxFit.contain,
        ),
      );
    }

    final initials = _initials(studioName);
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: accentColor == StitchM3Theme.accent
              ? StitchM3Theme.accent
              : accentColor,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'PC';
    if (parts.length == 1) {
      final s = parts.first;
      return s.substring(0, s.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
