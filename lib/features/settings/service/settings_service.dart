import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/live_action_type.dart';
import 'package:led_management_software/domain/enums/queue_behavior.dart';
import 'package:led_management_software/features/live_control/model/live_action_config.dart';
import 'package:led_management_software/features/settings/model/hotkey_binding_model.dart';
import 'package:led_management_software/features/settings/model/setting_item_model.dart';

enum FallbackBehavior {
  sponsorLoop,
  stayIdle,
}

class SettingsService extends ChangeNotifier {
  SettingsService._();

  static final SettingsService instance = SettingsService._();

  static const List<String> availableHotkeys = <String>[
    '—',
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
  String _vlcExecutablePath = '';
  String? _lastVlcError;
  bool _clearQueueOnStop = false;
  bool _strictSponsorLock = true;
  bool _operatorLargeControls = false;
  bool _operatorReducedAnimations = false;
  FallbackBehavior _fallbackBehavior = FallbackBehavior.sponsorLoop;

  String get vlcExecutablePath {
    _ensureLoaded();
    return _vlcExecutablePath;
  }

  String? get lastVlcError {
    _ensureLoaded();
    return _lastVlcError;
  }

  bool get clearQueueOnStop {
    _ensureLoaded();
    return _clearQueueOnStop;
  }

  bool get strictSponsorLock {
    _ensureLoaded();
    return _strictSponsorLock;
  }

  bool get operatorLargeControls {
    _ensureLoaded();
    return _operatorLargeControls;
  }

  bool get operatorReducedAnimations {
    _ensureLoaded();
    return _operatorReducedAnimations;
  }

  FallbackBehavior get fallbackBehavior {
    _ensureLoaded();
    return _fallbackBehavior;
  }

  List<SettingItemModel> loadPlaybackSettings() {
    return [
      SettingItemModel(
        id: 'clear_queue_on_stop',
        title: 'Queue nach Stop löschen',
        description: 'Entfernt wartende Cues automatisch, wenn Stop ausgelöst wird.',
        enabled: clearQueueOnStop,
      ),
      SettingItemModel(
        id: 'strict_sponsor_lock',
        title: 'Sponsor-Lock strikt',
        description: 'Während Locked Sponsor läuft, werden weitere Aktionen nur in die Queue gestellt.',
        enabled: strictSponsorLock,
      ),
    ];
  }

  List<SettingItemModel> loadOperatorSettings() {
    return [
      SettingItemModel(
        id: 'large_controls',
        title: 'Große Bedienflächen',
        description: 'Vergrößert Trigger-Flächen für Touch/Stressbetrieb.',
        enabled: operatorLargeControls,
      ),
      SettingItemModel(
        id: 'reduced_animations',
        title: 'Animationen reduziert',
        description: 'Reduziert visuelle Effekte für ruhigeren Betrieb und bessere Lesbarkeit.',
        enabled: operatorReducedAnimations,
      ),
    ];
  }

  List<LiveActionConfig> loadLiveActions() {
    _ensureLoaded();
    return List<LiveActionConfig>.unmodifiable(_liveActionsCache!);
  }

  List<HotkeyBindingModel> loadHotkeyBindings() {
    return loadLiveActions()
        .map(
          (action) => HotkeyBindingModel(
            eventLabel: action.label,
            description: _descriptionFor(action),
            shortcutLabel: _displayHotkey(action.hotkey),
          ),
        )
        .toList(growable: false);
  }

  Map<String, List<String>> hotkeyConflicts() {
    final assignments = <String, List<String>>{};
    for (final action in loadLiveActions()) {
      final key = _normalizeHotkey(action.hotkey);
      if (key == null) {
        continue;
      }
      assignments.putIfAbsent(key, () => []).add(action.label);
    }

    return {
      for (final entry in assignments.entries)
        if (entry.value.length > 1) entry.key: List<String>.unmodifiable(entry.value),
    };
  }

  Map<String, String> currentHotkeyMap() {
    return {
      for (final action in loadLiveActions())
        if (action.enabled && _normalizeHotkey(action.hotkey) != null) action.label: _normalizeHotkey(action.hotkey)!,
    };
  }

  String hotkeyForEvent(String eventLabel) {
    final action = loadLiveActions().where((item) => item.label == eventLabel).cast<LiveActionConfig?>().firstWhere((item) => item != null, orElse: () => null);
    return _displayHotkey(action?.hotkey);
  }

  void updateHotkey(String eventLabel, String shortcutLabel) {
    _ensureLoaded();
    final actions = _liveActionsCache!;
    final index = actions.indexWhere((item) => item.label == eventLabel);
    if (index < 0) {
      return;
    }

    final nextHotkey = _normalizeHotkey(shortcutLabel);
    final current = actions[index];
    final currentHotkey = _normalizeHotkey(current.hotkey);
    if (currentHotkey == nextHotkey) {
      return;
    }

    final conflictIndex = actions.indexWhere((item) => item.id != current.id && _normalizeHotkey(item.hotkey) == nextHotkey);
    if (conflictIndex >= 0) {
      actions[conflictIndex] = actions[conflictIndex].copyWith(hotkey: currentHotkey);
    }

    actions[index] = current.copyWith(hotkey: nextHotkey);
    _persist();
    notifyListeners();
  }

  void updatePlaybackToggle(String settingId, bool enabled) {
    _ensureLoaded();
    var changed = false;
    switch (settingId) {
      case 'clear_queue_on_stop':
        changed = _clearQueueOnStop != enabled;
        _clearQueueOnStop = enabled;
        break;
      case 'strict_sponsor_lock':
        changed = _strictSponsorLock != enabled;
        _strictSponsorLock = enabled;
        break;
      default:
        return;
    }

    if (changed) {
      _persist();
      notifyListeners();
    }
  }

  void updateOperatorToggle(String settingId, bool enabled) {
    _ensureLoaded();
    var changed = false;
    switch (settingId) {
      case 'large_controls':
        changed = _operatorLargeControls != enabled;
        _operatorLargeControls = enabled;
        break;
      case 'reduced_animations':
        changed = _operatorReducedAnimations != enabled;
        _operatorReducedAnimations = enabled;
        break;
      default:
        return;
    }

    if (changed) {
      _persist();
      notifyListeners();
    }
  }

  void updateFallbackBehavior(FallbackBehavior behavior) {
    _ensureLoaded();
    if (_fallbackBehavior == behavior) {
      return;
    }
    _fallbackBehavior = behavior;
    _persist();
    notifyListeners();
  }

  void updateLiveActionEnabled(String actionId, bool enabled) {
    _ensureLoaded();
    _liveActionsCache = _liveActionsCache!
        .map((item) => item.id == actionId ? item.copyWith(enabled: enabled) : item)
        .toList(growable: false);
    _persist();
    notifyListeners();
  }

  void updateLiveActionColor(String actionId, LiveActionColorSemantic color) {
    _ensureLoaded();
    _liveActionsCache = _liveActionsCache!
        .map((item) => item.id == actionId ? item.copyWith(color: color) : item)
        .toList(growable: false);
    _persist();
    notifyListeners();
  }

  void reorderLiveActions(List<String> orderedIds) {
    _ensureLoaded();
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
    _persist();
    notifyListeners();
  }

  void updateVlcExecutablePath(String value) {
    _ensureLoaded();
    final normalized = value.trim();
    if (_vlcExecutablePath == normalized) {
      return;
    }
    _vlcExecutablePath = normalized;
    _persist();
    notifyListeners();
  }

  void setLastVlcError(String? message) {
    _ensureLoaded();
    final normalized = message?.trim();
    final next = normalized == null || normalized.isEmpty ? null : normalized;
    if (_lastVlcError == next) {
      return;
    }
    _lastVlcError = next;
    _persist();
    notifyListeners();
  }

  void _ensureLoaded() {
    if (_liveActionsCache != null) {
      return;
    }

    final seeded = _seedDefaultLiveActions();

    if (!_storageFile.existsSync()) {
      _liveActionsCache = seeded;
      _persist();
      return;
    }

    try {
      final payload = _readPayload();
      final items = (payload['liveActions'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LiveActionConfig.fromJson)
          .toList(growable: false);
      _vlcExecutablePath = (payload['vlcExecutablePath'] as String? ?? '').trim();
      _lastVlcError = (payload['lastVlcError'] as String?)?.trim();
      _clearQueueOnStop = payload['clearQueueOnStop'] as bool? ?? false;
      _strictSponsorLock = payload['strictSponsorLock'] as bool? ?? true;
      _operatorLargeControls = payload['operatorLargeControls'] as bool? ?? false;
      _operatorReducedAnimations = payload['operatorReducedAnimations'] as bool? ?? false;
      final fallbackRaw = payload['fallbackBehavior'] as String?;
      _fallbackBehavior = fallbackRaw == FallbackBehavior.stayIdle.name ? FallbackBehavior.stayIdle : FallbackBehavior.sponsorLoop;

      if (items.isEmpty) {
        _liveActionsCache = seeded;
        _persist();
        return;
      }

      _liveActionsCache = _mergeMissingDefaults(items, seeded);
      _persist();
    } catch (_) {
      _liveActionsCache = seeded;
      _vlcExecutablePath = '';
      _lastVlcError = null;
      _clearQueueOnStop = false;
      _strictSponsorLock = true;
      _operatorLargeControls = false;
      _operatorReducedAnimations = false;
      _fallbackBehavior = FallbackBehavior.sponsorLoop;
      _persist();
    }
  }

  void _persist() {
    final payload = <String, dynamic>{
      'version': 2,
      'liveActions': _liveActionsCache?.map((item) => item.toJson()).toList(growable: false) ?? const [],
      'vlcExecutablePath': _vlcExecutablePath,
      'lastVlcError': _lastVlcError,
      'clearQueueOnStop': _clearQueueOnStop,
      'strictSponsorLock': _strictSponsorLock,
      'operatorLargeControls': _operatorLargeControls,
      'operatorReducedAnimations': _operatorReducedAnimations,
      'fallbackBehavior': _fallbackBehavior.name,
    };
    _storageFile.writeAsStringSync(jsonEncode(payload));
  }

  Map<String, dynamic> _readPayload() {
    final raw = jsonDecode(_storageFile.readAsStringSync());
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
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

  String? _normalizeHotkey(String? hotkey) {
    final normalized = hotkey?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty || normalized == '—') {
      return null;
    }
    return normalized;
  }

  String _displayHotkey(String? hotkey) {
    return _normalizeHotkey(hotkey) ?? '—';
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
