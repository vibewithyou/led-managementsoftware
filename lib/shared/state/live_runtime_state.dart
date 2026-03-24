import 'package:flutter/foundation.dart';
import 'package:led_management_software/domain/entities/playback_state.dart';
import 'package:led_management_software/features/live_control/model/live_cue_model.dart';

class LiveRuntimeState extends ChangeNotifier {
  LiveRuntimeState._();

  static final LiveRuntimeState instance = LiveRuntimeState._();

  PlaybackState _playbackState = PlaybackState.initial(projectId: 'live_project');
  List<LiveCueModel> _queue = const [];
  bool _vlcRunning = false;

  PlaybackState get playbackState => _playbackState;
  List<LiveCueModel> get queue => _queue;
  bool get vlcRunning => _vlcRunning;

  void update({
    required PlaybackState playbackState,
    required List<LiveCueModel> queue,
    required bool vlcRunning,
  }) {
    _playbackState = playbackState;
    _queue = List<LiveCueModel>.unmodifiable(queue);
    _vlcRunning = vlcRunning;
    notifyListeners();
  }
}
