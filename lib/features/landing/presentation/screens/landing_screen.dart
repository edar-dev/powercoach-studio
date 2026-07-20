import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/routing/app_paths.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/landing_cta_section.dart';
import '../widgets/landing_faq_section.dart';
import '../widgets/landing_features_section.dart';
import '../widgets/landing_footer_section.dart';
import '../widgets/landing_hero_section.dart';
import '../widgets/landing_how_it_works_section.dart';
import '../widgets/landing_pricing_section.dart';
import '../widgets/landing_pwa_hint_section.dart';
import '../widgets/landing_screen_app_bar.dart';

/// Landing page: hero, features, pricing, FAQ, beta/PWA hints, legal footer.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();
  StreamSubscription<dynamic>? _authSubscription;
  int _deferredSectionsStage = 0;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = SupabaseBootstrap.currentUser != null;
    _bindAuthState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_revealDeferredSections());
    });
  }

  Future<void> _revealDeferredSections() async {
    for (var stage = 1; stage <= 6; stage++) {
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 16));
      if (!mounted) return;
      setState(() {
        _deferredSectionsStage = stage;
      });
    }
  }

  Future<void> _bindAuthState() async {
    await SupabaseBootstrap.ensureInitialized();
    if (!mounted) return;
    final initialLoggedIn = SupabaseBootstrap.currentUser != null;
    if (initialLoggedIn != _isLoggedIn) {
      setState(() {
        _isLoggedIn = initialLoggedIn;
      });
    }
    try {
      final stream = Supabase.instance.client.auth.onAuthStateChange;
      _authSubscription = stream.listen((_) {
        if (!mounted) return;
        final nextLoggedIn = SupabaseBootstrap.currentUser != null;
        if (nextLoggedIn == _isLoggedIn) return;
        setState(() {
          _isLoggedIn = nextLoggedIn;
        });
      });
    } catch (_) {
      // Ignore when auth is not ready yet.
    }
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.08,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _navigateStartFree() {
    HapticFeedback.mediumImpact();
    if (_isLoggedIn) {
      navigateTo(context, '/customers');
    } else {
      navigateTo(context, '/register');
    }
  }

  void _navigateUpgradePro() {
    HapticFeedback.mediumImpact();
    if (_isLoggedIn) {
      navigateTo(context, AppPaths.subscription);
    } else {
      navigateTo(context, '/register');
    }
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
    final isLoggedIn = _isLoggedIn;
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: LandingScreenAppBar(
        isLoggedIn: isLoggedIn,
        onScrollToPricing: () {
          HapticFeedback.mediumImpact();
          _scrollTo(_pricingKey);
        },
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: LandingHeroSection(
              heroBadge: l10n.landingBetaBadge,
              titlePrefix: l10n.landingTitlePrefix,
              titleSuffix: l10n.landingTitleSuffix,
              subtitle: l10n.landingSubtitle,
              ctaPrimary: isLoggedIn
                  ? l10n.landingCtaSectionButtonLoggedIn
                  : l10n.landingCtaStartFree,
              ctaSecondary: l10n.landingCtaSeePricing,
              onPrimary: () {
                HapticFeedback.mediumImpact();
                if (isLoggedIn) {
                  navigateTo(context, '/profile');
                } else {
                  navigateTo(context, '/register');
                }
              },
              onSecondary: () {
                HapticFeedback.mediumImpact();
                _scrollTo(_pricingKey);
              },
            ),
          ),
          if (_deferredSectionsStage >= 1)
            SliverToBoxAdapter(
              key: _featuresKey,
              child: LandingFeaturesSection(l10n: l10n),
            ),
          if (_deferredSectionsStage >= 2)
            SliverToBoxAdapter(
              child: LandingHowItWorksSection(l10n: l10n),
            ),
          if (_deferredSectionsStage >= 3)
            SliverToBoxAdapter(
              key: _pricingKey,
              child: LandingPricingSection(
                l10n: l10n,
                isLoggedIn: isLoggedIn,
                onStartFree: _navigateStartFree,
                onUpgradePro: _navigateUpgradePro,
              ),
            ),
          if (_deferredSectionsStage >= 4)
            SliverToBoxAdapter(
              child: LandingFaqSection(l10n: l10n),
            ),
          if (_deferredSectionsStage >= 5)
            SliverToBoxAdapter(
              child: LandingCtaSection(
                title: l10n.landingCtaSectionTitle,
                subtext: isLoggedIn
                    ? l10n.landingCtaSectionSubtextLoggedIn
                    : l10n.landingPricingSubtitle,
                buttonLabel: isLoggedIn
                    ? l10n.landingPricingProCtaLoggedIn
                    : l10n.landingCtaStartFree,
                onCta: () {
                  if (isLoggedIn) {
                    navigateTo(context, AppPaths.subscription);
                  } else {
                    _navigateStartFree();
                  }
                },
              ),
            )
          else
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          if (_deferredSectionsStage >= 6) ...[
            SliverToBoxAdapter(child: LandingPwaHintSection(l10n: l10n)),
            SliverToBoxAdapter(child: LandingFooterSection(l10n: l10n)),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }
}
