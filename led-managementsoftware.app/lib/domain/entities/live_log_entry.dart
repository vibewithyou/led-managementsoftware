class LiveLogEntry {
  const LiveLogEntry({
    required this.id,
    required this.projectId,
    required this.timestamp,
    required this.deviceId,
    required this.actorName,
    required this.action,
    required this.details,
    required this.success,
  });

  final String id;
  final String projectId;
  final DateTime timestamp;
  final String deviceId;
  final String actorName;
  final String action;
  final String details;
  final bool success;

  LiveLogEntry copyWith({
    String? id,
    String? projectId,
    DateTime? timestamp,
    String? deviceId,
    String? actorName,
    String? action,
    String? details,
    bool? success,
  }) {
    return LiveLogEntry(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      timestamp: timestamp ?? this.timestamp,
      deviceId: deviceId ?? this.deviceId,
      actorName: actorName ?? this.actorName,
      action: action ?? this.action,
      details: details ?? this.details,
      success: success ?? this.success,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'timestamp': timestamp.toIso8601String(),
      'deviceId': deviceId,
      'actorName': actorName,
      'action': action,
      'details': details,
      'success': success,
    };
  }

  factory LiveLogEntry.fromMap(Map<String, dynamic> map) {
    return LiveLogEntry(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      deviceId: map['deviceId'] as String,
      actorName: map['actorName'] as String,
      action: map['action'] as String,
      details: map['details'] as String,
      success: map['success'] as bool,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LiveLogEntry &&
        other.id == id &&
        other.projectId == projectId &&
        other.timestamp == timestamp &&
        other.deviceId == deviceId &&
        other.actorName == actorName &&
        other.action == action &&
        other.details == details &&
        other.success == success;
  }

  @override
  int get hashCode => Object.hash(id, projectId, timestamp, deviceId, actorName, action, details, success);
}
