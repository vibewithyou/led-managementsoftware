enum TransportStatus {
  ready,
  starting,
  playing,
  error,
  fileMissing,
  stopped,
}

extension TransportStatusX on TransportStatus {
  String get value {
    return switch (this) {
      TransportStatus.ready => 'ready',
      TransportStatus.starting => 'starting',
      TransportStatus.playing => 'playing',
      TransportStatus.error => 'error',
      TransportStatus.fileMissing => 'file_missing',
      TransportStatus.stopped => 'stopped',
    };
  }

  static TransportStatus fromValue(String? value) {
    return TransportStatus.values.firstWhere(
      (item) => item.value == value,
      orElse: () => TransportStatus.stopped,
    );
  }
}
