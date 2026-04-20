enum PlaybackStatus {
  idle,
  playing,
  locked,
  queued,
  black,
}

extension PlaybackStatusX on PlaybackStatus {
  String get value => name;

  static PlaybackStatus fromValue(String? value) {
    return PlaybackStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => PlaybackStatus.idle,
    );
  }
}
