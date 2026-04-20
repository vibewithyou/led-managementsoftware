import 'package:led_managementsoftware_app/domain/enums/device_type.dart';

class DeviceProfile {
  const DeviceProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.isOnline,
    required this.lastSyncAt,
  });

  final String id;
  final String name;
  final DeviceType type;
  final bool isOnline;
  final DateTime lastSyncAt;

  DeviceProfile copyWith({
    String? id,
    String? name,
    DeviceType? type,
    bool? isOnline,
    DateTime? lastSyncAt,
  }) {
    return DeviceProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isOnline: isOnline ?? this.isOnline,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'isOnline': isOnline,
      'lastSyncAt': lastSyncAt.toIso8601String(),
    };
  }

  factory DeviceProfile.fromMap(Map<String, dynamic> map) {
    return DeviceProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      type: DeviceTypeX.fromValue(map['type'] as String),
      isOnline: map['isOnline'] as bool,
      lastSyncAt: DateTime.parse(map['lastSyncAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceProfile &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.isOnline == isOnline &&
        other.lastSyncAt == lastSyncAt;
  }

  @override
  int get hashCode => Object.hash(id, name, type, isOnline, lastSyncAt);
}
