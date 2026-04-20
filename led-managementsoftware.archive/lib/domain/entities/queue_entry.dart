import 'package:led_management_software/domain/entities/cue.dart';

class QueueEntry {
  const QueueEntry({
    required this.id,
    required this.projectId,
    required this.cue,
    required this.enqueuedAt,
    required this.reason,
    required this.priority,
  });

  factory QueueEntry.empty() {
    return QueueEntry(
      id: '',
      projectId: '',
      cue: Cue.empty(),
      enqueuedAt: DateTime.now(),
      reason: '',
      priority: 0,
    );
  }

  factory QueueEntry.fromJson(Map<String, dynamic> json) {
    final cueJson = json['cue'];
    return QueueEntry(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      cue: cueJson is Map<String, dynamic>
          ? Cue.fromJson(cueJson)
          : cueJson is Map
              ? Cue.fromJson(cueJson.map((key, value) => MapEntry(key.toString(), value)))
              : Cue.empty(),
      enqueuedAt: DateTime.tryParse(json['enqueuedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      reason: json['reason'] as String? ?? '',
      priority: json['priority'] as int? ?? 0,
    );
  }

  final String id;
  final String projectId;
  final Cue cue;
  final DateTime enqueuedAt;
  final String reason;
  final int priority;

  QueueEntry copyWith({
    String? id,
    String? projectId,
    Cue? cue,
    DateTime? enqueuedAt,
    String? reason,
    int? priority,
  }) {
    return QueueEntry(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      cue: cue ?? this.cue,
      enqueuedAt: enqueuedAt ?? this.enqueuedAt,
      reason: reason ?? this.reason,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'cue': cue.toJson(),
      'enqueuedAt': enqueuedAt.toIso8601String(),
      'reason': reason,
      'priority': priority,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QueueEntry &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            projectId == other.projectId &&
            cue == other.cue &&
            enqueuedAt == other.enqueuedAt &&
            reason == other.reason &&
            priority == other.priority;
  }

  @override
  int get hashCode {
    return Object.hash(id, projectId, cue, enqueuedAt, reason, priority);
  }
}
