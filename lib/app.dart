import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/screens/coach_dashboard_screen.dart';
import 'features/dashboard/presentation/screens/schedule_detail_screen.dart';
import 'features/dashboard/presentation/screens/schedule_screen.dart';
import 'features/landing/presentation/screens/landing_screen.dart';
import 'theme/stitch_m3_theme.dart';
import 'features/auth/presentation/screens/profile_screen.dart';
import 'features/auth/presentation/screens/registration_screen.dart';
import 'features/customers/presentation/screens/customer_creation_screen.dart';
import 'features/customers/presentation/screens/customer_detail_screen.dart';
import 'features/customers/presentation/screens/customer_edit_screen.dart';
import 'features/customers/presentation/screens/customer_list_screen.dart';
import 'features/customers/presentation/screens/customer_workouts_screen.dart';
import 'features/settings/presentation/screens/personal_info_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/settings/presentation/screens/subscription_screen.dart';
import 'features/workouts/presentation/screens/workout_builder_mobility_screen.dart';
import 'features/workouts/presentation/screens/workout_placeholder_screen.dart';
import 'l10n/app_localizations.dart';

final _goRouter = GoRouter(
  initialLocation: '/',
  observers: [SentryNavigatorObserver()],
  redirect: (context, state) {
    final path = state.uri.path;
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    final isCustomerRoute = path.startsWith('/customers');
    final isProtectedRoute = isCustomerRoute || path.startsWith('/dashboard') || path.startsWith('/workouts') || path == '/profile' || path.startsWith('/settings');
    if (isProtectedRoute && !isLoggedIn) {
      return '/login';
    }
    if (isLoggedIn && (path == '/' || path == '/login')) {
      return '/dashboard';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
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
      path: '/dashboard',
      builder: (context, state) => const CoachDashboardScreen(),
      routes: [
        GoRoute(
          path: 'schedule',
          builder: (context, state) => const ScheduleScreen(),
          routes: [
            GoRoute(
              path: 'detail',
              builder: (context, state) => const ScheduleDetailScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'personal-info',
          builder: (context, state) => const PersonalInfoScreen(),
        ),
        GoRoute(
          path: 'subscription',
          builder: (context, state) => const SubscriptionScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomerListScreen(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const CustomerCreationScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return CustomerDetailScreen(customerId: id);
          },
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                return CustomerEditScreen(customerId: id);
              },
            ),
            GoRoute(
              path: 'workouts',
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                return CustomerWorkoutsScreen(customerId: id);
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/workouts',
      builder: (_, __) => const WorkoutBuilderMobilityScreen(variant: WorkoutBuilderVariant.mobility),
      routes: [
        GoRoute(
          path: 'editor',
          builder: (context, state) {
            final customerId = state.uri.queryParameters['customerId'];
            return WorkoutBuilderMobilityScreen(
              variant: WorkoutBuilderVariant.mobility,
              customerId: customerId,
              editorMode: true,
            );
          },
          routes: [
            GoRoute(
              path: ':planId',
              builder: (context, state) {
                final planId = state.pathParameters['planId'];
                final customerId = state.uri.queryParameters['customerId'];
                return WorkoutBuilderMobilityScreen(
                  variant: WorkoutBuilderVariant.mobility,
                  customerId: customerId,
                  planId: planId,
                  editorMode: true,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: 'builder',
          builder: (_, __) => const WorkoutBuilderMobilityScreen(variant: WorkoutBuilderVariant.mobility),
          routes: [
            GoRoute(
              path: 'multiset',
              builder: (_, __) => const WorkoutBuilderMobilityScreen(variant: WorkoutBuilderVariant.multiset),
            ),
            GoRoute(
              path: 'superset',
              builder: (_, __) => const WorkoutBuilderMobilityScreen(variant: WorkoutBuilderVariant.superset),
            ),
            GoRoute(
              path: 'intuitive-superset',
              builder: (_, __) => const WorkoutBuilderMobilityScreen(variant: WorkoutBuilderVariant.intuitiveSuperset),
            ),
          ],
        ),
        GoRoute(
          path: 'library',
          builder: (_, __) => const WorkoutPlaceholderScreen(title: 'Library'),
        ),
        GoRoute(
          path: 'diary',
          builder: (_, __) => const WorkoutPlaceholderScreen(title: 'Diary'),
        ),
        GoRoute(
          path: 'stats',
          builder: (_, __) => const WorkoutPlaceholderScreen(title: 'Stats'),
        ),
      ],
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
      theme: StitchM3Theme.light,
      darkTheme: StitchM3Theme.dark,
      themeMode: ThemeMode.dark,
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
