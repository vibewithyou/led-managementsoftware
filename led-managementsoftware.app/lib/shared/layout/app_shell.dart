import 'package:flutter/material.dart';
import 'package:led_managementsoftware_app/core/config/backend_runtime.dart';
import 'package:led_managementsoftware_app/core/routing/app_router.dart';
import 'package:led_managementsoftware_app/core/routing/app_section.dart';
import 'package:led_managementsoftware_app/core/theme/app_colors.dart';
import 'package:led_managementsoftware_app/shared/layout/app_top_bar.dart';
import 'package:led_managementsoftware_app/shared/layout/sidebar_navigation.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.backendRuntime,
    super.key,
  });

  final BackendRuntime backendRuntime;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppSection _currentSection = AppSection.dashboard;
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useDrawer = width < 1100;
    final compactRail = width < 1380 || _collapsed;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1420), Color(0xFF09111C), Color(0xFF111F31)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: useDrawer
            ? Drawer(
                backgroundColor: AppColors.backgroundRaised,
                child: SafeArea(
                  child: SidebarNavigation(
                    currentSection: _currentSection,
                    compact: false,
                    onSelect: (section) {
                      Navigator.of(context).pop();
                      setState(() {
                        _currentSection = section;
                      });
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
                  currentSection: _currentSection,
                  compact: compactRail,
                  onToggleCompact: () {
                    setState(() {
                      _collapsed = !_collapsed;
                    });
                  },
                  onSelect: (section) {
                    setState(() {
                      _currentSection = section;
                    });
                  },
                ),
              Expanded(
                child: Column(
                  children: [
                    Builder(
                      builder: (innerContext) {
                        return AppTopBar(
                          section: _currentSection,
                          useDrawerTrigger: useDrawer,
                          backendStatusMessage: widget.backendRuntime.statusMessage,
                          onMenuTap: () => Scaffold.of(innerContext).openDrawer(),
                        );
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.background.withValues(alpha: 0.78),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow.withValues(alpha: 0.45),
                                blurRadius: 24,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: KeyedSubtree(
                              key: ValueKey(_currentSection),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: _buildSection(),
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildSection() {
    return AppRouter.buildSection(_currentSection, widget.backendRuntime);
  }
}