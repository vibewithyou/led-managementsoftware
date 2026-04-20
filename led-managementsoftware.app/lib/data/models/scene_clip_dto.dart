import 'package:led_managementsoftware_app/domain/entities/scene_clip.dart';
import 'package:led_managementsoftware_app/domain/enums/interruption_policy.dart';
import 'package:led_managementsoftware_app/domain/enums/return_behavior.dart';

class SceneClipDto {
  const SceneClipDto({
    required this.id,
    required this.sceneId,
    required this.mediaItemId,
    required this.orderIndex,
    required this.isProtected,
    required this.isOverridable,
    required this.priority,
    required this.playOnce,
    required this.repeatable,
    this.rotationGroup,
    required this.interruptionPolicy,
    required this.returnBehavior,
  });

  final String id;
  final String sceneId;
  final String mediaItemId;
  final int orderIndex;
  final bool isProtected;
  final bool isOverridable;
  final int priority;
  final bool playOnce;
  final bool repeatable;
  final String? rotationGroup;
  final String interruptionPolicy;
  final String returnBehavior;

  factory SceneClipDto.fromEntity(SceneClip entity) {
    return SceneClipDto(
      id: entity.id,
      sceneId: entity.sceneId,
      mediaItemId: entity.mediaItemId,
      orderIndex: entity.orderIndex,
      isProtected: entity.isProtected,
      isOverridable: entity.isOverridable,
      priority: entity.priority,
      playOnce: entity.playOnce,
      repeatable: entity.repeatable,
      rotationGroup: entity.rotationGroup,
      interruptionPolicy: entity.interruptionPolicy.name,
      returnBehavior: entity.returnBehavior.name,
    );
  }

  SceneClip toEntity() {
    return SceneClip(
      id: id,
      sceneId: sceneId,
      mediaItemId: mediaItemId,
      orderIndex: orderIndex,
      isProtected: isProtected,
      isOverridable: isOverridable,
      priority: priority,
      playOnce: playOnce,
      repeatable: repeatable,
      rotationGroup: rotationGroup,
      interruptionPolicy: InterruptionPolicyX.fromValue(interruptionPolicy),
      returnBehavior: ReturnBehaviorX.fromValue(returnBehavior),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sceneId': sceneId,
      'mediaItemId': mediaItemId,
      'orderIndex': orderIndex,
      'isProtected': isProtected,
      'isOverridable': isOverridable,
      'priority': priority,
      'playOnce': playOnce,
      'repeatable': repeatable,
      'rotationGroup': rotationGroup,
      'interruptionPolicy': interruptionPolicy,
      'returnBehavior': returnBehavior,
    };
  }

  factory SceneClipDto.fromMap(Map<String, dynamic> map) {
    return SceneClipDto(
      id: map['id'] as String,
      sceneId: map['sceneId'] as String,
      mediaItemId: map['mediaItemId'] as String,
      orderIndex: map['orderIndex'] as int,
      isProtected: map['isProtected'] as bool,
      isOverridable: map['isOverridable'] as bool,
      priority: map['priority'] as int,
      playOnce: map['playOnce'] as bool,
      repeatable: map['repeatable'] as bool,
      rotationGroup: map['rotationGroup'] as String?,
      interruptionPolicy: map['interruptionPolicy'] as String,
      returnBehavior: map['returnBehavior'] as String,
    );
  }
}
