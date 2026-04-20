import 'package:flutter/material.dart';
import 'package:led_management_software/app/routing/app_route.dart';
import 'package:led_management_software/shared/widgets/layout/app_scaffold_shell.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.currentRoute, super.key});

  final AppRoute currentRoute;

  @override
  Widget build(BuildContext context) {
    return AppScaffoldShell(currentRoute: currentRoute);
  }
}
