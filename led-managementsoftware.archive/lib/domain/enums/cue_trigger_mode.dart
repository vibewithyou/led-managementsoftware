enum CueTriggerMode {
  manual,
  scheduled,
  remote,
  hotkey,
}

extension CueTriggerModeX on CueTriggerMode {
  String get value => name;

  static CueTriggerMode fromValue(String? value) {
    return CueTriggerMode.values.firstWhere(
      (item) => item.name == value,
      orElse: () => CueTriggerMode.manual,
    );
  }
}
