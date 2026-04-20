import 'package:led_managementsoftware_app/domain/enums/interruption_policy.dart';
import 'package:led_managementsoftware_app/domain/enums/return_behavior.dart';

class SceneClip {
  const SceneClip({
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
  final InterruptionPolicy interruptionPolicy;
  final ReturnBehavior returnBehavior;

  SceneClip copyWith({
    String? id,
    String? sceneId,
    String? mediaItemId,
    int? orderIndex,
    bool? isProtected,
    bool? isOverridable,
    int? priority,
    bool? playOnce,
    bool? repeatable,
    String? rotationGroup,
    InterruptionPolicy? interruptionPolicy,
    ReturnBehavior? returnBehavior,
  }) {
    return SceneClip(
      id: id ?? this.id,
      sceneId: sceneId ?? this.sceneId,
      mediaItemId: mediaItemId ?? this.mediaItemId,
      orderIndex: orderIndex ?? this.orderIndex,
      isProtected: isProtected ?? this.isProtected,
      isOverridable: isOverridable ?? this.isOverridable,
      priority: priority ?? this.priority,
      playOnce: playOnce ?? this.playOnce,
      repeatable: repeatable ?? this.repeatable,
      rotationGroup: rotationGroup ?? this.rotationGroup,
      interruptionPolicy: interruptionPolicy ?? this.interruptionPolicy,
      returnBehavior: returnBehavior ?? this.returnBehavior,
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
      'interruptionPolicy': interruptionPolicy.name,
      'returnBehavior': returnBehavior.name,
    };
  }

  factory SceneClip.fromMap(Map<String, dynamic> map) {
    return SceneClip(
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
      interruptionPolicy: InterruptionPolicyX.fromValue(map['interruptionPolicy'] as String),
      returnBehavior: ReturnBehaviorX.fromValue(map['returnBehavior'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SceneClip &&
        other.id == id &&
        other.sceneId == sceneId &&
        other.mediaItemId == mediaItemId &&
        other.orderIndex == orderIndex &&
        other.isProtected == isProtected &&
        other.isOverridable == isOverridable &&
        other.priority == priority &&
        other.playOnce == playOnce &&
        other.repeatable == repeatable &&
        other.rotationGroup == rotationGroup &&
        other.interruptionPolicy == interruptionPolicy &&
        other.returnBehavior == returnBehavior;
  }

  @override
  int get hashCode => Object.hash(
        id,
        sceneId,
        mediaItemId,
        orderIndex,
        isProtected,
        isOverridable,
        priority,
        playOnce,
        repeatable,
        rotationGroup,
        interruptionPolicy,
        returnBehavior,
      );
}
