import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

/// Stitch empty customers list body (concentric rings + onboarding steps).
class CustomerListEmptyBody extends StatelessWidget {
  const CustomerListEmptyBody({
    super.key,
    required this.l10n,
    required this.onImportFromContacts,
  });

  final AppLocalizations l10n;
  final VoidCallback onImportFromContacts;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              const _EmptyConcentricGraphic(),
              const SizedBox(height: 28),
              Text(
                l10n.customersEmptyTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: MarketingDarkColors.text,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.customersEmptyMessage,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: MarketingDarkColors.slate400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => navigateTo(context, '/customers/new'),
                icon: const Icon(Icons.add, size: 20),
                label: Text(l10n.customersAddFirstClient),
                style: FilledButton.styleFrom(
                  backgroundColor: MarketingDarkColors.brand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  elevation: 6,
                  shadowColor:
                      MarketingDarkColors.brand.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      MarketingDarkColors.radiusXl,
                    ),
                    side: BorderSide(
                      color: MarketingDarkColors.brandLight.withValues(
                        alpha: 0.25,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Divider(color: MarketingDarkColors.border, height: 1),
              const SizedBox(height: 16),
              _OnboardingSteps(l10n: l10n),
              if (!kIsWeb) ...[
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: onImportFromContacts,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MarketingDarkColors.slate300,
                    side: const BorderSide(color: MarketingDarkColors.borderMuted),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(l10n.customersImportContacts),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: MarketingDarkColors.brand.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      l10n.customersOfflineFirstFooter,
                      style: const TextStyle(
                        fontSize: 11,
                        color: MarketingDarkColors.slate400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyConcentricGraphic extends StatelessWidget {
  const _EmptyConcentricGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 192,
      height: 192,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 192,
            height: 192,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MarketingDarkColors.surface900.withValues(alpha: 0.4),
              border: Border.all(
                color: MarketingDarkColors.border.withValues(alpha: 0.6),
              ),
            ),
          ),
          Container(
            width: 156,
            height: 156,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF111F38), Color(0xFF0C1526)],
              ),
              border: Border.all(
                color: MarketingDarkColors.brand.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: MarketingDarkColors.brand.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MarketingDarkColors.surface900.withValues(alpha: 0.9),
              border: Border.all(
                color: MarketingDarkColors.brand.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              size: 52,
              color: MarketingDarkColors.brandMid,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSteps extends StatelessWidget {
  const _OnboardingSteps({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final steps = [
      (l10n.customersEmptyStep1Title, l10n.customersEmptyStep1Body),
      (l10n.customersEmptyStep2Title, l10n.customersEmptyStep2Body),
      (l10n.customersEmptyStep3Title, l10n.customersEmptyStep3Body),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 560;
        final cards = [
          for (var i = 0; i < steps.length; i++)
            _StepCard(
              index: i + 1,
              title: steps[i].$1,
              body: steps[i].$2,
            ),
        ];
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }
        return Column(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              cards[i],
            ],
          ],
        );
      },
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.title,
    required this.body,
  });

  final int index;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MarketingDarkColors.surface900.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
        border: Border.all(color: MarketingDarkColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: MarketingDarkColors.brand.withValues(alpha: 0.12),
                  border: Border.all(
                    color: MarketingDarkColors.brand.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: MarketingDarkColors.brandLight,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: MarketingDarkColors.brandLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 12,
              height: 1.35,
              color: MarketingDarkColors.slate400,
            ),
          ),
        ],
      ),
    );
  }
}
