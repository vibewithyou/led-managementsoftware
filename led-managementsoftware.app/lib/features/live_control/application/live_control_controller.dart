import 'dart:collection';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:led_managementsoftware_app/core/config/backend_config.dart';
import 'package:led_managementsoftware_app/core/config/backend_runtime.dart';
import 'package:led_managementsoftware_app/core/services/local_playback_service.dart';
import 'package:led_managementsoftware_app/core/services/supabase_sync_service.dart';
import 'package:led_managementsoftware_app/domain/entities/live_log_entry.dart';
import 'package:led_managementsoftware_app/domain/entities/queue_state.dart';
import 'package:led_managementsoftware_app/domain/entities/scene.dart';
import 'package:led_managementsoftware_app/domain/entities/scene_clip.dart';
import 'package:led_managementsoftware_app/domain/enums/interruption_policy.dart';
import 'package:led_managementsoftware_app/domain/enums/return_behavior.dart';
import 'package:led_managementsoftware_app/domain/enums/scene_category.dart';
import 'package:led_managementsoftware_app/domain/enums/sync_status.dart';
import 'package:led_managementsoftware_app/features/playback/application/playback_controller.dart';
import 'package:led_managementsoftware_app/features/playback/domain/playback_state.dart';
import 'package:led_managementsoftware_app/features/live_control/domain/live_action_catalog.dart';
import 'package:led_managementsoftware_app/features/sync/application/sync_controller.dart';
import 'package:led_managementsoftware_app/features/sync/domain/sync_scope.dart';

class LiveControlController extends ChangeNotifier {
  LiveControlController({
    BackendRuntime? backendRuntime,
    PlaybackController? playbackController,
    SyncController? syncController,
  })  : backendRuntime = backendRuntime ?? _offlineRuntime,
        _playbackController = playbackController ?? PlaybackController(LocalPlaybackService()),
        _syncController = syncController ??
            SyncController(
              SupabaseSyncService(runtime: backendRuntime ?? _offlineRuntime),
            ) {
    _scenes = _buildScenes();
    final initialScene = _scenes.firstWhere((scene) => scene.isDefault, orElse: () => _scenes.first);
    _queueState = QueueState(
      id: 'queue-main',
      projectId: 'project-live',
      activeSceneId: initialScene.id,
      currentClipIndex: 0,
      nextClipIndex: initialScene.clips.length > 1 ? 1 : 0,
      isPaused: false,
    );
    _currentClip = _sortedClips(initialScene).first;
    _bindPlaybackState();
    _startCurrentClip();
  }

  final PlaybackController _playbackController;
  final SyncController _syncController;
  final BackendRuntime backendRuntime;
  final List<String> homeActions = LiveActionCatalog.homeColumnLabels;
  final List<String> awayActions = LiveActionCatalog.awayColumnLabels;

  late final List<Scene> _scenes;
  late QueueState _queueState;
  late SceneClip _currentClip;
  PlaybackState _playbackState = PlaybackState.initial();
  StreamSubscription<PlaybackState>? _playbackSubscription;
  final List<LiveLogEntry> _logs = [];
  final Map<String, int> _rotationIndexByGroup = {};
  String? _pendingSceneId;
  SyncStatus _projectSync = SyncStatus.localOnly;

  static const BackendRuntime _offlineRuntime = BackendRuntime(
    config: BackendConfig(
      environment: 'local-offline',
      enableRemoteSync: false,
      mainDeviceId: 'main-pc',
      mainPcPriority: true,
    ),
    statusMessage: 'Offline-Modus aktiv (lokal).',
  );

  QueueState get queueState => _queueState;
  PlaybackState get playbackState => _playbackState;
  UnmodifiableListView<LiveLogEntry> get logs => UnmodifiableListView(_logs);
  String get activeSceneName => _activeScene.name;
  String get currentClipLabel => _currentClip.mediaItemId;
  String get nextClipLabel => _clipAt(_queueState.nextClipIndex)?.mediaItemId ?? '-';
  bool get hasProtectedClip => _currentClip.isProtected;
  SyncStatus get projectSync => _projectSync;

  Future<void> pauseQueue() async {
    _queueState = _queueState.copyWith(isPaused: true);
    await _playbackController.pause();
    _addLog('Queue pausiert', details: 'Aktive Szene: ${_activeScene.name}');
    notifyListeners();
  }

  Future<void> resumeQueue() async {
    _queueState = _queueState.copyWith(isPaused: false);
    await _playbackController.resume();
    _addLog('Queue fortgesetzt', details: 'Aktive Szene: ${_activeScene.name}');
    notifyListeners();
  }

  Future<void> stopPlayback() async {
    await _playbackController.stop();
    _addLog('Playback gestoppt', details: 'Bedienaktion in Live-Control');
    notifyListeners();
  }

  Future<void> startPlayback() async {
    await _startCurrentClip();
    _addLog('Playback gestartet', details: 'Clip ${_currentClip.mediaItemId}');
    notifyListeners();
  }

  Future<void> skipClip() async {
    await _advanceQueue();
    _addLog('Clip übersprungen', details: 'Neuer Clip: ${_currentClip.mediaItemId}');
    notifyListeners();
  }

  Future<void> returnToPreviousScene() async {
    final interruptedSceneId = _queueState.interruptedBySceneId;
    if (interruptedSceneId == null) {
      return;
    }
    final returnIndex = _queueState.returnClipIndex ?? 0;
    await _switchScene(
      interruptedSceneId,
      currentClipIndex: returnIndex,
      interruptedBySceneId: null,
      returnClipIndex: null,
      returnTimestamp: null,
    );
    _addLog('Rückkehr ausgeführt', details: 'Zur Szene ${_activeScene.name} an Index $returnIndex');
    notifyListeners();
  }

  Future<void> changeScene(String sceneId) async {
    await _switchScene(sceneId, currentClipIndex: 0);
    _addLog('Szenenwechsel', details: 'Manueller Wechsel zu ${_activeScene.name}');
    notifyListeners();
  }

  Future<void> triggerQuickAction(String action) async {
    final rule = LiveActionCatalog.resolve(action);
    if (rule == null || !rule.action.isEnabled) {
      _addLog('Systemwarnung', details: 'Keine Szene für Aktion $action', success: false);
      notifyListeners();
      return;
    }

    if (_currentClip.isProtected && !rule.action.canInterruptProtectedClip) {
      _addLog('Unterbrechung blockiert', details: 'Aktion $action darf Schutzclip nicht unterbrechen', success: false);
      notifyListeners();
      return;
    }

    if (_currentClip.interruptionPolicy == InterruptionPolicy.sceneEnd) {
      _addLog('Unterbrechung nicht erlaubt', details: 'Clip erlaubt keine Unterbrechung');
      notifyListeners();
      return;
    }

    final deferUntilClipEnd = !rule.action.startsImmediately ||
        _currentClip.interruptionPolicy == InterruptionPolicy.queueEnd;
    if (deferUntilClipEnd) {
      _pendingSceneId = rule.sceneId;
      _addLog('Unterbrechung geplant', details: 'Aktion $action nach aktuellem Clip');
      notifyListeners();
      return;
    }

    await _switchScene(
      rule.sceneId,
      currentClipIndex: 0,
      interruptedBySceneId: _queueState.activeSceneId,
      returnClipIndex: _queueState.currentClipIndex,
      returnTimestamp: DateTime.now(),
    );
    _addLog('Unterbrechung sofort', details: 'Aktion $action startet Szene ${_activeScene.name}');
    notifyListeners();
  }

  Future<void> syncNow() async {
    await _syncController.syncNow();
    final snapshot = await _syncController.snapshot('project-live', SyncScope.project);
    _projectSync = snapshot.status;
    _addLog('Sync', details: 'Projektstatus: ${snapshot.status.label}');
    notifyListeners();
  }

  Future<void> simulateSyncConflict() async {
    final conflict = await _syncController.detectConflict(
      entityId: 'project-live',
      localVersion: 4,
      remoteVersion: 6,
    );
    if (conflict == null) {
      return;
    }
    _addLog('Sync-Konflikt', details: 'Konflikt erkannt für ${conflict.entityId}');
    await _syncController.resolveConflict(conflict, mainPcWins: true);
    _projectSync = SyncStatus.synced;
    _addLog('Konflikt aufgelöst', details: 'Haupt-PC-Regel angewendet');
    notifyListeners();
  }

  Future<void> _advanceQueue() async {
    if (_queueState.isPaused) {
      return;
    }

    final clips = _sortedClips(_activeScene);
    var next = _queueState.currentClipIndex + 1;
    if (next >= clips.length) {
      if (_pendingSceneId != null) {
        final scene = _pendingSceneId!;
        _pendingSceneId = null;
        await _switchScene(scene, currentClipIndex: 0);
        return;
      }

      if (_queueState.interruptedBySceneId != null) {
        await returnToPreviousScene();
        return;
      }

      next = _activeScene.isLooping ? 0 : clips.length - 1;
    }

    _queueState = _queueState.copyWith(
      currentClipIndex: next,
      nextClipIndex: _nextIndex(next, clips.length),
    );
    _currentClip = _pickClipWithRotation(clips[next], clips);
    await _startCurrentClip();
  }

  Future<void> _switchScene(
    String sceneId, {
    required int currentClipIndex,
    String? interruptedBySceneId,
    int? returnClipIndex,
    DateTime? returnTimestamp,
  }) async {
    final scene = _scenes.firstWhere((entry) => entry.id == sceneId);
    final clips = _sortedClips(scene);
    final safeIndex = currentClipIndex.clamp(0, clips.length - 1);

    _queueState = _queueState.copyWith(
      activeSceneId: sceneId,
      currentClipIndex: safeIndex,
      nextClipIndex: _nextIndex(safeIndex, clips.length),
      interruptedBySceneId: interruptedBySceneId,
      returnClipIndex: returnClipIndex,
      returnTimestamp: returnTimestamp,
    );
    _currentClip = _pickClipWithRotation(clips[safeIndex], clips);
    await _playbackController.loadScene(sceneId);
    await _startCurrentClip();
  }

  Future<void> _startCurrentClip() async {
    await _playbackController.startClip(_currentClip.mediaItemId);
  }

  void _bindPlaybackState() {
    _playbackSubscription = _playbackController.stateStream.listen((state) {
      _playbackState = state;
      if (state.error.message.isNotEmpty) {
        _addLog('VLC-Fehler', details: state.error.message, success: false);
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _playbackSubscription?.cancel();
    super.dispose();
  }

  int _nextIndex(int current, int length) {
    if (length <= 1) {
      return current;
    }
    return current + 1 >= length ? 0 : current + 1;
  }

  Scene get _activeScene => _scenes.firstWhere((entry) => entry.id == _queueState.activeSceneId);

  SceneClip? _clipAt(int index) {
    final clips = _sortedClips(_activeScene);
    if (index < 0 || index >= clips.length) {
      return null;
    }
    return clips[index];
  }

  SceneClip _pickClipWithRotation(SceneClip clip, List<SceneClip> clips) {
    final group = clip.rotationGroup;
    if (group == null) {
      return clip;
    }
    final grouped = clips.where((entry) => entry.rotationGroup == group).toList()..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    if (grouped.isEmpty) {
      return clip;
    }

    final currentIndex = _rotationIndexByGroup[group] ?? -1;
    final nextIndex = (currentIndex + 1) % grouped.length;
    _rotationIndexByGroup[group] = nextIndex;
    return grouped[nextIndex];
  }

  List<SceneClip> _sortedClips(Scene scene) {
    final clips = [...scene.clips]..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return clips;
  }

  void _addLog(String action, {required String details, bool success = true}) {
    final entry = LiveLogEntry(
      id: 'log-${DateTime.now().microsecondsSinceEpoch}',
      projectId: 'project-live',
      timestamp: DateTime.now(),
      deviceId: 'main-pc',
      actorName: 'Operator',
      action: action,
      details: details,
      success: success,
    );
    _logs.add(entry);
  }

  List<Scene> _buildScenes() {
    final now = DateTime.now();
    Scene scene(
      String id,
      String name,
      SceneCategory category,
      List<SceneClip> clips, {
      bool isDefault = false,
      bool isLooping = true,
    }) {
      return Scene(
        id: id,
        projectId: 'project-live',
        name: name,
        category: category,
        isLooping: isLooping,
        isActive: true,
        isDefault: isDefault,
        fallbackSceneId: 'scene-live',
        createdAt: now,
        updatedAt: now,
        clips: clips,
      );
    }

    List<SceneClip> clips(String sceneId, String prefix, {String? group, bool protected = false}) {
      return [
        SceneClip(
          id: '$sceneId-1',
          sceneId: sceneId,
          mediaItemId: '$prefix-clip-a',
          orderIndex: 0,
          isProtected: protected,
          isOverridable: !protected,
          priority: 1,
          playOnce: false,
          repeatable: true,
          rotationGroup: group,
          interruptionPolicy: protected ? InterruptionPolicy.queueEnd : InterruptionPolicy.immediate,
          returnBehavior: ReturnBehavior.toPreviousClip,
        ),
        SceneClip(
          id: '$sceneId-2',
          sceneId: sceneId,
          mediaItemId: '$prefix-clip-b',
          orderIndex: 1,
          isProtected: false,
          isOverridable: true,
          priority: 1,
          playOnce: false,
          repeatable: true,
          rotationGroup: group,
          interruptionPolicy: InterruptionPolicy.immediate,
          returnBehavior: ReturnBehavior.toPreviousClip,
        ),
      ];
    }

    return [
      scene('scene-pre', 'Vor dem Spiel', SceneCategory.preGame, clips('scene-pre', 'pregame'), isDefault: true),
      scene('scene-live', 'Während des Spiels', SceneCategory.inGame, clips('scene-live', 'tvon', group: 'tvon', protected: true)),
      scene('scene-break', 'Pause', SceneCategory.breakTime, clips('scene-break', 'break')),
      scene('scene-post', 'Nach dem Spiel', SceneCategory.postGame, clips('scene-post', 'post')),
      scene('scene-intro-home', 'Einlauf Heim', SceneCategory.specialAction, clips('scene-intro-home', 'intro-home')),
      scene('scene-intro-away', 'Einlauf Gegner', SceneCategory.specialAction, clips('scene-intro-away', 'intro-away')),
      scene('scene-special-home', '2 Minuten Heim', SceneCategory.specialAction, clips('scene-special-home', 'penalty-home'), isLooping: false),
      scene('scene-special-away', '2 Minuten Gegner', SceneCategory.specialAction, clips('scene-special-away', 'penalty-away'), isLooping: false),
      scene('scene-timeout-home', 'Timeout Heim', SceneCategory.specialAction, clips('scene-timeout-home', 'timeout-home'), isLooping: false),
      scene('scene-timeout-away', 'Timeout Gegner', SceneCategory.specialAction, clips('scene-timeout-away', 'timeout-away'), isLooping: false),
      scene('scene-card', 'Rote Karte', SceneCategory.specialAction, clips('scene-card', 'red-card'), isLooping: false),
      scene('scene-wiper', 'Wischer', SceneCategory.specialAction, clips('scene-wiper', 'wiper'), isLooping: false),
      scene('scene-goal-home', 'Tor Heim', SceneCategory.specialAction, clips('scene-goal-home', 'goal-home'), isLooping: false),
      scene('scene-goal-away', 'Tor Gegner', SceneCategory.specialAction, clips('scene-goal-away', 'goal-away'), isLooping: false),
      scene('scene-injury-home', 'Verletzung Heim', SceneCategory.specialAction, clips('scene-injury-home', 'injury-home'), isLooping: false),
      scene('scene-injury-away', 'Verletzung Gegner', SceneCategory.specialAction, clips('scene-injury-away', 'injury-away'), isLooping: false),
    ];
  }
}
