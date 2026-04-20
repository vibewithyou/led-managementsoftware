enum CueType {
  loop,
  oneShot,
  lockedSponsor,
  event,
  fallback,
}

extension CueTypeX on CueType {
  String get value => name;

  static CueType fromValue(String? value) {
    return CueType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => CueType.oneShot,
    );
  }
}
