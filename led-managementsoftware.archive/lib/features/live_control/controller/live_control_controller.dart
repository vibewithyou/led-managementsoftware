import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:led_management_software/data/repositories/media_repository_impl.dart';
import 'package:led_management_software/data/repositories/project_repository_impl.dart';
import 'package:led_management_software/data/services/global_hotkey_service.dart';
import 'package:led_management_software/data/services/playback_service.dart';
import 'package:led_management_software/domain/entities/cue.dart';
import 'package:led_management_software/domain/entities/live_event_log.dart';
import 'package:led_management_software/domain/entities/playback_state.dart';
import 'package:led_management_software/domain/entities/project.dart';
import 'package:led_management_software/domain/enums/cue_trigger_mode.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/live_action_type.dart';
import 'package:led_management_software/domain/enums/playback_status.dart';
import 'package:led_management_software/domain/enums/queue_behavior.dart';
import 'package:led_management_software/domain/enums/transport_status.dart';
import 'package:led_management_software/data/services/vlc_bridge_service.dart';
import 'package:led_management_software/features/live_control/model/live_action_config.dart';
import 'package:led_management_software/features/live_control/model/live_cue_model.dart';
import 'package:led_management_software/features/live_control/service/live_control_service.dart';
import 'package:led_management_software/features/settings/service/settings_service.dart';
import 'package:led_management_software/shared/state/active_project_state.dart';
import 'package:led_management_software/shared/state/live_runtime_state.dart';

class LiveControlController extends ChangeNotifier {
  final LiveRuntimeState _liveRuntimeState = LiveRuntimeState.instance;

  LiveControlController({
    LiveControlService? service,
    SettingsService? settingsService,
    GlobalHotkeyService? globalHotkeyService,
    ProjectRepositoryImpl? projectRepository,
    MediaRepositoryImpl? mediaRepository,
  })  : _service = service ?? const LiveControlService(),
        _settingsService = settingsService ?? SettingsService.instance,
        _globalHotkeyService = globalHotkeyService ?? GlobalHotkeyService.instance,
        _projectRepository = projectRepository ?? ProjectRepositoryImpl(),
        _mediaRepository = mediaRepository ?? MediaRepositoryImpl() {
    _actions = _sortedEnabledActions(_settingsService.loadLiveActions());
    _activeProjectState.addListener(_onActiveProjectChanged);

    final fallbackCue = _buildCueFromAction(
      _actions.where((item) => item.id == 'fallback').cast<LiveActionConfig?>().firstWhere(
            (item) => item != null,
            orElse: () => null,
          ) ??
          _actions.where((item) => item.id == 'fallback_default').cast<LiveActionConfig?>().firstWhere(
            (item) => item != null,
            orElse: () => null,
          ) ??
          _defaultFallbackAction(),
      fallbackTitle: _service.loadFallbackCueLabel(),
    );

    _playbackService = PlaybackService(
      projectId: 'live_project',
      fallbackCue: fallbackCue,
      cueDurationsMs: _cueDurations(),
      vlcService: VlcService(
        executablePath: _settingsService.vlcExecutablePath.trim().isEmpty ? null : _settingsService.vlcExecutablePath.trim(),
      ),
      strictSponsorLock: _settingsService.strictSponsorLock,
      clearQueueOnStop: _settingsService.clearQueueOnStop,
      fallbackBehavior: _settingsService.fallbackBehavior,
    );
    _playbackService.addListener(_onPlaybackChanged);
    _settingsService.addListener(_onSettingsChanged);
    _syncFromPlaybackService();

    if (_playbackState.status == PlaybackStatus.idle) {
      _playbackService.returnToFallback(triggerSource: 'bootstrap');
    }

    unawaited(_initializeRuntimeContext());
    unawaited(_registerGlobalHotkeys());
  }

  final LiveControlService _service;
  final SettingsService _settingsService;
  final GlobalHotkeyService _globalHotkeyService;
  final ProjectRepositoryImpl _projectRepository;
  final MediaRepositoryImpl _mediaRepository;
  final ActiveProjectState _activeProjectState = ActiveProjectState.instance;
  late final PlaybackService _playbackService;

  List<LiveActionConfig> _actions = const [];
  PlaybackState _playbackState = PlaybackState.initial(projectId: 'live_project');
  List<LiveCueModel> _queue = const [];
  String _fallbackCueLabel = 'Fallback';
  List<LiveEventLog> _logs = const [];
  Project? _activeProject;
  Map<String, String> _mediaTitleById = const {};

  PlaybackState get playbackState => _playbackState;
  List<LiveCueModel> get queue => _queue;
  String get fallbackCueLabel => _fallbackCueLabel;
  List<LiveEventLog> get logs => _logs;
  List<LiveEventLog> get recentLogs => _logs.reversed.take(6).toList(growable: false);
  List<LiveActionConfig> get actions => _actions;

  bool get globalHotkeysActive => _globalHotkeyService.isRegistered;
  bool get sponsorLockedRunning => _playbackService.playbackState.status == PlaybackStatus.locked;
  bool get vlcRunning => _playbackService.isVlcRunning;
  String get activeProjectId => _playbackService.projectId;
  bool get fallbackConfigured => _playbackService.fallbackCue.title.trim().isNotEmpty;
  int get queueLength => _queue.length;
  TransportStatus get transportStatus => _playbackState.transportStatus;
  String get transportMessage => _playbackState.transportMessage;

  bool get hasTransportError => transportStatus == TransportStatus.error || transportStatus == TransportStatus.fileMissing;
  bool get useLargeControls => _settingsService.operatorLargeControls;
  bool get reduceAnimations => _settingsService.operatorReducedAnimations;

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

  bool isActionConfigured(LiveActionConfig action) {
    if (action.actionType == LiveActionType.stopCue || action.actionType == LiveActionType.blackScreenOn) {
      return true;
    }

    if (action.actionType != LiveActionType.triggerCue) {
      return true;
    }

    return _resolveMediaAssetIdForAction(action) != null;
  }

  bool isActionActive(LiveActionConfig action) {
    final cue = _playbackState.currentCue;
    if (cue == null) {
      return false;
    }

    final resolvedMediaAssetId = _resolveMediaAssetIdForAction(action);
    if (resolvedMediaAssetId != null && cue.mediaAssetId == resolvedMediaAssetId) {
      return true;
    }

    return cue.title == _resolveCueTitleForAction(action);
  }

  String actionCueLabel(LiveActionConfig action) {
    return _resolveCueTitleForAction(action);
  }

  double get progress {
    final total = _playbackState.currentMediaPositionMs + _playbackState.remainingMs;
    if (total <= 0) {
      return 0;
    }
    return (_playbackState.currentMediaPositionMs / total).clamp(0, 1);
  }

  void triggerAction(LiveActionConfig action) {
    if (!action.enabled) {
      return;
    }

    switch (action.actionType) {
      case LiveActionType.stopCue:
        _playbackService.stopCue(clearQueue: _settingsService.clearQueueOnStop, triggerSource: 'operator_stop');
        return;
      case LiveActionType.blackScreenOn:
        _playbackService.startCue(
          _buildCueFromAction(action),
          triggerSource: 'operator_black',
        );
        return;
      default:
        _playbackService.startCue(
          _buildCueFromAction(action),
          triggerSource: 'operator_event',
        );
    }
  }

  void triggerEmergencyBlackScreen() {
    final action = _actions.where((item) => item.id == 'black_screen').cast<LiveActionConfig?>().firstWhere(
          (item) => item != null,
          orElse: () => null,
        );
    if (action == null) {
      _playbackService.startCue(
        _buildCueFromAction(_defaultBlackScreenAction()),
        triggerSource: 'operator_emergency',
      );
      return;
    }

    triggerAction(action);
  }

  void _onPlaybackChanged() {
    _syncFromPlaybackService();
    notifyListeners();
  }

  void _onSettingsChanged() {
    _actions = _sortedEnabledActions(_settingsService.loadLiveActions());
    _playbackService.updateRuntimeConfig(
      strictSponsorLock: _settingsService.strictSponsorLock,
      clearQueueOnStop: _settingsService.clearQueueOnStop,
      fallbackBehavior: _settingsService.fallbackBehavior,
    );
    unawaited(_registerGlobalHotkeys());
    notifyListeners();
  }

  void _syncFromPlaybackService() {
    _playbackState = _playbackService.playbackState;
    _fallbackCueLabel = _service.loadFallbackCueLabel();
    final durations = _cueDurations();
    _queue = _playbackService.queueState.entries
        .map(
          (entry) => LiveCueModel(
            id: entry.id,
            title: entry.cue.title,
            category: _categoryForCue(entry.cue),
            status: 'queued',
            remainingMs: durations[entry.cue.title] ?? 7000,
            queuedAt: entry.enqueuedAt,
          ),
        )
        .toList(growable: false);
    _logs = _playbackService.logs;
    if (hasTransportError) {
      _settingsService.setLastVlcError(_playbackState.lastError ?? _playbackState.transportMessage);
    }
    _liveRuntimeState.update(playbackState: _playbackState, queue: _queue, vlcRunning: _playbackService.isVlcRunning);
  }

  String _categoryForCue(Cue cue) {
    if (cue.cueType == CueType.lockedSponsor) return 'advertising';
    if (cue.cueType == CueType.fallback) return 'safety';
    if (cue.title == 'Nächster Spieler') return 'intro';
    return 'game';
  }

  Future<void> _registerGlobalHotkeys() async {
    try {
      await _globalHotkeyService.registerHotkeys(
        bindings: _settingsService.currentHotkeyMap(),
        onTriggered: (label) {
          final action = _actions.where((item) => item.label == label).cast<LiveActionConfig?>().firstWhere((item) => item != null, orElse: () => null);
          if (action == null) {
            return;
          }
          triggerAction(action);
        },
      );
    } catch (error) {
      debugPrint('Globale Hotkeys konnten nicht registriert werden: $error');
    }

    notifyListeners();
  }

  Future<void> _initializeRuntimeContext() async {
    final project = _activeProjectState.activeProject ?? await _projectRepository.getActiveProject();
    if (project != null && _activeProjectState.activeProject == null) {
      _activeProjectState.setActiveProject(project);
    } else {
      _activeProject = project;
    }

    await _refreshMediaIndex();
    notifyListeners();
  }

  Future<void> _refreshMediaIndex() async {
    try {
      final assets = await _mediaRepository.getAllMediaAssets();
      _mediaTitleById = {
        for (final asset in assets.where((item) => item.isActive && item.title.trim().isNotEmpty)) asset.id: asset.title,
      };
    } catch (_) {
      _mediaTitleById = const {};
    }
  }

  void _onActiveProjectChanged() {
    _activeProject = _activeProjectState.activeProject;
    notifyListeners();
  }

  Cue _buildCueFromAction(LiveActionConfig action, {String? fallbackTitle}) {
    final resolvedMediaAssetId = _resolveMediaAssetIdForAction(action);
    final resolvedTitle = _resolveCueTitleForAction(action);

    return Cue(
      id: 'cue_${DateTime.now().microsecondsSinceEpoch}',
      mediaAssetId: resolvedMediaAssetId ?? action.id,
      title: fallbackTitle ?? resolvedTitle,
      cueType: action.cueType,
      isLocked: action.cueType == CueType.lockedSponsor,
      canInterrupt: action.canInterrupt,
      mustPlayToEnd: false,
      autoReturnToFallback: false,
      queueIfBlocked: true,
      queueBehavior: action.queueBehavior,
      triggerMode: CueTriggerMode.manual,
      hotkey: action.hotkey,
      isFavorite: action.cueType == CueType.lockedSponsor,
      notes: action.label,
    );
  }

  String _resolveCueTitleForAction(LiveActionConfig action) {
    final mediaAssetId = _resolveMediaAssetIdForAction(action);
    if (mediaAssetId != null) {
      final title = _mediaTitleById[mediaAssetId];
      if (title != null && title.trim().isNotEmpty) {
        return title;
      }
    }
    return action.label;
  }

  String? _resolveMediaAssetIdForAction(LiveActionConfig action) {
    final slotFromProject = _resolveProjectSlotForAction(action);
    if (slotFromProject != null && slotFromProject.trim().isNotEmpty) {
      return slotFromProject;
    }

    final fromAction = action.mediaAssetId?.trim();
    if (fromAction != null && fromAction.isNotEmpty) {
      return fromAction;
    }

    return null;
  }

  String? _resolveProjectSlotForAction(LiveActionConfig action) {
    final project = _activeProject;
    if (project == null) {
      return null;
    }

    return switch (action.id) {
      'goal' => project.goalCueId,
      'penalty' => project.penaltyCueId,
      'seven_meter' => project.sevenMeterCueId,
      'yellow_card' => project.yellowCardCueId,
      'red_card' => project.redCardCueId,
      'timeout_home' => project.timeoutHomeCueId,
      'timeout_guest' => project.timeoutGuestCueId,
      'timeout' => project.timeoutHomeCueId ?? project.timeoutGuestCueId,
      'wiper' => project.wiperCueId,
      'intro' => project.introCueId,
      'sponsor_loop' => project.sponsorLoopCueId,
      'halftime' => project.halftimeCueId,
      'game_end' => project.gameEndCueId,
      'fallback' => project.fallbackCueId,
      'fallback_default' => project.fallbackCueId,
      _ => null,
    };
  }

  Map<String, int> _cueDurations() {
    return {
      for (final action in _actions) action.label: _service.fallbackDurationFor(action),
    };
  }

  List<LiveActionConfig> _sortedEnabledActions(List<LiveActionConfig> actions) {
    final filtered = actions.where((item) => item.enabled).toList(growable: false);
    filtered.sort((a, b) => a.priority.compareTo(b.priority));
    return filtered;
  }

  LiveActionConfig _defaultBlackScreenAction() {
    return const LiveActionConfig(
      id: 'black_screen_fallback',
      label: 'Black Screen',
      actionType: LiveActionType.blackScreenOn,
      group: LiveActionGroup.safety,
      color: LiveActionColorSemantic.neutral,
      hotkey: null,
      enabled: true,
      priority: 999,
      queueBehavior: QueueBehavior.replace,
      canInterrupt: true,
      cueType: CueType.fallback,
      mediaAssetId: null,
    );
  }

  LiveActionConfig _defaultFallbackAction() {
    return const LiveActionConfig(
      id: 'fallback',
      label: 'Fallback',
      actionType: LiveActionType.triggerCue,
      group: LiveActionGroup.safety,
      color: LiveActionColorSemantic.neutral,
      hotkey: null,
      enabled: true,
      priority: 0,
      queueBehavior: QueueBehavior.replace,
      canInterrupt: true,
      cueType: CueType.fallback,
      mediaAssetId: null,
    );
  }

  @override
  void dispose() {
    _activeProjectState.removeListener(_onActiveProjectChanged);
    _settingsService.removeListener(_onSettingsChanged);
    unawaited(_globalHotkeyService.unregisterAll());
    _playbackService.removeListener(_onPlaybackChanged);
    _playbackService.dispose();
    super.dispose();
  }
}
