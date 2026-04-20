import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:led_managementsoftware_app/core/config/backend_config.dart';
import 'package:led_managementsoftware_app/core/config/backend_runtime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BackendInitializer {
  const BackendInitializer._();

  static Future<BackendRuntime> initialize() async {
    await _loadDotEnv();
    final config = BackendConfig.fromEnvironment(
      environment: _read('APP_ENV', fallback: 'local') ?? 'local',
      enableRemoteSync: _readBool('ENABLE_REMOTE_SYNC', fallback: true),
      supabaseUrl: _read('SUPABASE_URL'),
      supabaseAnonOrPublishableKey: _read('SUPABASE_ANON_OR_PUBLISHABLE_KEY'),
      mainDeviceId: _read('MAIN_DEVICE_ID', fallback: 'main-pc') ?? 'main-pc',
      mainPcPriority: _readBool('MAIN_PC_PRIORITY', fallback: true),
    );

    if (!config.hasSupabaseCredentials) {
      return BackendRuntime(
        config: config,
        statusMessage: 'Offline-Modus aktiv: Supabase-Konfiguration fehlt.',
      );
    }

    if (!config.enableRemoteSync) {
      return BackendRuntime(
        config: config,
        statusMessage: 'Offline-Modus aktiv: Remote-Sync ist deaktiviert.',
      );
    }

    try {
      await Supabase.initialize(
        url: config.supabaseUrl!,
        anonKey: config.supabaseAnonOrPublishableKey!,
      );
      return BackendRuntime(
        config: config,
        client: Supabase.instance.client,
        statusMessage: 'Supabase verbunden. Offline-Fallback bleibt verfügbar.',
      );
    } catch (error, stackTrace) {
      debugPrint('Supabase-Init fehlgeschlagen: $error');
      debugPrint('$stackTrace');
      return BackendRuntime(
        config: config,
        statusMessage: 'Offline-Fallback aktiv: Supabase konnte nicht initialisiert werden.',
      );
    }
  }

  static Future<void> _loadDotEnv() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Optional: fallback to --dart-define without .env file.
    }
  }

  static String? _read(String key, {String? fallback}) {
    String? fromEnvFile;
    try {
      fromEnvFile = dotenv.maybeGet(key);
    } catch (_) {
      fromEnvFile = null;
    }
    final fromDefine = switch (key) {
      'APP_ENV' => const String.fromEnvironment('APP_ENV', defaultValue: ''),
      'ENABLE_REMOTE_SYNC' => const String.fromEnvironment('ENABLE_REMOTE_SYNC', defaultValue: ''),
      'SUPABASE_URL' => const String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
      'SUPABASE_ANON_OR_PUBLISHABLE_KEY' =>
        const String.fromEnvironment('SUPABASE_ANON_OR_PUBLISHABLE_KEY', defaultValue: ''),
      'MAIN_DEVICE_ID' => const String.fromEnvironment('MAIN_DEVICE_ID', defaultValue: ''),
      'MAIN_PC_PRIORITY' => const String.fromEnvironment('MAIN_PC_PRIORITY', defaultValue: ''),
      _ => '',
    };
    final value = (fromEnvFile ?? fromDefine).trim();
    if (value.isEmpty) {
      return fallback;
    }
    return value;
  }

  static bool _readBool(String key, {required bool fallback}) {
    final raw = _read(key);
    if (raw == null) {
      return fallback;
    }
    return raw.toLowerCase() == 'true' || raw == '1';
  }
}
