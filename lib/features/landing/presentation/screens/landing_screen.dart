import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    final colorScheme = theme.colorScheme;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.appTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
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
              colorScheme: colorScheme,
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
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chip: light background, dark text, icon = two arrows out (expansion)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: colorScheme.onSurface,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        heroBadge,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Title: "Power" dark, "Coach Studio" accent – left-aligned
              Text(
                titlePrefix,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              Text(
                titleSuffix,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                subtitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              // CTAs centered
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    onPressed: onPrimary,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: theme.textTheme.titleMedium,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(ctaPrimary),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: onSecondary,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: theme.textTheme.titleMedium,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: colorScheme.surface,
      ),
      child: Column(
        children: [
          Text(
            l10n.landingFeaturesTitle.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.landingFeaturesHeadline,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.landingFeaturesDesc,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
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
                color: colorScheme.primaryContainer,
              ),
              _FeatureCard(
                icon: Icons.analytics_outlined,
                title: l10n.landingFeaturesClientData,
                subtitle: l10n.landingFeaturesExport,
                color: colorScheme.tertiaryContainer,
              ),
              _FeatureCard(
                icon: Icons.picture_as_pdf_outlined,
                title: l10n.landingFeaturesExport,
                subtitle: l10n.landingFeaturesEditor,
                color: colorScheme.secondaryContainer,
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
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
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
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: colorScheme.primary),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
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
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Column(
        children: [
          Text(
            l10n.landingHowItWorksLabel.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.landingHowItWorksTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
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
                color: colorScheme.onSurfaceVariant,
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
    required this.colorScheme,
  });

  final String title;
  final String subtext;
  final String buttonLabel;
  final VoidCallback onCta;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 4,
        color: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtext,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: onCta,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.onPrimary,
                  foregroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
