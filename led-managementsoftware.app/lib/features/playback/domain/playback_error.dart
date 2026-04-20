enum PlaybackErrorType { none, mediaMissing, engineUnavailable, interrupted, unknown }

class PlaybackError {
  const PlaybackError({
    required this.type,
    required this.message,
  });

  final PlaybackErrorType type;
  final String message;

  static const PlaybackError none = PlaybackError(
    type: PlaybackErrorType.none,
    message: '',
  );
}
