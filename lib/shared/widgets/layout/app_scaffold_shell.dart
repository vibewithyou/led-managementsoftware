import 'package:flutter/material.dart';
import 'package:led_management_software/app/routing/app_route.dart';
import 'package:led_management_software/app/routing/app_router.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:led_management_software/features/intro_players/presentation/screens/intro_players_screen.dart';
import 'package:led_management_software/features/live_control/presentation/screens/live_control_screen.dart';
import 'package:led_management_software/features/media_library/presentation/screens/media_library_screen.dart';
import 'package:led_management_software/features/projects/presentation/screens/projects_screen.dart';
import 'package:led_management_software/features/settings/presentation/screens/settings_screen.dart';
import 'package:led_management_software/shared/widgets/layout/app_top_bar.dart';
import 'package:led_management_software/shared/widgets/layout/sidebar_navigation.dart';

class AppScaffoldShell extends StatelessWidget {
  const AppScaffoldShell({required this.currentRoute, super.key});

  final AppRoute currentRoute;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useDrawer = width < 1050;
    final compactSidebar = width < 1360;

    final content = _routeToScreen(currentRoute);

    return Scaffold(
      drawer: useDrawer
          ? Drawer(
              backgroundColor: AppColors.backgroundElevated,
              child: SafeArea(
                child: SidebarNavigation(
                  currentRoute: currentRoute,
                  compact: false,
                  onSelect: (route) {
                    Navigator.of(context).pop();
                    AppRouter.goTo(context, route);
                  },
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!useDrawer)
              SidebarNavigation(
                currentRoute: currentRoute,
                compact: compactSidebar,
                onSelect: (route) => AppRouter.goTo(context, route),
              ),
            Expanded(
              child: Column(
                children: [
                  Builder(
                    builder: (innerContext) => AppTopBar(
                      title: currentRoute.label,
                      subtitle: 'Live-Regie für LED-Banden und Videoclips',
                      onMenuTap: useDrawer
                          ? () {
                              Scaffold.of(innerContext).openDrawer();
                            }
                          : null,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: KeyedSubtree(
                          key: ValueKey(currentRoute.path),
                          child: content,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _routeToScreen(AppRoute route) {
    return switch (route) {
      AppRoute.dashboard => const DashboardScreen(),
      AppRoute.mediaLibrary => const MediaLibraryScreen(),
      AppRoute.liveControl => const LiveControlScreen(),
      AppRoute.introPlayers => const IntroPlayersScreen(),
      AppRoute.projects => const ProjectsScreen(),
      AppRoute.settings => const SettingsScreen(),
    };
  }
}
