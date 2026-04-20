import 'package:flutter/material.dart';
import 'package:led_management_software/app/routing/app_route.dart';
import 'package:led_management_software/shared/widgets/layout/sidebar_navigation.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    required this.currentRoute,
    required this.compact,
    required this.onSelect,
    super.key,
  });

  final AppRoute currentRoute;
  final bool compact;
  final ValueChanged<AppRoute> onSelect;

  @override
  Widget build(BuildContext context) {
    return SidebarNavigation(
      currentRoute: currentRoute,
      compact: compact,
      onSelect: onSelect,
    );
  }
}
