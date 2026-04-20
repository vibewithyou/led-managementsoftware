import 'package:flutter/material.dart';
import 'package:led_managementsoftware_app/core/config/backend_runtime.dart';
import 'package:led_managementsoftware_app/core/routing/app_section.dart';
import 'package:led_managementsoftware_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:led_managementsoftware_app/features/live_control/presentation/live_control_screen.dart';
import 'package:led_managementsoftware_app/features/media_library/presentation/media_library_screen.dart';
import 'package:led_managementsoftware_app/features/projects/presentation/projects_screen.dart';
import 'package:led_managementsoftware_app/features/settings/presentation/settings_screen.dart';

class AppRouter {
  const AppRouter._();

  static Widget buildSection(AppSection section, BackendRuntime backendRuntime) {
    switch (section) {
      case AppSection.dashboard:
        return const DashboardScreen();
      case AppSection.projects:
        return const ProjectsScreen();
      case AppSection.mediaLibrary:
        return const MediaLibraryScreen();
      case AppSection.liveControl:
        return LiveControlScreen(backendRuntime: backendRuntime);
      case AppSection.settings:
        return const SettingsScreen();
    }
  }
}
