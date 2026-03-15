import 'package:led_management_software/domain/entities/queue_entry.dart';

/// Represents the full runtime queue state of the playback engine.
class QueueState {
  const QueueState({
    required this.projectId,
    required this.entries,
    required this.updatedAt,
  });

  factory QueueState.initial({required String projectId}) {
    return QueueState(
      projectId: projectId,
      entries: const [],
      updatedAt: DateTime.now(),
    );
  }

  final String projectId;
  final List<QueueEntry> entries;
  final DateTime updatedAt;

  bool get hasEntries => entries.isNotEmpty;

  QueueState copyWith({
    String? projectId,
    List<QueueEntry>? entries,
    DateTime? updatedAt,
  }) {
    return QueueState(
      projectId: projectId ?? this.projectId,
      entries: entries ?? this.entries,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'entries': entries.map((entry) => entry.toJson()).toList(growable: false),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory QueueState.fromJson(Map<String, dynamic> json) {
    final entriesJson = (json['entries'] as List<dynamic>? ?? const <dynamic>[]);
    return QueueState(
      projectId: json['projectId'] as String? ?? '',
      entries: entriesJson
          .map((item) => item is Map<String, dynamic>
              ? QueueEntry.fromJson(item)
              : item is Map
                  ? QueueEntry.fromJson(item.map((key, value) => MapEntry(key.toString(), value)))
                  : QueueEntry.empty())
          .toList(growable: false),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QueueState &&
            runtimeType == other.runtimeType &&
            projectId == other.projectId &&
            updatedAt == other.updatedAt &&
            _entriesEqual(entries, other.entries);
  }

  @override
  int get hashCode {
    return Object.hash(projectId, updatedAt, Object.hashAll(entries));
  }
}

bool _entriesEqual(List<QueueEntry> a, List<QueueEntry> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (var index = 0; index < a.length; index++) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}
