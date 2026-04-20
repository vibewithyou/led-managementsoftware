import 'package:led_managementsoftware_app/features/playback/domain/playback_error.dart';
import 'package:led_managementsoftware_app/features/playback/domain/playback_status_model.dart';

class PlaybackState {
  const PlaybackState({
    required this.status,
    this.currentClipId,
    this.currentSceneId,
    this.error = PlaybackError.none,
    this.updatedAt,
  });

  final PlaybackStatusModel status;
  final String? currentClipId;
  final String? currentSceneId;
  final PlaybackError error;
  final DateTime? updatedAt;

  factory PlaybackState.initial() {
    return PlaybackState(
      status: PlaybackStatusModel.idle,
      updatedAt: DateTime.now(),
    );
  }

  PlaybackState copyWith({
    PlaybackStatusModel? status,
    String? currentClipId,
    String? currentSceneId,
    PlaybackError? error,
    DateTime? updatedAt,
  }) {
    return PlaybackState(
      status: status ?? this.status,
      currentClipId: currentClipId ?? this.currentClipId,
      currentSceneId: currentSceneId ?? this.currentSceneId,
      error: error ?? this.error,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
