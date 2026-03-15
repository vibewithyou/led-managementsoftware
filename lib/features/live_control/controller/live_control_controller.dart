import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:led_management_software/data/services/global_hotkey_service.dart';
import 'package:led_management_software/data/services/playback_service.dart';
import 'package:led_management_software/domain/entities/cue.dart';
import 'package:led_management_software/domain/entities/live_event_log.dart';
import 'package:led_management_software/domain/entities/playback_state.dart';
import 'package:led_management_software/domain/enums/cue_trigger_mode.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/playback_status.dart';
import 'package:led_management_software/domain/enums/queue_behavior.dart';
import 'package:led_management_software/features/live_control/model/live_cue_model.dart';
import 'package:led_management_software/features/live_control/service/live_control_service.dart';
import 'package:led_management_software/features/settings/service/settings_service.dart';

/// Manages live trigger behavior, sponsor lock handling and playback progress.
class LiveControlController extends ChangeNotifier {
  LiveControlController({
    LiveControlService? service,
    SettingsService? settingsService,
    GlobalHotkeyService? globalHotkeyService,
  })  : _service = service ?? const LiveControlService(),
        _settingsService = settingsService ?? SettingsService.instance,
        _globalHotkeyService = globalHotkeyService ?? GlobalHotkeyService.instance {
    _eventDurations = _service.eventDurationsMs();
    _eventButtons = _service.liveEventButtons();

    final fallbackCue = _buildCue(
      _service.loadFallbackCueLabel(),
      cueType: CueType.lockedSponsor,
      sponsorName: 'Standard Sponsorloop',
      isLocked: true,
    );

    _playbackService = PlaybackService(
      projectId: 'live_project',
      fallbackCue: fallbackCue,
      cueDurationsMs: _eventDurations,
    );
    _playbackService.addListener(_onPlaybackChanged);
    _settingsService.addListener(_onSettingsChanged);
    _syncFromPlaybackService();

    if (_playbackState.status == PlaybackStatus.idle) {
      _playbackService.returnToFallback(triggerSource: 'bootstrap');
    }

    unawaited(_registerGlobalHotkeys());
  }

  final LiveControlService _service;
  final SettingsService _settingsService;
  final GlobalHotkeyService _globalHotkeyService;
  late final Map<String, int> _eventDurations;
  late final List<String> _eventButtons;
  late final PlaybackService _playbackService;

  PlaybackState _playbackState = PlaybackState.initial(projectId: 'live_project');
  List<LiveCueModel> _queue = const [];
  String _fallbackCueLabel = 'Fallback Safe Loop';
  List<LiveEventLog> _logs = const [];

  PlaybackState get playbackState => _playbackState;

  List<LiveCueModel> get queue => _queue;

  String get fallbackCueLabel => _fallbackCueLabel;

  List<LiveEventLog> get logs => _logs;

  List<LiveEventLog> get recentLogs => _logs.reversed.take(6).toList(growable: false);

  List<String> get eventButtons => _eventButtons;

  bool get globalHotkeysActive => _globalHotkeyService.isRegistered;

  bool get sponsorLockedRunning => _playbackService.playbackState.status == PlaybackStatus.locked;

  bool get vlcRunning => _playbackService.isVlcRunning;

  String get activeProjectId => _playbackService.projectId;

  bool get fallbackConfigured => _playbackService.fallbackCue.title.trim().isNotEmpty;

  int get queueLength => _queue.length;

  String get lockedSponsorLabel {
    final cue = _playbackService.playbackState.currentCue;
    if (cue == null || !sponsorLockedRunning) {
      return 'LOCKED SPONSOR CLIP';
    }
    return cue.title.trim().isEmpty ? 'LOCKED SPONSOR CLIP' : cue.title.toUpperCase();
  }

  String hotkeyForEvent(String eventLabel) {
    return _settingsService.hotkeyForEvent(eventLabel);
  }

  double get progress {
    final total = _playbackState.currentMediaPositionMs + _playbackState.remainingMs;
    if (total <= 0) {
      return 0;
    }
    return (_playbackState.currentMediaPositionMs / total).clamp(0, 1);
  }

  void triggerEvent(String eventLabel) {
    if (eventLabel == 'Stop') {
      _playbackService.stopCue(triggerSource: 'operator_stop');
      return;
    }

    if (eventLabel == 'Black Screen') {
      _playbackService.startCue(
        _buildCue(eventLabel, cueType: CueType.fallback),
        triggerSource: 'operator_black',
      );
      return;
    }

    if (eventLabel == 'Sponsor Loop') {
      _playbackService.startCue(
        _buildCue(
          eventLabel,
          cueType: CueType.lockedSponsor,
          sponsorName: 'Sponsor Main Loop',
          isLocked: true,
        ),
        triggerSource: 'operator_sponsor_loop',
      );
      return;
    }

    final cueType = eventLabel == 'Nächster Spieler' ? CueType.oneShot : CueType.event;
    _playbackService.startCue(
      _buildCue(eventLabel, cueType: cueType),
      triggerSource: 'operator_event',
    );
  }

  void triggerEmergencyBlackScreen() {
    _playbackService.startCue(
      _buildCue('Black Screen', cueType: CueType.fallback),
      triggerSource: 'operator_emergency',
    );
  }

  void _onPlaybackChanged() {
    _syncFromPlaybackService();
    notifyListeners();
  }

  void _onSettingsChanged() {
    unawaited(_registerGlobalHotkeys());
    notifyListeners();
  }

  void _syncFromPlaybackService() {
    _playbackState = _playbackService.playbackState;
    _fallbackCueLabel = _playbackService.playbackState.currentCue?.title == 'Black Screen'
        ? _service.loadFallbackCueLabel()
        : _service.loadFallbackCueLabel();
    _queue = _playbackService.queueState.entries
        .map(
          (entry) => LiveCueModel(
            id: entry.id,
            title: entry.cue.title,
            category: _categoryForEvent(entry.cue.title),
            status: 'queued',
            remainingMs: _eventDurations[entry.cue.title] ?? 7000,
            queuedAt: entry.enqueuedAt,
          ),
        )
        .toList(growable: false);
    _logs = _playbackService.logs;
  }

  String _categoryForEvent(String eventLabel) {
    if (eventLabel == 'Sponsor Loop') {
      return 'sponsor';
    }
    if (eventLabel == 'Nächster Spieler') {
      return 'player';
    }
    return 'event';
  }

  Future<void> _registerGlobalHotkeys() async {
    try {
      await _globalHotkeyService.registerHotkeys(
        bindings: _settingsService.currentHotkeyMap(),
        onTriggered: triggerEvent,
      );
    } catch (error) {
      debugPrint('Globale Hotkeys konnten nicht registriert werden: $error');
    }

    notifyListeners();
  }

  Cue _buildCue(
    String title, {
    required CueType cueType,
    String? sponsorName,
    bool isLocked = false,
  }) {
    return Cue(
      id: 'cue_${DateTime.now().microsecondsSinceEpoch}',
      mediaAssetId: title.toLowerCase().replaceAll(' ', '_'),
      title: title,
      cueType: cueType,
      isLocked: isLocked,
      canInterrupt: !isLocked,
      mustPlayToEnd: false,
      autoReturnToFallback: false,
      queueIfBlocked: true,
      queueBehavior: QueueBehavior.enqueue,
      triggerMode: CueTriggerMode.manual,
      hotkey: null,
      isFavorite: sponsorName != null,
      notes: sponsorName,
    );
  }

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    unawaited(_globalHotkeyService.unregisterAll());
    _playbackService.removeListener(_onPlaybackChanged);
    _playbackService.dispose();
    super.dispose();
  }
}
