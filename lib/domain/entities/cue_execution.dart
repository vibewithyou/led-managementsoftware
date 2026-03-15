import 'package:led_management_software/domain/entities/cue.dart';

/// Captures runtime execution metadata for the currently playing cue.
class CueExecution {
  const CueExecution({
    required this.id,
    required this.projectId,
    required this.cue,
    required this.startedAt,
    required this.expectedDurationMs,
    required this.expectedEndAt,
    required this.triggerSource,
  });

  final String id;
  final String projectId;
  final Cue cue;
  final DateTime startedAt;
  final int expectedDurationMs;
  final DateTime expectedEndAt;
  final String triggerSource;

  CueExecution copyWith({
    String? id,
    String? projectId,
    Cue? cue,
    DateTime? startedAt,
    int? expectedDurationMs,
    DateTime? expectedEndAt,
    String? triggerSource,
  }) {
    return CueExecution(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      cue: cue ?? this.cue,
      startedAt: startedAt ?? this.startedAt,
      expectedDurationMs: expectedDurationMs ?? this.expectedDurationMs,
      expectedEndAt: expectedEndAt ?? this.expectedEndAt,
      triggerSource: triggerSource ?? this.triggerSource,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'cue': cue.toJson(),
      'startedAt': startedAt.toIso8601String(),
      'expectedDurationMs': expectedDurationMs,
      'expectedEndAt': expectedEndAt.toIso8601String(),
      'triggerSource': triggerSource,
    };
  }

  factory CueExecution.fromJson(Map<String, dynamic> json) {
    final cueJson = json['cue'];
    return CueExecution(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      cue: cueJson is Map<String, dynamic>
          ? Cue.fromJson(cueJson)
          : cueJson is Map
              ? Cue.fromJson(cueJson.map((key, value) => MapEntry(key.toString(), value)))
              : Cue.empty(),
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      expectedDurationMs: json['expectedDurationMs'] as int? ?? 0,
      expectedEndAt: DateTime.tryParse(json['expectedEndAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      triggerSource: json['triggerSource'] as String? ?? 'manual',
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CueExecution &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            projectId == other.projectId &&
            cue == other.cue &&
            startedAt == other.startedAt &&
            expectedDurationMs == other.expectedDurationMs &&
            expectedEndAt == other.expectedEndAt &&
            triggerSource == other.triggerSource;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      projectId,
      cue,
      startedAt,
      expectedDurationMs,
      expectedEndAt,
      triggerSource,
    );
  }
}
