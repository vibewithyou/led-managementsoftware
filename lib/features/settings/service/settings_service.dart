import 'package:led_management_software/features/settings/model/setting_item_model.dart';
import 'package:flutter/foundation.dart';

import 'package:led_management_software/features/settings/model/hotkey_binding_model.dart';

class SettingsService extends ChangeNotifier {
  SettingsService._();

  static final SettingsService instance = SettingsService._();

  static const List<String> availableHotkeys = <String>[
    'F1',
    'F2',
    'F3',
    'F4',
    'F5',
    'F6',
    'F7',
    'F8',
    'F9',
    'F10',
    'F11',
    'F12',
  ];

  static const List<(String, String)> _hotkeyDefinitions = <(String, String)>[
    ('Tor', 'Toranimation sofort starten'),
    ('Zeitstrafe', 'Zeitstrafen-Event triggern'),
    ('Gelbe Karte', 'Gelbe Karte einblenden'),
    ('Rote Karte', 'Rote Karte einblenden'),
    ('Timeout', 'Timeout-Grafik starten'),
    ('Sponsor Loop', 'Sponsorloop aktivieren'),
    ('Black Screen', 'Ausgabe schwarz schalten'),
    ('Stop', 'Playback anhalten'),
    ('Nächster Spieler', 'Nächsten Spieler anzeigen'),
  ];

  final Map<String, String> _hotkeyBindings = <String, String>{
    'Tor': 'F1',
    'Zeitstrafe': 'F2',
    'Gelbe Karte': 'F3',
    'Rote Karte': 'F4',
    'Timeout': 'F5',
    'Sponsor Loop': 'F6',
    'Black Screen': 'F7',
    'Stop': 'F8',
    'Nächster Spieler': 'F9',
  };

  List<SettingItemModel> loadPlaybackSettings() {
    return const [
      SettingItemModel(title: 'VLC Auto-Reconnect', description: 'Verbindung bei Engine-Verlust automatisch neu aufbauen.', enabled: true),
      SettingItemModel(title: 'Failover auf Backup-Ausgabe', description: 'Bei Fehler auf sekundären Output wechseln.', enabled: true),
      SettingItemModel(title: 'Sicherheits-Bestätigung bei Stop-All', description: 'Globale Stop-Befehle mit Bestätigung schützen.', enabled: true),
    ];
  }

  List<HotkeyBindingModel> loadHotkeyBindings() {
    return _hotkeyDefinitions
        .map(
          (definition) => HotkeyBindingModel(
            eventLabel: definition.$1,
            description: definition.$2,
            shortcutLabel: _hotkeyBindings[definition.$1] ?? '—',
          ),
        )
        .toList(growable: false);
  }

  Map<String, String> currentHotkeyMap() {
    return Map<String, String>.unmodifiable(_hotkeyBindings);
  }

  String hotkeyForEvent(String eventLabel) {
    return _hotkeyBindings[eventLabel] ?? '—';
  }

  void updateHotkey(String eventLabel, String shortcutLabel) {
    if (_hotkeyBindings[eventLabel] == shortcutLabel) {
      return;
    }

    final previousShortcut = _hotkeyBindings[eventLabel];
    String? conflictingEvent;

    for (final entry in _hotkeyBindings.entries) {
      if (entry.key != eventLabel && entry.value == shortcutLabel) {
        conflictingEvent = entry.key;
        break;
      }
    }

    _hotkeyBindings[eventLabel] = shortcutLabel;

    // Keep bindings unique by swapping instead of silently duplicating.
    if (conflictingEvent != null && previousShortcut != null) {
      _hotkeyBindings[conflictingEvent] = previousShortcut;
    }

    notifyListeners();
  }
}
