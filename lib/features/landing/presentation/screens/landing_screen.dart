import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/not_implemented.dart';
import '../../../../l10n/app_localizations.dart';

/// Landing page matching Stitch prototype: navbar, hero (chip, title, CTAs),
/// features, how it works, CTA section.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final GlobalKey _featuresKey = GlobalKey();
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        scrolledUnderElevation: 2,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black26,
        title: Row(
          children: [
            // Logo badge: gradient blue → purple "PCS" (design spec)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.logoStart, AppTheme.logoEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              alignment: Alignment.center,
              child: const Text(
                'PCS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.appTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppTheme.border,
            height: 1,
          ),
        ),
        actions: [
          if (isLoggedIn) ...[
            TextButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.push('/customers');
              },
              icon: const Icon(Icons.people_outline, size: 20),
              label: Text(l10n.customersTitle),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.push('/profile');
                },
                icon: const Icon(Icons.person_outline, size: 20),
                label: Text(l10n.headerProfile),
              ),
            ),
          ]
          else ...[
            TextButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.push('/login');
              },
              child: Text(l10n.headerLogin),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.push('/register');
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n.headerJoinNow),
              ),
            ),
          ],
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Hero – CTA "Inizia ora" va al profilo se loggato, alla registrazione altrimenti
          SliverToBoxAdapter(
            child: _HeroSection(
              heroBadge: l10n.landingHeroBadge,
              titlePrefix: l10n.landingTitlePrefix,
              titleSuffix: l10n.landingTitleSuffix,
              subtitle: l10n.landingSubtitle,
              ctaPrimary: isLoggedIn
                  ? l10n.landingCtaSectionButtonLoggedIn
                  : l10n.landingCtaPrimary,
              ctaSecondary: l10n.landingCtaSecondary,
              onPrimary: () {
                HapticFeedback.mediumImpact();
                if (isLoggedIn) {
                  context.push('/profile');
                } else {
                  context.push('/register');
                }
              },
              onSecondary: () {
                HapticFeedback.mediumImpact();
                final ctx = _featuresKey.currentContext;
                if (ctx != null) {
                  Scrollable.ensureVisible(
                    ctx,
                    alignment: 0.2,
                    duration: const Duration(milliseconds: 500),
                  );
                } else {
                  showNotImplementedAlert(context);
                }
              },
            ),
          ),
          // Features
          SliverToBoxAdapter(
            key: _featuresKey,
            child: _FeaturesSection(l10n: l10n),
          ),
          // How it works
          SliverToBoxAdapter(
            child: _HowItWorksSection(l10n: l10n),
          ),
          // CTA – testo e pulsante diversi se l'utente è loggato
          SliverToBoxAdapter(
            child: _CtaSection(
              title: l10n.landingCtaSectionTitle,
              subtext: isLoggedIn
                  ? l10n.landingCtaSectionSubtextLoggedIn
                  : l10n.landingCtaSectionSubtext,
              buttonLabel: isLoggedIn
                  ? l10n.landingCtaSectionButtonLoggedIn
                  : l10n.landingCtaSectionButton,
              onCta: () {
                HapticFeedback.mediumImpact();
                if (isLoggedIn) {
                  context.push('/profile');
                } else {
                  context.push('/login');
                }
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.heroBadge,
    required this.titlePrefix,
    required this.titleSuffix,
    required this.subtitle,
    required this.ctaPrimary,
    required this.ctaSecondary,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String heroBadge;
  final String titlePrefix;
  final String titleSuffix;
  final String subtitle;
  final String ctaPrimary;
  final String ctaSecondary;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Design spec: Hero background gradient from blue-50 to white
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.accentLight, AppTheme.bg],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chip: light background, dark text (design spec)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.bg,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: AppTheme.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        heroBadge,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Title: design spec – text-4xl, bold, "Power" dark, "Coach Studio" accent
              Text(
                titlePrefix,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              Text(
                titleSuffix,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accent,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                subtitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 32),
              // CTAs: design spec – min-height 44px, rounded-xl
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    onPressed: onPrimary,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      minimumSize: const Size(44, 44),
                      textStyle: theme.textTheme.titleMedium,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      ),
                    ),
                    child: Text(ctaPrimary),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: onSecondary,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accent,
                      side: const BorderSide(color: AppTheme.border),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      minimumSize: const Size(44, 44),
                      textStyle: theme.textTheme.titleMedium,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      ),
                    ),
                    child: Text(ctaSecondary),
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

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: const BoxDecoration(
        color: AppTheme.bg,
      ),
      child: Column(
        children: [
          Text(
            l10n.landingFeaturesTitle.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppTheme.accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.landingFeaturesHeadline,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.landingFeaturesDesc,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _FeatureCard(
                icon: Icons.people_outline,
                title: l10n.landingFeaturesCustomers,
                subtitle: l10n.landingFeaturesEditor,
              ),
              _FeatureCard(
                icon: Icons.analytics_outlined,
                title: l10n.landingFeaturesClientData,
                subtitle: l10n.landingFeaturesExport,
              ),
              _FeatureCard(
                icon: Icons.picture_as_pdf_outlined,
                title: l10n.landingFeaturesExport,
                subtitle: l10n.landingFeaturesEditor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Design spec: Cards white, rounded-xl, shadow-sm, border gray-200
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.accentLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Icon(icon, size: 28, color: AppTheme.accent),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final steps = [
      l10n.landingHowItWorksStep1,
      l10n.landingHowItWorksStep2,
      l10n.landingHowItWorksStep3,
      l10n.landingHowItWorksStep4,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: const BoxDecoration(
        color: AppTheme.bgSecondary,
      ),
      child: Column(
        children: [
          Text(
            l10n.landingHowItWorksLabel.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppTheme.accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.landingHowItWorksTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return isWide
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        4,
                        (i) => _StepItem(
                          step: steps[i],
                          number: i + 1,
                          colorScheme: colorScheme,
                          theme: theme,
                        ),
                      ),
                    )
                  : Column(
                      children: List.generate(
                        4,
                        (i) => _StepItem(
                          step: steps[i],
                          number: i + 1,
                          colorScheme: colorScheme,
                          theme: theme,
                        ),
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.step,
    required this.number,
    required this.colorScheme,
    required this.theme,
  });

  final String step;
  final int number;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            child: Text(
              '$number',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 200,
            child: Text(
              step,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaSection extends StatelessWidget {
  const _CtaSection({
    required this.title,
    required this.subtext,
    required this.buttonLabel,
    required this.onCta,
  });

  final String title;
  final String subtext;
  final String buttonLabel;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Design spec: CTA full-width bg-blue-600, white text, CTA button
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtext,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onCta,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.accent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  minimumSize: const Size(44, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: Text(buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
