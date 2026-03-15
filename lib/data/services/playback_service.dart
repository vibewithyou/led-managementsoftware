import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:led_management_software/domain/entities/cue.dart';
import 'package:led_management_software/domain/entities/cue_execution.dart';
import 'package:led_management_software/domain/entities/live_event_log.dart';
import 'package:led_management_software/domain/entities/playback_state.dart';
import 'package:led_management_software/domain/entities/queue_entry.dart';
import 'package:led_management_software/domain/entities/queue_state.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/live_action_type.dart';
import 'package:led_management_software/domain/enums/playback_status.dart';

/// Central playback engine for locked sponsor behavior, queue handling and fallback logic.
class PlaybackService extends ChangeNotifier {
  PlaybackService({
    required String projectId,
    required Cue fallbackCue,
    required Map<String, int> cueDurationsMs,
  })  : _projectId = projectId,
        _fallbackCue = fallbackCue,
        _cueDurationsMs = cueDurationsMs,
        _playbackState = PlaybackState.initial(projectId: projectId),
        _queueState = QueueState.initial(projectId: projectId);

  final String _projectId;
  final Cue _fallbackCue;
  final Map<String, int> _cueDurationsMs;

  PlaybackState _playbackState;
  QueueState _queueState;
  CueExecution? _currentExecution;
  final List<LiveEventLog> _logs = [];

  Timer? _ticker;

  PlaybackState get playbackState => _playbackState;

  QueueState get queueState => _queueState;

  CueExecution? get currentExecution => _currentExecution;

  List<LiveEventLog> get logs => List.unmodifiable(_logs);

  /// Starts a cue unless a locked cue is running; in that case the cue is queued.
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
      lastError: null,
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

    _startTicker();
    notifyListeners();
  }

  /// Adds a cue to queue and marks state as queued when idle/playing transitions are needed.
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

  /// Stops current playback and optionally clears queue; used by stop action and black-screen handling.
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
    );

    _appendLog(
      actionType: LiveActionType.stopCue,
      cueId: null,
      result: 'stopped',
      metadata: {'triggerSource': triggerSource},
    );

    notifyListeners();
  }

  /// Returns playback to standard fallback sponsor loop.
  void returnToFallback({String triggerSource = 'auto'}) {
    startCue(_fallbackCue, triggerSource: triggerSource);
  }

  /// Handles cue completion according to lock and one-shot rules.
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
      startCue(next.cue, triggerSource: 'queue');
      return;
    }

    // One-shot cues return automatically to fallback.
    if (finishedCue != null && finishedCue.cueType == CueType.oneShot) {
      returnToFallback(triggerSource: 'auto_oneshot_finished');
      return;
    }

    // Locked or regular cues with empty queue also return to fallback by default.
    returnToFallback(triggerSource: 'auto_finished');
  }

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

    notifyListeners();
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
    return _cueDurationsMs[cue.title] ?? 7000;
  }

  void _appendLog({
    required LiveActionType actionType,
    required String? cueId,
    required String result,
    Map<String, dynamic>? metadata,
  }) {
    _logs.add(
      LiveEventLog(
        id: 'log_${DateTime.now().microsecondsSinceEpoch}',
        projectId: _projectId,
        cueId: cueId,
        actionType: actionType,
        timestamp: DateTime.now(),
        operatorName: 'system',
        result: result,
        errorMessage: null,
        metadata: metadata,
      ),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
