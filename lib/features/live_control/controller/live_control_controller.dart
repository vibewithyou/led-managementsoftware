import 'package:flutter/foundation.dart';
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

/// Manages live trigger behavior, sponsor lock handling and playback progress.
class LiveControlController extends ChangeNotifier {
  LiveControlController({LiveControlService? service}) : _service = service ?? const LiveControlService() {
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
    _syncFromPlaybackService();

    if (_playbackState.status == PlaybackStatus.idle) {
      _playbackService.returnToFallback(triggerSource: 'bootstrap');
    }
  }

  final LiveControlService _service;
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

  List<String> get eventButtons => _eventButtons;

  bool get sponsorLockedRunning => _playbackService.playbackState.status == PlaybackStatus.locked;

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

  void _onPlaybackChanged() {
    _syncFromPlaybackService();
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
    _playbackService.removeListener(_onPlaybackChanged);
    _playbackService.dispose();
    super.dispose();
  }
}
