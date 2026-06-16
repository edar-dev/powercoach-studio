import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/locale/app_locale_controller.dart';
import 'package:powercoach_studio/core/routing/root_navigator_key.dart';
import 'package:powercoach_studio/core/routing/route_redirect.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/screens/coach_calendar_screen.dart';
import 'features/dashboard/presentation/screens/coach_dashboard_screen.dart';
import 'features/dashboard/presentation/screens/schedule_detail_screen.dart';
import 'features/dashboard/presentation/screens/schedule_screen.dart';
import 'features/landing/presentation/screens/landing_screen.dart';
import 'theme/stitch_m3_theme.dart';
import 'features/auth/presentation/screens/profile_screen.dart';
import 'features/auth/presentation/screens/registration_screen.dart';
import 'features/customers/presentation/screens/customer_notes_screen.dart';
import 'features/customers/presentation/screens/customer_measurement_history_screen.dart';
import 'features/customers/presentation/screens/customer_creation_screen.dart';
import 'features/customers/presentation/screens/customer_detail_screen.dart';
import 'features/customers/presentation/screens/customer_edit_screen.dart';
import 'features/customers/presentation/screens/customer_list_screen.dart';
import 'features/customers/presentation/screens/customer_workouts_screen.dart';
import 'features/settings/presentation/screens/personal_info_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/settings/presentation/screens/sync_issues_screen.dart';
import 'features/settings/presentation/screens/subscription_screen.dart';
import 'features/workouts/presentation/screens/workout_builder_mobility_screen.dart';
import 'features/workouts/presentation/screens/workout_plan_templates_screen.dart';
import 'features/workouts/presentation/screens/workout_diary_screen.dart';
import 'features/workouts/presentation/screens/coach_stats_screen.dart';
import 'features/exercise_library/presentation/screens/exercise_library_screen.dart';
import 'l10n/app_localizations.dart';

late final GoRouter appGoRouter;

void configureAppRouter() {
  appGoRouter = GoRouter(
  navigatorKey: appRootNavigatorKey,
  initialLocation: '/',
  observers: kReleaseMode ? [SentryNavigatorObserver()] : const <NavigatorObserver>[],
  refreshListenable: SupabaseBootstrap.refreshTick,
  redirect: (context, state) => resolveAppRouteRedirect(state),
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
          path: 'calendar',
          parentNavigatorKey: appRootNavigatorKey,
          builder: (context, state) => const CoachCalendarScreen(),
        ),
        GoRoute(
          path: 'schedule',
          parentNavigatorKey: appRootNavigatorKey,
          builder: (context, state) => const ScheduleScreen(),
          routes: [
            GoRoute(
              path: 'detail',
              parentNavigatorKey: appRootNavigatorKey,
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
          parentNavigatorKey: appRootNavigatorKey,
          builder: (context, state) => const PersonalInfoScreen(),
        ),
        GoRoute(
          path: 'subscription',
          parentNavigatorKey: appRootNavigatorKey,
          builder: (context, state) => const SubscriptionScreen(),
        ),
        GoRoute(
          path: 'sync-issues',
          parentNavigatorKey: appRootNavigatorKey,
          builder: (context, state) => SyncIssuesScreen(
            preselectedOpId: state.uri.queryParameters['opId'],
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/exercise-library',
      builder: (context, state) => const ExerciseLibraryScreen(),
    ),
    GoRoute(
      path: '/customers/new',
      builder: (context, state) => const CustomerCreationScreen(),
    ),
    GoRoute(
      path: '/customers/:id',
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
          routes: [
            GoRoute(
              path: 'new',
              parentNavigatorKey: appRootNavigatorKey,
              builder: (context, state) {
                final customerId = state.pathParameters['id'] ?? '';
                return WorkoutBuilderMobilityScreen(
                  variant: WorkoutBuilderVariant.mobility,
                  customerId: customerId,
                  editorMode: true,
                );
              },
            ),
            GoRoute(
              path: ':planId',
              parentNavigatorKey: appRootNavigatorKey,
              builder: (context, state) {
                final customerId = state.pathParameters['id'] ?? '';
                final planId = state.pathParameters['planId'] ?? '';
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
          path: 'notes',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            final customerName = state.uri.queryParameters['customerName'];
            return CustomerNotesScreen(
              customerId: id,
              customerName: customerName,
            );
          },
        ),
        GoRoute(
          path: 'measurements/history',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            final customerName = state.uri.queryParameters['customerName'];
            return CustomerMeasurementHistoryScreen(
              customerId: id,
              customerName: customerName,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomerListScreen(),
    ),
    GoRoute(
      path: '/workouts',
      builder: (_, __) => const WorkoutBuilderMobilityScreen(variant: WorkoutBuilderVariant.mobility),
      routes: [
        GoRoute(
          path: 'editor',
          parentNavigatorKey: appRootNavigatorKey,
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
              parentNavigatorKey: appRootNavigatorKey,
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
          path: 'templates',
          parentNavigatorKey: appRootNavigatorKey,
          builder: (context, state) => const WorkoutPlanTemplatesScreen(),
        ),
        GoRoute(
          path: 'builder',
          parentNavigatorKey: appRootNavigatorKey,
          builder: (_, __) => const WorkoutBuilderMobilityScreen(variant: WorkoutBuilderVariant.mobility),
          routes: [
            GoRoute(
              path: 'multiset',
              parentNavigatorKey: appRootNavigatorKey,
              builder: (_, __) => const WorkoutBuilderMobilityScreen(variant: WorkoutBuilderVariant.multiset),
            ),
            GoRoute(
              path: 'superset',
              parentNavigatorKey: appRootNavigatorKey,
              builder: (_, __) => const WorkoutBuilderMobilityScreen(variant: WorkoutBuilderVariant.superset),
            ),
            GoRoute(
              path: 'intuitive-superset',
              parentNavigatorKey: appRootNavigatorKey,
              builder: (_, __) => const WorkoutBuilderMobilityScreen(variant: WorkoutBuilderVariant.intuitiveSuperset),
            ),
          ],
        ),
        GoRoute(
          path: 'library',
          parentNavigatorKey: appRootNavigatorKey,
          redirect: (_, __) => '/exercise-library',
        ),
        GoRoute(
          path: 'diary',
          parentNavigatorKey: appRootNavigatorKey,
          builder: (context, state) => const WorkoutDiaryScreen(),
        ),
        GoRoute(
          path: 'stats',
          parentNavigatorKey: appRootNavigatorKey,
          builder: (context, state) => const CoachStatsScreen(),
        ),
      ],
    ),
  ],
  );
}

class PowerCoachStudioApp extends StatelessWidget {
  const PowerCoachStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLocaleController.instance,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'PowerCoach Studio',
          debugShowCheckedModeBanner: false,
          theme: StitchM3Theme.light,
          darkTheme: StitchM3Theme.dark,
          themeMode: ThemeMode.dark,
          locale: AppLocaleController.instance.locale,
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
          routerConfig: appGoRouter,
        );
      },
    );
  }
}
