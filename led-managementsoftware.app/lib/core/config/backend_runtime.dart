import 'package:led_managementsoftware_app/core/config/backend_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BackendRuntime {
  const BackendRuntime({
    required this.config,
    required this.statusMessage,
    this.client,
  });

  final BackendConfig config;
  final SupabaseClient? client;
  final String statusMessage;

  bool get remoteEnabled => client != null && config.enableRemoteSync;
}
