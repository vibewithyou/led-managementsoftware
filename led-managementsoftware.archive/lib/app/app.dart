import 'package:flutter/material.dart';
import 'package:led_management_software/app/routing/app_route.dart';
import 'package:led_management_software/app/routing/app_router.dart';
import 'package:led_management_software/core/theme/app_theme.dart';

class LedControlApp extends StatelessWidget {
  const LedControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LED Regie Control',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.dark(),
      theme: AppTheme.dark(),
      initialRoute: AppRoute.dashboard.path,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
