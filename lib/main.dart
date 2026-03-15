import 'package:flutter/widgets.dart';
import 'package:led_management_software/app/app.dart';
import 'package:led_management_software/data/services/global_hotkey_service.dart';
import 'package:led_management_software/data/local/isar/isar_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await IsarDatabase.instance.initialize();
  } catch (error) {
    debugPrint('Lokale Datenbank konnte nicht initialisiert werden: $error');
  }

  try {
    await GlobalHotkeyService.instance.initialize();
  } catch (error) {
    debugPrint('Globale Hotkeys konnten nicht initialisiert werden: $error');
  }

  runApp(const LedControlApp());
}
