import 'package:led_management_software/features/settings/model/setting_item_model.dart';

class SettingsService {
  const SettingsService();

  List<SettingItemModel> loadPlaybackSettings() {
    return const [
      SettingItemModel(title: 'VLC Auto-Reconnect', description: 'Verbindung bei Engine-Verlust automatisch neu aufbauen.', enabled: true),
      SettingItemModel(title: 'Failover auf Backup-Ausgabe', description: 'Bei Fehler auf sekundären Output wechseln.', enabled: true),
      SettingItemModel(title: 'Sicherheits-Bestätigung bei Stop-All', description: 'Globale Stop-Befehle mit Bestätigung schützen.', enabled: true),
    ];
  }
}
