import 'dart:async';

import 'package:led_managementsoftware_app/core/services/playback_service.dart';
import 'package:led_managementsoftware_app/features/playback/domain/playback_error.dart';
import 'package:led_managementsoftware_app/features/playback/domain/playback_state.dart';
import 'package:led_managementsoftware_app/features/playback/domain/playback_status_model.dart';

class MockPlaybackService implements PlaybackService {
  final StreamController<PlaybackState> _controller = StreamController<PlaybackState>.broadcast();
  PlaybackState _state = PlaybackState.initial();

  @override
  PlaybackState get currentState => _state;

  @override
  Stream<PlaybackState> get stateStream => _controller.stream;

  @override
  String? get lastError =>
      _state.error.type == PlaybackErrorType.none ? null : _state.error.message;

  @override
  Future<void> loadScene(String sceneId) async {
    _state = _state.copyWith(currentSceneId: sceneId);
    _controller.add(_state);
  }

  @override
  Future<void> nextClip() async {
    _state = _state.copyWith(status: PlaybackStatusModel.playing);
    _controller.add(_state);
  }

  @override
  Future<void> pause() async {
    _state = _state.copyWith(status: PlaybackStatusModel.paused);
    _controller.add(_state);
  }

  @override
  Future<void> resume() async {
    _state = _state.copyWith(status: PlaybackStatusModel.playing);
    _controller.add(_state);
  }

  @override
  Future<void> startClip(String mediaId) async {
    _state = _state.copyWith(
      status: PlaybackStatusModel.playing,
      currentClipId: mediaId,
      error: PlaybackError.none,
    );
    _controller.add(_state);
  }

  @override
  Future<void> stop() async {
    _state = _state.copyWith(status: PlaybackStatusModel.idle, currentClipId: null);
    _controller.add(_state);
  }

  @override
  Future<void> emitEngineError(String message) async {
    _state = _state.copyWith(
      status: PlaybackStatusModel.error,
      error: PlaybackError(type: PlaybackErrorType.engineUnavailable, message: message),
    );
    _controller.add(_state);
  }
}
