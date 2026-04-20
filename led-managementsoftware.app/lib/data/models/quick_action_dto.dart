import 'package:led_managementsoftware_app/domain/entities/quick_action.dart';
import 'package:led_managementsoftware_app/domain/enums/quick_action_type.dart';
import 'package:led_managementsoftware_app/domain/enums/team_side.dart';

class QuickActionDto {
  const QuickActionDto({
    required this.id,
    required this.name,
    required this.type,
    required this.targetSide,
    this.linkedSceneId,
    required this.startsImmediately,
    required this.canInterruptProtectedClip,
    required this.requiresConfirmation,
    required this.isEnabled,
  });

  final String id;
  final String name;
  final String type;
  final String targetSide;
  final String? linkedSceneId;
  final bool startsImmediately;
  final bool canInterruptProtectedClip;
  final bool requiresConfirmation;
  final bool isEnabled;

  factory QuickActionDto.fromEntity(QuickAction entity) {
    return QuickActionDto(
      id: entity.id,
      name: entity.name,
      type: entity.type.name,
      targetSide: entity.targetSide.name,
      linkedSceneId: entity.linkedSceneId,
      startsImmediately: entity.startsImmediately,
      canInterruptProtectedClip: entity.canInterruptProtectedClip,
      requiresConfirmation: entity.requiresConfirmation,
      isEnabled: entity.isEnabled,
    );
  }

  QuickAction toEntity() {
    return QuickAction(
      id: id,
      name: name,
      type: QuickActionTypeX.fromValue(type),
      targetSide: TeamSideX.fromValue(targetSide),
      linkedSceneId: linkedSceneId,
      startsImmediately: startsImmediately,
      canInterruptProtectedClip: canInterruptProtectedClip,
      requiresConfirmation: requiresConfirmation,
      isEnabled: isEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'targetSide': targetSide,
      'linkedSceneId': linkedSceneId,
      'startsImmediately': startsImmediately,
      'canInterruptProtectedClip': canInterruptProtectedClip,
      'requiresConfirmation': requiresConfirmation,
      'isEnabled': isEnabled,
    };
  }

  factory QuickActionDto.fromMap(Map<String, dynamic> map) {
    return QuickActionDto(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      targetSide: map['targetSide'] as String,
      linkedSceneId: map['linkedSceneId'] as String?,
      startsImmediately: map['startsImmediately'] as bool,
      canInterruptProtectedClip: map['canInterruptProtectedClip'] as bool,
      requiresConfirmation: map['requiresConfirmation'] as bool,
      isEnabled: map['isEnabled'] as bool,
    );
  }
}
