enum ReturnBehavior { toPreviousClip, toLoopStart, holdFrame }

extension ReturnBehaviorX on ReturnBehavior {
  String get label {
    switch (this) {
      case ReturnBehavior.toPreviousClip:
        return 'Zurück zum vorherigen Clip';
      case ReturnBehavior.toLoopStart:
        return 'Zurück zum Schleifenstart';
      case ReturnBehavior.holdFrame:
        return 'Standbild halten';
    }
  }

  static ReturnBehavior fromValue(String raw) {
    return ReturnBehavior.values.firstWhere(
      (behavior) => behavior.name == raw,
      orElse: () => ReturnBehavior.toPreviousClip,
    );
  }
}
