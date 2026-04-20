import 'package:led_managementsoftware_app/core/services/playback_service.dart';
import 'package:led_managementsoftware_app/features/playback/domain/playback_state.dart';

class PlaybackController {
  PlaybackController(this.service);

  final PlaybackService service;

  PlaybackState get currentState => service.currentState;
  Stream<PlaybackState> get stateStream => service.stateStream;
  String? get lastError => service.lastError;

  Future<void> startClip(String mediaId) => service.startClip(mediaId);
  Future<void> pause() => service.pause();
  Future<void> resume() => service.resume();
  Future<void> stop() => service.stop();
  Future<void> nextClip() => service.nextClip();
  Future<void> loadScene(String sceneId) => service.loadScene(sceneId);
}
