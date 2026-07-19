import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';

/// Navigation drawer for the coach dashboard shell.
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
                if (context.mounted) context.go('/dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text(AppLocalizations.of(context).calendarTitle),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) context.push('/dashboard/calendar');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: Text(AppLocalizations.of(context).customersTitle),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) context.go('/customers');
              },
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: Text(AppLocalizations.of(context).dashboardWorkoutBuilderDraft),
              subtitle: Text(AppLocalizations.of(context).dashboardWorkoutBuilder),
              isThreeLine: true,
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) navigateTo(context, '/workouts/builder');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: Text(
                AppLocalizations.of(context).workoutTemplatesDrawerLabel,
              ),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) navigateTo(context, '/workouts/templates');
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books_outlined),
              title: Text(AppLocalizations.of(context).exerciseLibraryTitle),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) navigateTo(context, '/exercise-library');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(AppLocalizations.of(context).headerProfile),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) navigateTo(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(AppLocalizations.of(context).settingsTitle),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) navigateTo(context, '/settings');
              },
            ),
          ],
        ),
      ),
    );
  }
}
