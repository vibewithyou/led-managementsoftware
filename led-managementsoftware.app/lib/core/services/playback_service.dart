import 'package:led_managementsoftware_app/features/playback/domain/playback_state.dart';

abstract class PlaybackService {
  PlaybackState get currentState;
  Stream<PlaybackState> get stateStream;
  String? get lastError;

  Future<void> startClip(String mediaId);
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> nextClip();
  Future<void> loadScene(String sceneId);
  Future<void> emitEngineError(String message);
}
