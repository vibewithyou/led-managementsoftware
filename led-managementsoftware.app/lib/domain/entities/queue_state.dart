class QueueState {
  const QueueState({
    required this.id,
    required this.projectId,
    required this.activeSceneId,
    required this.currentClipIndex,
    required this.nextClipIndex,
    required this.isPaused,
    this.interruptedBySceneId,
    this.returnClipIndex,
    this.returnTimestamp,
  });

  final String id;
  final String projectId;
  final String activeSceneId;
  final int currentClipIndex;
  final int nextClipIndex;
  final bool isPaused;
  final String? interruptedBySceneId;
  final int? returnClipIndex;
  final DateTime? returnTimestamp;

  QueueState copyWith({
    String? id,
    String? projectId,
    String? activeSceneId,
    int? currentClipIndex,
    int? nextClipIndex,
    bool? isPaused,
    String? interruptedBySceneId,
    int? returnClipIndex,
    DateTime? returnTimestamp,
  }) {
    return QueueState(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      activeSceneId: activeSceneId ?? this.activeSceneId,
      currentClipIndex: currentClipIndex ?? this.currentClipIndex,
      nextClipIndex: nextClipIndex ?? this.nextClipIndex,
      isPaused: isPaused ?? this.isPaused,
      interruptedBySceneId: interruptedBySceneId ?? this.interruptedBySceneId,
      returnClipIndex: returnClipIndex ?? this.returnClipIndex,
      returnTimestamp: returnTimestamp ?? this.returnTimestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'activeSceneId': activeSceneId,
      'currentClipIndex': currentClipIndex,
      'nextClipIndex': nextClipIndex,
      'isPaused': isPaused,
      'interruptedBySceneId': interruptedBySceneId,
      'returnClipIndex': returnClipIndex,
      'returnTimestamp': returnTimestamp?.toIso8601String(),
    };
  }

  factory QueueState.fromMap(Map<String, dynamic> map) {
    return QueueState(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      activeSceneId: map['activeSceneId'] as String,
      currentClipIndex: map['currentClipIndex'] as int,
      nextClipIndex: map['nextClipIndex'] as int,
      isPaused: map['isPaused'] as bool,
      interruptedBySceneId: map['interruptedBySceneId'] as String?,
      returnClipIndex: map['returnClipIndex'] as int?,
      returnTimestamp: map['returnTimestamp'] == null ? null : DateTime.parse(map['returnTimestamp'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is QueueState &&
        other.id == id &&
        other.projectId == projectId &&
        other.activeSceneId == activeSceneId &&
        other.currentClipIndex == currentClipIndex &&
        other.nextClipIndex == nextClipIndex &&
        other.isPaused == isPaused &&
        other.interruptedBySceneId == interruptedBySceneId &&
        other.returnClipIndex == returnClipIndex &&
        other.returnTimestamp == returnTimestamp;
  }

  @override
  int get hashCode => Object.hash(
        id,
        projectId,
        activeSceneId,
        currentClipIndex,
        nextClipIndex,
        isPaused,
        interruptedBySceneId,
        returnClipIndex,
        returnTimestamp,
      );
}
