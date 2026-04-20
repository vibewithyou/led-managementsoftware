import 'package:flutter/material.dart';
import 'package:led_managementsoftware_app/core/app/led_control_app.dart';
import 'package:led_managementsoftware_app/core/config/backend_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final backendRuntime = await BackendInitializer.initialize();
  runApp(LedControlApp(backendRuntime: backendRuntime));
}
