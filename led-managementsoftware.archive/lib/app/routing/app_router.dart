import 'package:flutter/material.dart';
import 'package:led_management_software/app/routing/app_route.dart';
import 'package:led_management_software/shared/widgets/layout/app_shell.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final selectedRoute = AppRoute.fromName(settings.name);
    return PageRouteBuilder(
      settings: RouteSettings(name: selectedRoute.path),
      pageBuilder: (context, animation, secondaryAnimation) => AppShell(currentRoute: selectedRoute),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  static void goTo(BuildContext context, AppRoute route) {
    final active = ModalRoute.of(context)?.settings.name;
    if (active == route.path) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(route.path);
  }
}
