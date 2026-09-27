import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

/// Stitch dark hero for new-customer form.
class CustomerCreationHeroBanner extends StatelessWidget {
  const CustomerCreationHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl),
        border: Border.all(
          color: const Color(0xFF1E3A5F).withValues(alpha: 0.5),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF141E33), Color(0xFF101726)],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MarketingDarkColors.brand,
                  MarketingDarkColors.brandLight,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: MarketingDarkColors.brand.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.person_add, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.customerCreationHeroTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: MarketingDarkColors.text,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.customerCreationHeroSubtitle,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: MarketingDarkColors.slate400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
