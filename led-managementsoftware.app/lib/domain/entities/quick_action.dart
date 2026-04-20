import 'package:led_managementsoftware_app/domain/enums/quick_action_type.dart';
import 'package:led_managementsoftware_app/domain/enums/team_side.dart';

class QuickAction {
  const QuickAction({
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
  final QuickActionType type;
  final TeamSide targetSide;
  final String? linkedSceneId;
  final bool startsImmediately;
  final bool canInterruptProtectedClip;
  final bool requiresConfirmation;
  final bool isEnabled;

  QuickAction copyWith({
    String? id,
    String? name,
    QuickActionType? type,
    TeamSide? targetSide,
    String? linkedSceneId,
    bool? startsImmediately,
    bool? canInterruptProtectedClip,
    bool? requiresConfirmation,
    bool? isEnabled,
  }) {
    return QuickAction(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      targetSide: targetSide ?? this.targetSide,
      linkedSceneId: linkedSceneId ?? this.linkedSceneId,
      startsImmediately: startsImmediately ?? this.startsImmediately,
      canInterruptProtectedClip: canInterruptProtectedClip ?? this.canInterruptProtectedClip,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'targetSide': targetSide.name,
      'linkedSceneId': linkedSceneId,
      'startsImmediately': startsImmediately,
      'canInterruptProtectedClip': canInterruptProtectedClip,
      'requiresConfirmation': requiresConfirmation,
      'isEnabled': isEnabled,
    };
  }

  factory QuickAction.fromMap(Map<String, dynamic> map) {
    return QuickAction(
      id: map['id'] as String,
      name: map['name'] as String,
      type: QuickActionTypeX.fromValue(map['type'] as String),
      targetSide: TeamSideX.fromValue(map['targetSide'] as String),
      linkedSceneId: map['linkedSceneId'] as String?,
      startsImmediately: map['startsImmediately'] as bool,
      canInterruptProtectedClip: map['canInterruptProtectedClip'] as bool,
      requiresConfirmation: map['requiresConfirmation'] as bool,
      isEnabled: map['isEnabled'] as bool,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is QuickAction &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.targetSide == targetSide &&
        other.linkedSceneId == linkedSceneId &&
        other.startsImmediately == startsImmediately &&
        other.canInterruptProtectedClip == canInterruptProtectedClip &&
        other.requiresConfirmation == requiresConfirmation &&
        other.isEnabled == isEnabled;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        type,
        targetSide,
        linkedSceneId,
        startsImmediately,
        canInterruptProtectedClip,
        requiresConfirmation,
        isEnabled,
      );
}
