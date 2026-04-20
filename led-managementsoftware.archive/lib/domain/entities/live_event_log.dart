import 'package:led_management_software/domain/enums/live_action_type.dart';

class LiveEventLog {
  const LiveEventLog({
    required this.id,
    required this.projectId,
    required this.cueId,
    required this.actionType,
    required this.timestamp,
    required this.operatorName,
    required this.result,
    required this.errorMessage,
    required this.metadata,
  });

  factory LiveEventLog.empty() {
    return const LiveEventLog(
      id: '',
      projectId: '',
      cueId: null,
      actionType: LiveActionType.triggerCue,
      timestamp: null,
      operatorName: null,
      result: 'success',
      errorMessage: null,
      metadata: null,
    );
  }

  factory LiveEventLog.fromJson(Map<String, dynamic> json) {
    final metadataJson = json['metadata'];
    return LiveEventLog(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      cueId: json['cueId'] as String?,
      actionType: LiveActionTypeX.fromValue(json['actionType'] as String?),
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? ''),
      operatorName: json['operatorName'] as String?,
      result: json['result'] as String? ?? 'success',
      errorMessage: json['errorMessage'] as String?,
      metadata: metadataJson is Map<String, dynamic>
          ? metadataJson
          : metadataJson is Map
              ? metadataJson.map((key, value) => MapEntry(key.toString(), value))
              : null,
    );
  }

  final String id;
  final String projectId;
  final String? cueId;
  final LiveActionType actionType;
  final DateTime? timestamp;
  final String? operatorName;
  final String result;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  LiveEventLog copyWith({
    String? id,
    String? projectId,
    Object? cueId = _unset,
    LiveActionType? actionType,
    Object? timestamp = _unset,
    Object? operatorName = _unset,
    String? result,
    Object? errorMessage = _unset,
    Object? metadata = _unset,
  }) {
    return LiveEventLog(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      cueId: cueId == _unset ? this.cueId : cueId as String?,
      actionType: actionType ?? this.actionType,
      timestamp: timestamp == _unset ? this.timestamp : timestamp as DateTime?,
      operatorName: operatorName == _unset ? this.operatorName : operatorName as String?,
      result: result ?? this.result,
      errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
      metadata: metadata == _unset ? this.metadata : metadata as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'cueId': cueId,
      'actionType': actionType.value,
      'timestamp': timestamp?.toIso8601String(),
      'operatorName': operatorName,
      'result': result,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LiveEventLog &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            projectId == other.projectId &&
            cueId == other.cueId &&
            actionType == other.actionType &&
            timestamp == other.timestamp &&
            operatorName == other.operatorName &&
            result == other.result &&
            errorMessage == other.errorMessage &&
            _mapEquals(metadata, other.metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      projectId,
      cueId,
      actionType,
      timestamp,
      operatorName,
      result,
      errorMessage,
      _mapHash(metadata),
    );
  }
}

bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
  if (identical(a, b)) {
    return true;
  }
  if (a == null || b == null || a.length != b.length) {
    return false;
  }
  for (final entry in a.entries) {
    if (b[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}

int _mapHash(Map<String, dynamic>? map) {
  if (map == null) {
    return 0;
  }
  return Object.hashAll(
    map.entries.map((entry) => Object.hash(entry.key, entry.value)),
  );
}

const _unset = Object();
