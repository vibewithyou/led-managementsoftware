import 'package:flutter/material.dart';
import 'package:led_managementsoftware_app/core/config/backend_runtime.dart';
import 'package:led_managementsoftware_app/core/theme/app_theme.dart';
import 'package:led_managementsoftware_app/shared/layout/app_shell.dart';

class LedControlApp extends StatelessWidget {
  const LedControlApp({
    required this.backendRuntime,
    super.key,
  });

  final BackendRuntime backendRuntime;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LED Management Software',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      home: AppShell(backendRuntime: backendRuntime),
    );
  }
}