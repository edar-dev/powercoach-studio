import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/profile_screen.dart';
import 'features/auth/presentation/screens/registration_screen.dart';
import 'features/landing/presentation/screens/landing_screen.dart';
import 'l10n/app_localizations.dart';

final _goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);

class PowerCoachStudioApp extends StatelessWidget {
  const PowerCoachStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PowerCoach Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B6EE8),
          brightness: Brightness.light,
        ).copyWith(
          surface: const Color(0xFFF8F7FC),
          surfaceContainerHighest: const Color(0xFFEBE9F2),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F7FC),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B6EE8),
          brightness: Brightness.dark,
        ).copyWith(surface: const Color(0xFF1C1B2E)),
      ),
      locale: const Locale('it'),
      supportedLocales: const [
        Locale('it'),
        Locale('en'),
      ],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeResolutionCallback: (locale, supported) {
        if (locale != null) {
          for (final s in supported) {
            if (s.languageCode == locale.languageCode) return s;
          }
        }
        return const Locale('it');
      },
      routerConfig: _goRouter,
    );
  }
}
