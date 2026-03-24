import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/live_action_type.dart';
import 'package:led_management_software/domain/enums/queue_behavior.dart';
import 'package:led_management_software/features/live_control/model/live_action_config.dart';
import 'package:led_management_software/features/settings/model/hotkey_binding_model.dart';
import 'package:led_management_software/features/settings/model/setting_item_model.dart';

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

  final File _storageFile = File('.led_live_actions.json');
  List<LiveActionConfig>? _liveActionsCache;

  List<SettingItemModel> loadPlaybackSettings() {
    return const [
      SettingItemModel(title: 'VLC Auto-Reconnect', description: 'Verbindung bei Engine-Verlust automatisch neu aufbauen.', enabled: true),
      SettingItemModel(title: 'Failover auf Backup-Ausgabe', description: 'Bei Fehler auf sekundären Output wechseln.', enabled: true),
      SettingItemModel(title: 'Sicherheits-Bestätigung bei Stop-All', description: 'Globale Stop-Befehle mit Bestätigung schützen.', enabled: true),
    ];
  }

  List<LiveActionConfig> loadLiveActions() {
    _ensureLiveActionsLoaded();
    return List<LiveActionConfig>.unmodifiable(_liveActionsCache!);
  }

  List<HotkeyBindingModel> loadHotkeyBindings() {
    return loadLiveActions()
        .map(
          (action) => HotkeyBindingModel(
            eventLabel: action.label,
            description: _descriptionFor(action),
            shortcutLabel: action.hotkey ?? '—',
          ),
        )
        .toList(growable: false);
  }

  Map<String, String> currentHotkeyMap() {
    return {
      for (final action in loadLiveActions())
        if (action.enabled && action.hotkey != null && action.hotkey!.isNotEmpty) action.label: action.hotkey!,
    };
  }

  String hotkeyForEvent(String eventLabel) {
    final action = loadLiveActions().where((item) => item.label == eventLabel).cast<LiveActionConfig?>().firstWhere((item) => item != null, orElse: () => null);
    return action?.hotkey ?? '—';
  }

  void updateHotkey(String eventLabel, String shortcutLabel) {
    _ensureLiveActionsLoaded();
    final actions = _liveActionsCache!;
    final index = actions.indexWhere((item) => item.label == eventLabel);
    if (index < 0) {
      return;
    }

    final current = actions[index];
    if (current.hotkey == shortcutLabel) {
      return;
    }

    final conflictIndex = actions.indexWhere((item) => item.id != current.id && item.hotkey == shortcutLabel);
    if (conflictIndex >= 0) {
      actions[conflictIndex] = actions[conflictIndex].copyWith(hotkey: current.hotkey);
    }

    actions[index] = current.copyWith(hotkey: shortcutLabel);
    _persistLiveActions();
    notifyListeners();
  }

  void updateLiveActionEnabled(String actionId, bool enabled) {
    _ensureLiveActionsLoaded();
    _liveActionsCache = _liveActionsCache!
        .map((item) => item.id == actionId ? item.copyWith(enabled: enabled) : item)
        .toList(growable: false);
    _persistLiveActions();
    notifyListeners();
  }

  void updateLiveActionColor(String actionId, LiveActionColorSemantic color) {
    _ensureLiveActionsLoaded();
    _liveActionsCache = _liveActionsCache!
        .map((item) => item.id == actionId ? item.copyWith(color: color) : item)
        .toList(growable: false);
    _persistLiveActions();
    notifyListeners();
  }

  void reorderLiveActions(List<String> orderedIds) {
    _ensureLiveActionsLoaded();
    final byId = {for (final action in _liveActionsCache!) action.id: action};
    final reordered = <LiveActionConfig>[];

    for (var i = 0; i < orderedIds.length; i++) {
      final item = byId[orderedIds[i]];
      if (item != null) {
        reordered.add(item.copyWith(priority: i));
      }
    }

    for (final action in _liveActionsCache!) {
      if (!orderedIds.contains(action.id)) {
        reordered.add(action.copyWith(priority: reordered.length));
      }
    }

    _liveActionsCache = reordered;
    _persistLiveActions();
    notifyListeners();
  }

  void _ensureLiveActionsLoaded() {
    if (_liveActionsCache != null) {
      return;
    }

    final seeded = _seedDefaultLiveActions();

    if (!_storageFile.existsSync()) {
      _liveActionsCache = seeded;
      _persistLiveActions();
      return;
    }

    try {
      final payload = jsonDecode(_storageFile.readAsStringSync()) as Map<String, dynamic>;
      final items = (payload['liveActions'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LiveActionConfig.fromJson)
          .toList(growable: false);

      if (items.isEmpty) {
        _liveActionsCache = seeded;
        _persistLiveActions();
        return;
      }

      _liveActionsCache = _mergeMissingDefaults(items, seeded);
      _persistLiveActions();
    } catch (_) {
      _liveActionsCache = seeded;
      _persistLiveActions();
    }
  }

  void _persistLiveActions() {
    final payload = {
      'version': 1,
      'liveActions': _liveActionsCache?.map((item) => item.toJson()).toList(growable: false) ?? const [],
    };
    _storageFile.writeAsStringSync(jsonEncode(payload));
  }

  List<LiveActionConfig> _mergeMissingDefaults(List<LiveActionConfig> existing, List<LiveActionConfig> defaults) {
    final byId = {for (final item in existing) item.id: item};
    final merged = [...existing];

    for (final item in defaults) {
      if (!byId.containsKey(item.id)) {
        merged.add(item.copyWith(priority: merged.length));
      }
    }

    merged.sort((a, b) => a.priority.compareTo(b.priority));
    return merged;
  }

  String _descriptionFor(LiveActionConfig action) {
    switch (action.id) {
      case 'goal':
        return 'Toranimation sofort starten';
      case 'penalty':
        return 'Zeitstrafen-Event triggern';
      case 'yellow_card':
        return 'Gelbe Karte einblenden';
      case 'red_card':
        return 'Rote Karte einblenden';
      case 'timeout':
        return 'Timeout-Grafik starten';
      case 'wiper':
        return 'Wischer-Animation';
      case 'sponsor_loop':
        return 'Sponsorloop aktivieren';
      case 'black_screen':
        return 'Ausgabe schwarz schalten';
      case 'stop':
        return 'Playback anhalten';
      case 'next_player':
        return 'Nächsten Spieler anzeigen';
      default:
        return 'Live-Aktion';
    }
  }

  List<LiveActionConfig> _seedDefaultLiveActions() {
    return const [
      LiveActionConfig(
        id: 'goal',
        label: 'Tor',
        actionType: LiveActionType.triggerCue,
        group: LiveActionGroup.game,
        color: LiveActionColorSemantic.success,
        hotkey: 'F1',
        enabled: true,
        priority: 0,
        queueBehavior: QueueBehavior.enqueue,
        canInterrupt: true,
        cueType: CueType.event,
        mediaAssetId: null,
      ),
      LiveActionConfig(
        id: 'penalty',
        label: 'Zeitstrafe',
        actionType: LiveActionType.triggerCue,
        group: LiveActionGroup.game,
        color: LiveActionColorSemantic.warning,
        hotkey: 'F2',
        enabled: true,
        priority: 1,
        queueBehavior: QueueBehavior.enqueue,
        canInterrupt: true,
        cueType: CueType.event,
        mediaAssetId: null,
      ),
      LiveActionConfig(
        id: 'yellow_card',
        label: 'Gelbe Karte',
        actionType: LiveActionType.triggerCue,
        group: LiveActionGroup.game,
        color: LiveActionColorSemantic.warning,
        hotkey: 'F3',
        enabled: true,
        priority: 2,
        queueBehavior: QueueBehavior.enqueue,
        canInterrupt: true,
        cueType: CueType.event,
        mediaAssetId: null,
      ),
      LiveActionConfig(
        id: 'red_card',
        label: 'Rote Karte',
        actionType: LiveActionType.triggerCue,
        group: LiveActionGroup.game,
        color: LiveActionColorSemantic.danger,
        hotkey: 'F4',
        enabled: true,
        priority: 3,
        queueBehavior: QueueBehavior.enqueue,
        canInterrupt: true,
        cueType: CueType.event,
        mediaAssetId: null,
      ),
      LiveActionConfig(
        id: 'timeout',
        label: 'Timeout',
        actionType: LiveActionType.triggerCue,
        group: LiveActionGroup.game,
        color: LiveActionColorSemantic.primary,
        hotkey: 'F5',
        enabled: true,
        priority: 4,
        queueBehavior: QueueBehavior.enqueue,
        canInterrupt: true,
        cueType: CueType.event,
        mediaAssetId: null,
      ),
      LiveActionConfig(
        id: 'wiper',
        label: 'Wischer',
        actionType: LiveActionType.triggerCue,
        group: LiveActionGroup.advertising,
        color: LiveActionColorSemantic.primary,
        hotkey: 'F6',
        enabled: true,
        priority: 5,
        queueBehavior: QueueBehavior.enqueue,
        canInterrupt: true,
        cueType: CueType.event,
        mediaAssetId: null,
      ),
      LiveActionConfig(
        id: 'sponsor_loop',
        label: 'Sponsor Loop',
        actionType: LiveActionType.triggerCue,
        group: LiveActionGroup.advertising,
        color: LiveActionColorSemantic.danger,
        hotkey: 'F7',
        enabled: true,
        priority: 6,
        queueBehavior: QueueBehavior.forceFront,
        canInterrupt: false,
        cueType: CueType.lockedSponsor,
        mediaAssetId: null,
      ),
      LiveActionConfig(
        id: 'black_screen',
        label: 'Black Screen',
        actionType: LiveActionType.blackScreenOn,
        group: LiveActionGroup.safety,
        color: LiveActionColorSemantic.neutral,
        hotkey: 'F8',
        enabled: true,
        priority: 7,
        queueBehavior: QueueBehavior.replace,
        canInterrupt: true,
        cueType: CueType.fallback,
        mediaAssetId: null,
      ),
      LiveActionConfig(
        id: 'stop',
        label: 'Stop',
        actionType: LiveActionType.stopCue,
        group: LiveActionGroup.safety,
        color: LiveActionColorSemantic.danger,
        hotkey: 'F9',
        enabled: true,
        priority: 8,
        queueBehavior: QueueBehavior.replace,
        canInterrupt: true,
        cueType: CueType.fallback,
        mediaAssetId: null,
      ),
      LiveActionConfig(
        id: 'next_player',
        label: 'Nächster Spieler',
        actionType: LiveActionType.triggerCue,
        group: LiveActionGroup.intro,
        color: LiveActionColorSemantic.success,
        hotkey: 'F10',
        enabled: true,
        priority: 9,
        queueBehavior: QueueBehavior.enqueue,
        canInterrupt: true,
        cueType: CueType.oneShot,
        mediaAssetId: null,
      ),
    ];
  }
}
