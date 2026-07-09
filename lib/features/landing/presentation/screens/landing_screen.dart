import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/landing_cta_section.dart';
import '../widgets/landing_features_section.dart';
import '../widgets/landing_hero_section.dart';
import '../widgets/landing_how_it_works_section.dart';
import '../widgets/landing_screen_app_bar.dart';

/// Landing page matching Stitch prototype: navbar, hero (chip, title, CTAs),
/// features, how it works, CTA section.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final GlobalKey _featuresKey = GlobalKey();
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
    for (var stage = 1; stage <= 3; stage++) {
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
      appBar: LandingScreenAppBar(isLoggedIn: isLoggedIn),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: LandingHeroSection(
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
                  navigateTo(context, '/profile');
                } else {
                  navigateTo(context, '/register');
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
                }
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
              child: LandingCtaSection(
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
                    navigateTo(context, '/profile');
                  } else {
                    navigateTo(context, '/login');
                  }
                },
              ),
            )
          else
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }
}
