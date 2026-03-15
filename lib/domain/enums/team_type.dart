enum TeamType {
  home,
  guest,
  neutral,
  unknown,
}

extension TeamTypeX on TeamType {
  String get value => name;

  static TeamType fromValue(String? value) {
    return TeamType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => TeamType.unknown,
    );
  }
}
