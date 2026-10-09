import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/routing/app_paths.dart';
import 'package:powercoach_studio/core/routing/root_navigator_key.dart';
import 'package:powercoach_studio/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:powercoach_studio/features/auth/presentation/screens/login_screen.dart';
import 'package:powercoach_studio/features/auth/presentation/screens/registration_screen.dart';
import 'package:powercoach_studio/features/customers/presentation/screens/customer_creation_screen.dart';
import 'package:powercoach_studio/features/customers/presentation/screens/customer_detail_screen.dart';
import 'package:powercoach_studio/features/customers/presentation/screens/customer_edit_screen.dart';
import 'package:powercoach_studio/features/customers/presentation/screens/customer_list_screen.dart';
import 'package:powercoach_studio/features/customers/presentation/screens/customer_measurement_history_screen.dart';
import 'package:powercoach_studio/features/customers/presentation/screens/customer_notes_screen.dart';
import 'package:powercoach_studio/features/customers/presentation/screens/customer_workouts_screen.dart';
import 'package:powercoach_studio/features/dashboard/presentation/screens/coach_calendar_screen.dart';
import 'package:powercoach_studio/features/dashboard/presentation/screens/coach_dashboard_screen.dart';
import 'package:powercoach_studio/features/dashboard/presentation/screens/schedule_detail_screen.dart';
import 'package:powercoach_studio/features/exercise_library/presentation/screens/exercise_library_screen.dart';
import 'package:powercoach_studio/features/landing/presentation/screens/landing_screen.dart';
import 'package:powercoach_studio/features/settings/presentation/screens/data_health_screen.dart';
import 'package:powercoach_studio/features/settings/presentation/screens/pdf_brand_settings_screen.dart';
import 'package:powercoach_studio/features/settings/presentation/screens/personal_info_screen.dart';
import 'package:powercoach_studio/features/settings/presentation/screens/settings_screen.dart';
import 'package:powercoach_studio/features/settings/presentation/screens/subscription_screen.dart';
import 'package:powercoach_studio/features/workouts/presentation/screens/workout_builder_mobility_screen.dart';
import 'package:powercoach_studio/features/workouts/presentation/screens/workout_diary_screen.dart';
import 'package:powercoach_studio/features/workouts/presentation/screens/workout_diary_entry_screen.dart';
import 'package:powercoach_studio/core/constants/workout_plan_template_scope.dart';

List<RouteBase> buildAppRoutes() {
  return [
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
      routes: [
        // Legacy post-signup URL; public registration removed (invite-only).
        GoRoute(
          path: 'check-email',
          redirect: (context, state) => '/register',
        ),
      ],
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
        // List hub removed (Wave C); keep detail for calendar/today session log.
        GoRoute(
          path: 'schedule',
          parentNavigatorKey: appRootNavigatorKey,
          redirect: (context, state) {
            if (state.uri.path == '/dashboard/schedule') {
              final query = state.uri.query;
              return query.isEmpty
                  ? '/dashboard/calendar'
                  : '/dashboard/calendar?$query';
            }
            return null;
          },
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
      redirect: (context, state) {
        final query = state.uri.query;
        return query.isEmpty
            ? AppPaths.personalInfo
            : '${AppPaths.personalInfo}?$query';
      },
    ),
    GoRoute(
      path: AppPaths.subscription,
      parentNavigatorKey: appRootNavigatorKey,
      builder: (context, state) => const SubscriptionScreen(),
    ),
    GoRoute(
      path: '/gym',
      redirect: (context, state) {
        final query = state.uri.query;
        return query.isEmpty ? '/dashboard' : '/dashboard?$query';
      },
      routes: [
        GoRoute(
          path: 'session',
          redirect: (context, state) {
            final query = state.uri.query;
            return query.isEmpty ? '/dashboard' : '/dashboard?$query';
          },
        ),
      ],
    ),
    GoRoute(
      path: '/plans/diff',
      redirect: (context, state) {
        final query = state.uri.query;
        return query.isEmpty ? '/customers' : '/customers?$query';
      },
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
          path: 'pdf-brand',
          parentNavigatorKey: appRootNavigatorKey,
          builder: (context, state) => const PdfBrandSettingsScreen(),
        ),
        GoRoute(
          path: 'data-health',
          parentNavigatorKey: appRootNavigatorKey,
          builder: (context, state) => const DataHealthScreen(),
        ),
        GoRoute(
          path: 'subscription',
          parentNavigatorKey: appRootNavigatorKey,
          redirect: (context, state) {
            final query = state.uri.query;
            return query.isEmpty
                ? AppPaths.subscription
                : '${AppPaths.subscription}?$query';
          },
        ),
        GoRoute(
          path: 'release-notes',
          parentNavigatorKey: appRootNavigatorKey,
          redirect: (context, state) {
            final query = state.uri.query;
            return query.isEmpty
                ? AppPaths.settings
                : '${AppPaths.settings}?$query';
          },
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
      redirect: (context, state) {
        if (state.uri.path == '/workouts') {
          return '/workouts/builder';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: 'editor',
          parentNavigatorKey: appRootNavigatorKey,
          redirect: (context, state) {
            // Legacy template-scope editor bookmarks → sandbox builder.
            if (state.uri.queryParameters['customerId'] ==
                kWorkoutPlanTemplateScopeId) {
              return '/workouts/builder';
            }
            return null;
          },
          builder: (context, state) {
            final customerId = state.uri.queryParameters['customerId'];
            return WorkoutBuilderMobilityScreen(
              customerId: customerId,
              editorMode: true,
            );
          },
          routes: [
            GoRoute(
              path: ':planId',
              parentNavigatorKey: appRootNavigatorKey,
              redirect: (context, state) {
                if (state.uri.queryParameters['customerId'] ==
                    kWorkoutPlanTemplateScopeId) {
                  return '/workouts/builder';
                }
                return null;
              },
              builder: (context, state) {
                final planId = state.pathParameters['planId'];
                final customerId = state.uri.queryParameters['customerId'];
                return WorkoutBuilderMobilityScreen(
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
          // Legacy bookmarks for removed template library.
          redirect: (context, state) => '/workouts/builder',
        ),
        GoRoute(
          path: 'builder',
          parentNavigatorKey: appRootNavigatorKey,
          builder: (_, _) => const WorkoutBuilderMobilityScreen(),
        ),
        GoRoute(
          path: 'library',
          parentNavigatorKey: appRootNavigatorKey,
          redirect: (context, state) {
            final query = state.uri.query;
            return query.isEmpty
                ? '/exercise-library'
                : '/exercise-library?$query';
          },
        ),
        GoRoute(
          path: 'diary',
          parentNavigatorKey: appRootNavigatorKey,
          builder: (context, state) => const WorkoutDiaryScreen(),
          routes: [
            GoRoute(
              path: ':planId/:sessionKey',
              parentNavigatorKey: appRootNavigatorKey,
              builder: (context, state) => WorkoutDiaryEntryScreen(
                planId: state.pathParameters['planId'] ?? '',
                sessionKey: state.pathParameters['sessionKey'] ?? '',
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'stats',
          parentNavigatorKey: appRootNavigatorKey,
          redirect: (context, state) {
            final query = state.uri.query;
            return query.isEmpty
                ? '/workouts/diary'
                : '/workouts/diary?$query';
          },
        ),
      ],
    ),
  ];
}
