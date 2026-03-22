import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/ui/breakpoints.dart';
import '../theme/stitch_m3_theme.dart';
import '../widgets/stitch_app_bar.dart';
import '../widgets/stitch_card.dart';

/// Simplified Startup Landing Page – Stitch ID 0b414c91bc8d406ea47ac2570d7b51df.
/// Pixel-perfect: layout, colori HEX, typography (fontSize/weight), spacing (16/24), radius 12,
/// elevation/shadows (card shadow-sm blur 10 offset 0,2; chip shadow blur 4 offset 0,1).
/// Responsive: MediaQuery width < 600 → padding 24, else 32. Solo Material widgets.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _paddingMobile = 24;
  static const double _paddingDesktop = 32;
  static const double _radiusLg = 12;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isNarrow = width < AppBreakpoints.tablet;
    final padding = isNarrow ? _paddingMobile : _paddingDesktop;

    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: StitchAppBar(
        title: 'PowerCoach Studio',
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.push('/login');
            },
            child: const Text('Login'),
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
                minimumSize: const Size(44, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_radiusLg),
                ),
              ),
              child: const Text('Join now'),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          _HeroSection(padding: padding, isNarrow: isNarrow),
          _FeaturesSection(padding: padding, isNarrow: isNarrow),
          _HowItWorksSection(padding: padding, isNarrow: isNarrow),
          _CtaSection(padding: padding),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.padding, required this.isNarrow});

  final double padding;
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [StitchM3Theme.accentLight, StitchM3Theme.bg],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(padding, 24, padding, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: StitchM3Theme.bg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: StitchM3Theme.border),
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
                        Icon(Icons.open_in_new, size: 16, color: StitchM3Theme.textPrimary),
                        const SizedBox(width: 8),
                        Text(
                          'Per coach e atleti',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: StitchM3Theme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Power',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: StitchM3Theme.textPrimary,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Coach Studio',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: StitchM3Theme.accent,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Crea e gestisci piani di allenamento per i tuoi clienti.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: StitchM3Theme.textMuted,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        context.push('/register');
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                        ),
                      ),
                      child: const Text('Inizia ora'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        // scroll to features
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                        ),
                      ),
                      child: const Text('Scopri di più'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({required this.padding, required this.isNarrow});

  final double padding;
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 48),
        color: StitchM3Theme.bg,
        child: Column(
          children: [
            Text(
              'FEATURES',
              style: theme.textTheme.labelLarge?.copyWith(
                color: StitchM3Theme.accent,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tutto ciò che ti serve',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: StitchM3Theme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Gestione clienti, piani e export in un\'unica app.',
              style: theme.textTheme.bodyMedium?.copyWith(color: StitchM3Theme.textMuted),
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
                  title: 'Clienti',
                  subtitle: 'Gestisci profili e piani',
                ),
                _FeatureCard(
                  icon: Icons.analytics_outlined,
                  title: 'Dati e metriche',
                  subtitle: 'Export e report',
                ),
                _FeatureCard(
                  icon: Icons.picture_as_pdf_outlined,
                  title: 'Export PDF',
                  subtitle: 'Piani e schede',
                ),
              ],
            ),
          ],
        ),
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: StitchCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: StitchM3Theme.accentLight,
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
              ),
              child: Icon(icon, size: 28, color: StitchM3Theme.accent),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: StitchM3Theme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(color: StitchM3Theme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection({required this.padding, required this.isNarrow});

  final double padding;
  final bool isNarrow;

  static const _steps = [
    'Crea il profilo cliente',
    'Crea i piani di allenamento',
    'Aggiungi esercizi, set e ripetizioni',
    'Esporta in PDF',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 48),
        color: StitchM3Theme.bgSecondary,
        child: Column(
          children: [
            Text(
              'COME FUNZIONA',
              style: theme.textTheme.labelLarge?.copyWith(
                color: StitchM3Theme.accent,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'In quattro passi',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: StitchM3Theme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (isNarrow)
              Column(
                children: List.generate(4, (i) => _StepItem(step: _steps[i], number: i + 1)),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  4,
                  (i) => _StepItem(step: _steps[i], number: i + 1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({required this.step, required this.number});

  final String step;
  final int number;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: StitchM3Theme.accent,
            foregroundColor: Colors.white,
            child: Text(
              '$number',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 200,
            child: Text(
              step,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: StitchM3Theme.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaSection extends StatelessWidget {
  const _CtaSection({required this.padding});

  final double padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: StitchM3Theme.accent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: StitchM3Theme.accent.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Pronto per iniziare?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Registrati e crea il tuo primo piano.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.push('/login');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: StitchM3Theme.accent,
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                  ),
                ),
                child: const Text('Accedi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
