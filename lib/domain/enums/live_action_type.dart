enum LiveActionType {
  triggerCue,
  stopCue,
  pauseCue,
  resumeCue,
  blackScreenOn,
  blackScreenOff,
  lockPlayback,
  unlockPlayback,
  queueAdd,
  queueRemove,
  queueClear,
  switchFallback,
}

extension LiveActionTypeX on LiveActionType {
  String get value => name;

  static LiveActionType fromValue(String? value) {
    return LiveActionType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => LiveActionType.triggerCue,
    );
  }
}
