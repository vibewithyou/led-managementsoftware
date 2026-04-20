import 'package:led_managementsoftware_app/domain/entities/queue_state.dart';

class QueueStateDto {
  const QueueStateDto({
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
  final String? returnTimestamp;

  factory QueueStateDto.fromEntity(QueueState entity) {
    return QueueStateDto(
      id: entity.id,
      projectId: entity.projectId,
      activeSceneId: entity.activeSceneId,
      currentClipIndex: entity.currentClipIndex,
      nextClipIndex: entity.nextClipIndex,
      isPaused: entity.isPaused,
      interruptedBySceneId: entity.interruptedBySceneId,
      returnClipIndex: entity.returnClipIndex,
      returnTimestamp: entity.returnTimestamp?.toIso8601String(),
    );
  }

  QueueState toEntity() {
    return QueueState(
      id: id,
      projectId: projectId,
      activeSceneId: activeSceneId,
      currentClipIndex: currentClipIndex,
      nextClipIndex: nextClipIndex,
      isPaused: isPaused,
      interruptedBySceneId: interruptedBySceneId,
      returnClipIndex: returnClipIndex,
      returnTimestamp: returnTimestamp == null ? null : DateTime.parse(returnTimestamp!),
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
      'returnTimestamp': returnTimestamp,
    };
  }

  factory QueueStateDto.fromMap(Map<String, dynamic> map) {
    return QueueStateDto(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      activeSceneId: map['activeSceneId'] as String,
      currentClipIndex: map['currentClipIndex'] as int,
      nextClipIndex: map['nextClipIndex'] as int,
      isPaused: map['isPaused'] as bool,
      interruptedBySceneId: map['interruptedBySceneId'] as String?,
      returnClipIndex: map['returnClipIndex'] as int?,
      returnTimestamp: map['returnTimestamp'] as String?,
    );
  }
}
