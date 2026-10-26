import 'package:flutter/material.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/routing/app_paths.dart';
import '../../../../l10n/app_localizations.dart';

/// Legacy navigation drawer (unused by primary hubs after shell IA).
///
/// Kept for reference / possible deep-link tooling; hubs use
/// [PrimaryShellScaffold] instead.
class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: Text(AppLocalizations.of(context).dashboardTitle),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) {
                  navigateTo(context, AppPaths.dashboard);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text(AppLocalizations.of(context).calendarTitle),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) {
                  navigateTo(context, AppPaths.calendar);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: Text(AppLocalizations.of(context).customersTitle),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) {
                  navigateTo(context, AppPaths.customers);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: Text(
                AppLocalizations.of(context).dashboardWorkoutBuilderDraft,
              ),
              subtitle: Text(
                AppLocalizations.of(context).dashboardWorkoutBuilder,
              ),
              isThreeLine: true,
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) {
                  navigateTo(context, AppPaths.workoutBuilder);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books_outlined),
              title: Text(AppLocalizations.of(context).exerciseLibraryTitle),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) {
                  navigateTo(context, AppPaths.exerciseLibrary);
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(AppLocalizations.of(context).headerProfile),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) {
                  navigateTo(context, AppPaths.personalInfo);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(AppLocalizations.of(context).settingsTitle),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) {
                  navigateTo(context, AppPaths.settings);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
