enum DeviceType { mainPc, tablet, backupLaptop }

extension DeviceTypeX on DeviceType {
  String get label {
    switch (this) {
      case DeviceType.mainPc:
        return 'Haupt-PC';
      case DeviceType.tablet:
        return 'Tablet';
      case DeviceType.backupLaptop:
        return 'Backup-Laptop';
    }
  }

  static DeviceType fromValue(String raw) {
    return DeviceType.values.firstWhere(
      (type) => type.name == raw,
      orElse: () => DeviceType.mainPc,
    );
  }
}
