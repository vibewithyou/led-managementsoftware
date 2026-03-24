import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:led_management_software/data/repositories/media_repository_impl.dart';
import 'package:led_management_software/data/repositories/live_log_repository_impl.dart';
import 'package:led_management_software/domain/entities/cue.dart';
import 'package:led_management_software/domain/entities/cue_execution.dart';
import 'package:led_management_software/domain/entities/live_event_log.dart';
import 'package:led_management_software/domain/entities/playback_state.dart';
import 'package:led_management_software/domain/entities/queue_entry.dart';
import 'package:led_management_software/domain/entities/queue_state.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/live_action_type.dart';
import 'package:led_management_software/domain/enums/playback_status.dart';
import 'package:led_management_software/domain/enums/transport_status.dart';
import 'package:led_management_software/domain/repositories/live_log_repository.dart';
import 'package:led_management_software/domain/repositories/media_repository.dart';
import 'package:led_management_software/data/services/vlc_bridge_service.dart';

/// Central playback engine for locked sponsor behavior, queue handling and fallback logic.
class PlaybackService extends ChangeNotifier {
  PlaybackService({
    required String projectId,
    required Cue fallbackCue,
    required Map<String, int> cueDurationsMs,
    LiveLogRepository? liveLogRepository,
    MediaRepository? mediaRepository,
    VlcService? vlcService,
  })  : _projectId = projectId,
        _fallbackCue = fallbackCue,
        _cueDurationsMs = cueDurationsMs,
        _liveLogRepository = liveLogRepository ?? LiveLogRepositoryImpl(),
        _mediaRepository = mediaRepository ?? MediaRepositoryImpl(),
        _vlcService = vlcService ?? VlcService(),
        _playbackState = PlaybackState.initial(projectId: projectId),
        _queueState = QueueState.initial(projectId: projectId) {
    _vlcStatusSubscription = _vlcService.statusStream.listen(_handleVlcStatusUpdate);
    unawaited(_warmMediaDurationCache());
  }

  final String _projectId;
  final Cue _fallbackCue;
  final Map<String, int> _cueDurationsMs;
  final LiveLogRepository _liveLogRepository;
  final MediaRepository _mediaRepository;
  final VlcService _vlcService;

  PlaybackState _playbackState;
  QueueState _queueState;
  CueExecution? _currentExecution;
  final List<LiveEventLog> _logs = [];

  Timer? _ticker;
  StreamSubscription<VlcStatusSnapshot>? _vlcStatusSubscription;
  final Map<String, int> _resolvedDurationsByMediaAssetId = {};

  PlaybackState get playbackState => _playbackState;

  QueueState get queueState => _queueState;

  CueExecution? get currentExecution => _currentExecution;

  List<LiveEventLog> get logs => List.unmodifiable(_logs);

  bool get isVlcRunning => _vlcService.isRunning();
  TransportStatus get transportStatus => _playbackState.transportStatus;
  String get transportMessage => _playbackState.transportMessage;

  String get projectId => _projectId;

  Cue get fallbackCue => _fallbackCue;

  /// Starts playback for a cue and mirrors that state back into the UI.
  ///
  /// Flow:
  /// - Black screen cues interrupt immediately and stop VLC output.
  /// - Locked cues block new playback and send incoming cues into the queue.
  /// - All other cues update playback state first, then trigger VLC asynchronously.
  void startCue(Cue cue, {String triggerSource = 'manual'}) {
    if (_isBlackScreenCue(cue)) {
      _interruptWithBlackScreen(cue, triggerSource: triggerSource);
      return;
    }

    if (_isLockedCueRunning()) {
      queueCue(cue, reason: 'locked_running');
      return;
    }

    final duration = _durationFor(cue);
    final now = DateTime.now();
    final isLocked = cue.isLocked || cue.cueType == CueType.lockedSponsor;

    _playbackState = _playbackState.copyWith(
      status: isLocked ? PlaybackStatus.locked : PlaybackStatus.playing,
      currentCue: cue,
      currentMediaPositionMs: 0,
      remainingMs: duration,
      startedAt: now,
      isLocked: isLocked,
      isBlackScreen: false,
      lastAction: LiveActionType.triggerCue,
      // Clear previous transport errors as soon as a fresh cue starts.
      lastError: null,
      transportStatus: TransportStatus.starting,
      transportMessage: 'Wiedergabe wird vorbereitet …',
    );

    _currentExecution = CueExecution(
      id: 'exec_${now.microsecondsSinceEpoch}',
      projectId: _projectId,
      cue: cue,
      startedAt: now,
      expectedDurationMs: duration,
      expectedEndAt: now.add(Duration(milliseconds: duration)),
      triggerSource: triggerSource,
    );

    _appendLog(
      actionType: LiveActionType.triggerCue,
      cueId: cue.id,
      result: 'started',
      metadata: {
        'status': _playbackState.status.value,
        'triggerSource': triggerSource,
      },
    );

    unawaited(_playCueInVlc(cue, triggerSource: triggerSource));

    _startTicker();
    notifyListeners();
  }

  /// Queues a cue when playback is currently blocked by a locked clip.
  void queueCue(Cue cue, {String reason = 'blocked'}) {
    final now = DateTime.now();
    final entry = QueueEntry(
      id: 'queue_${now.microsecondsSinceEpoch}',
      projectId: _projectId,
      cue: cue,
      enqueuedAt: now,
      reason: reason,
      priority: 0,
    );

    _queueState = _queueState.copyWith(
      entries: [..._queueState.entries, entry],
      updatedAt: now,
    );

    _playbackState = _playbackState.copyWith(
      status: _isLockedCueRunning() ? PlaybackStatus.locked : PlaybackStatus.queued,
      lastAction: LiveActionType.queueAdd,
    );

    _appendLog(
      actionType: LiveActionType.queueAdd,
      cueId: cue.id,
      result: 'queued',
      metadata: {
        'reason': reason,
        'queueLength': _queueState.entries.length,
      },
    );

    notifyListeners();
  }

  /// Stops the active cue and resets the transport/UI state.
  ///
  /// Edge cases:
  /// - calling stop while idle is safe
  /// - queue clearing remains optional because operators may want to preserve it
  void stopCue({bool clearQueue = false, String triggerSource = 'manual'}) {
    _ticker?.cancel();
    _currentExecution = null;

    if (clearQueue) {
      _queueState = _queueState.copyWith(entries: const [], updatedAt: DateTime.now());
      _appendLog(
        actionType: LiveActionType.queueClear,
        cueId: null,
        result: 'cleared',
        metadata: {'triggerSource': triggerSource},
      );
    }

    _playbackState = _playbackState.copyWith(
      status: PlaybackStatus.idle,
      currentCue: null,
      currentMediaPositionMs: 0,
      remainingMs: 0,
      startedAt: null,
      isLocked: false,
      isBlackScreen: false,
      lastAction: LiveActionType.stopCue,
      lastError: null,
      transportStatus: TransportStatus.stopped,
      transportMessage: 'VLC gestoppt',
    );

    _appendLog(
      actionType: LiveActionType.stopCue,
      cueId: null,
      result: 'stopped',
      metadata: {'triggerSource': triggerSource},
    );

    unawaited(_stopVlcPlayback(triggerSource: triggerSource));

    notifyListeners();
  }

  /// Returns playback to the configured fallback cue.
  void returnToFallback({String triggerSource = 'auto'}) {
    startCue(_fallbackCue, triggerSource: triggerSource);
  }

  /// Finalizes a cue and performs the next transport transition.
  ///
  /// Flow:
  /// - current VLC playback is stopped first
  /// - queued content has priority
  /// - finished one-shots return to fallback
  /// - all other completed cues also return to fallback by default
  void handleCueFinished() {
    final finishedCue = _playbackState.currentCue;

    if (finishedCue != null) {
      _appendLog(
        actionType: LiveActionType.stopCue,
        cueId: finishedCue.id,
        result: 'finished',
        metadata: {'cueType': finishedCue.cueType.value},
      );
    }

    _ticker?.cancel();
    _currentExecution = null;

    unawaited(_handleCueFinishedTransition(finishedCue));
  }

  /// Black screen is modeled as a local UI/output state:
  /// VLC output is stopped and the app state flips to `black` so the UI stays in sync.
  ///
  /// A dedicated black-frame transport command can be added later without touching UI code.
  void _interruptWithBlackScreen(Cue blackCue, {required String triggerSource}) {
    _ticker?.cancel();

    _queueState = _queueState.copyWith(entries: const [], updatedAt: DateTime.now());

    _playbackState = _playbackState.copyWith(
      status: PlaybackStatus.black,
      currentCue: blackCue,
      currentMediaPositionMs: 0,
      remainingMs: 0,
      startedAt: DateTime.now(),
      isLocked: false,
      isBlackScreen: true,
      lastAction: LiveActionType.blackScreenOn,
      lastError: null,
      transportStatus: TransportStatus.stopped,
      transportMessage: 'Black Screen aktiv',
    );

    _currentExecution = CueExecution(
      id: 'exec_black_${DateTime.now().microsecondsSinceEpoch}',
      projectId: _projectId,
      cue: blackCue,
      startedAt: DateTime.now(),
      expectedDurationMs: 0,
      expectedEndAt: DateTime.now(),
      triggerSource: triggerSource,
    );

    _appendLog(
      actionType: LiveActionType.blackScreenOn,
      cueId: blackCue.id,
      result: 'interrupted_all',
      metadata: {'triggerSource': triggerSource},
    );

    unawaited(_stopVlcPlayback(triggerSource: '${triggerSource}_black_screen'));

    notifyListeners();
  }

  Future<void> _handleCueFinishedTransition(Cue? finishedCue) async {
    await _stopVlcPlayback(triggerSource: 'cue_finished');

    if (_queueState.entries.isNotEmpty) {
      final next = _queueState.entries.first;
      _queueState = _queueState.copyWith(
        entries: _queueState.entries.sublist(1),
        updatedAt: DateTime.now(),
      );
      _appendLog(
        actionType: LiveActionType.queueRemove,
        cueId: next.cue.id,
        result: 'dequeued',
        metadata: {'queueLength': _queueState.entries.length},
      );

      // UI is notified before the next cue begins so queue widgets reflect the dequeue instantly.
      notifyListeners();
      startCue(next.cue, triggerSource: 'queue');
      return;
    }

    // One-shot cues always hand off to fallback once their transport ends.
    if (finishedCue != null && finishedCue.cueType == CueType.oneShot) {
      returnToFallback(triggerSource: 'auto_oneshot_finished');
      return;
    }

    // Locked or regular cues with an empty queue also fall back to the safe loop.
    returnToFallback(triggerSource: 'auto_finished');
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final state = _playbackState;
      if (state.status != PlaybackStatus.playing && state.status != PlaybackStatus.locked) {
        return;
      }

      final nextPosition = state.currentMediaPositionMs + 250;
      final nextRemaining = state.remainingMs - 250;

      if (nextRemaining <= 0) {
        handleCueFinished();
        return;
      }

      _playbackState = state.copyWith(
        currentMediaPositionMs: nextPosition,
        remainingMs: nextRemaining,
      );
      notifyListeners();
    });
  }

  bool _isLockedCueRunning() {
    return _playbackState.status == PlaybackStatus.locked || _playbackState.isLocked;
  }

  bool _isBlackScreenCue(Cue cue) {
    return cue.title.toLowerCase() == 'black screen';
  }

  int _durationFor(Cue cue) {
    final fromOverrides = _cueDurationsMs[cue.id] ?? _cueDurationsMs[cue.mediaAssetId] ?? _cueDurationsMs[cue.title];
    if (fromOverrides != null && fromOverrides > 0) {
      return fromOverrides;
    }

    final mediaDuration = _resolvedDurationsByMediaAssetId[cue.mediaAssetId];
    if (mediaDuration != null && mediaDuration > 0) {
      return mediaDuration;
    }

    return 7000;
  }

  Future<void> _warmMediaDurationCache() async {
    try {
      final assets = await _mediaRepository.getAllMediaAssets();
      for (final asset in assets) {
        if (asset.durationMs > 0) {
          _resolvedDurationsByMediaAssetId[asset.id] = asset.durationMs;
        }
      }
    } catch (_) {
      // Cache warmup is best-effort; playback fallback stays active.
    }
  }

  void _appendLog({
    required LiveActionType actionType,
    required String? cueId,
    required String result,
    Map<String, dynamic>? metadata,
    String? errorMessage,
  }) {
    final log = LiveEventLog(
      id: 'log_${DateTime.now().microsecondsSinceEpoch}',
      projectId: _projectId,
      cueId: cueId,
      actionType: actionType,
      timestamp: DateTime.now(),
      operatorName: 'system',
      result: result,
      errorMessage: errorMessage,
      metadata: metadata,
    );

    _logs.add(log);
    unawaited(_liveLogRepository.appendLog(log));
  }

  Future<void> _playCueInVlc(Cue cue, {required String triggerSource}) async {
    try {
      final filePath = await _resolveMediaPath(cue);
      if (filePath == null || filePath.isEmpty) {
        debugPrint('[PlaybackService] No media path found for cue ${cue.title} (${cue.mediaAssetId}). VLC playback skipped.');
        _playbackState = _playbackState.copyWith(
          lastError: 'Kein Dateipfad für Cue "${cue.title}" gefunden.',
          transportStatus: TransportStatus.fileMissing,
          transportMessage: 'Datei fehlt',
        );
        notifyListeners();
        _appendLog(
          actionType: LiveActionType.triggerCue,
          cueId: cue.id,
          result: 'vlc_skipped',
          metadata: {
            'triggerSource': triggerSource,
            'reason': 'missing_media_path',
            'mediaAssetId': cue.mediaAssetId,
          },
        );
        return;
      }

      await _vlcService.setFullscreenOutput();
      await _vlcService.playFile(filePath);

      _playbackState = _playbackState.copyWith(lastError: null);
      notifyListeners();

      debugPrint('[PlaybackService] VLC playing file: $filePath');
      _appendLog(
        actionType: LiveActionType.triggerCue,
        cueId: cue.id,
        result: 'vlc_playing',
        metadata: {
          'triggerSource': triggerSource,
          'filePath': filePath,
          'vlcRunning': _vlcService.isRunning(),
        },
      );
    } catch (error) {
      debugPrint('[PlaybackService] VLC playback failed: $error');
      final userError = switch (error) {
        VlcOperationException(:final operatorMessage) => operatorMessage,
        _ => '$error',
      };
      _playbackState = _playbackState.copyWith(
        lastError: '$error',
        transportStatus: error is VlcOperationException && error.status == VlcTransportStatus.fileMissing
            ? TransportStatus.fileMissing
            : TransportStatus.error,
        transportMessage: userError,
      );
      notifyListeners();
      _appendLog(
        actionType: LiveActionType.triggerCue,
        cueId: cue.id,
        result: 'vlc_error',
        errorMessage: '$error',
        metadata: {
          'triggerSource': triggerSource,
          'mediaAssetId': cue.mediaAssetId,
        },
      );
    }
  }

  Future<void> _stopVlcPlayback({required String triggerSource}) async {
    try {
      final activeCueId = _playbackState.currentCue?.id;
      await _vlcService.stop();
      debugPrint('[PlaybackService] VLC stopped.');
      _appendLog(
        actionType: LiveActionType.stopCue,
        cueId: activeCueId,
        result: 'vlc_stopped',
        metadata: {
          'triggerSource': triggerSource,
        },
      );
    } catch (error) {
      debugPrint('[PlaybackService] VLC stop failed: $error');
      _playbackState = _playbackState.copyWith(lastError: '$error');
      notifyListeners();
      _appendLog(
        actionType: LiveActionType.stopCue,
        cueId: _playbackState.currentCue?.id,
        result: 'vlc_stop_error',
        errorMessage: '$error',
        metadata: {
          'triggerSource': triggerSource,
        },
      );
    }
  }

  void _handleVlcStatusUpdate(VlcStatusSnapshot snapshot) {
    final nextStatus = switch (snapshot.status) {
      VlcTransportStatus.ready => TransportStatus.ready,
      VlcTransportStatus.starting => TransportStatus.starting,
      VlcTransportStatus.playing => TransportStatus.playing,
      VlcTransportStatus.error => TransportStatus.error,
      VlcTransportStatus.fileMissing => TransportStatus.fileMissing,
      VlcTransportStatus.stopped => TransportStatus.stopped,
    };

    _playbackState = _playbackState.copyWith(
      transportStatus: nextStatus,
      transportMessage: snapshot.operatorMessage,
      lastError: snapshot.technicalMessage ?? _playbackState.lastError,
    );
    notifyListeners();
  }

  Future<String?> _resolveMediaPath(Cue cue) async {
    // Demo/live-control cues may not yet reference a persisted media asset.
    // In that case the service logs and skips transport instead of breaking playback state.
    if (cue.mediaAssetId.trim().isEmpty) {
      return null;
    }

    final mediaAsset = await _mediaRepository.getMediaAssetById(cue.mediaAssetId);
    final filePath = mediaAsset?.filePath.trim();
    if (filePath == null || filePath.isEmpty) {
      return null;
    }

    return filePath;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _vlcStatusSubscription?.cancel();
    unawaited(_vlcService.stop());
    _vlcService.dispose();
    super.dispose();
  }
}
