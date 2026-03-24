import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/live_action_type.dart';
import 'package:led_management_software/domain/enums/queue_behavior.dart';

enum LiveActionGroup { game, advertising, safety, intro }

enum LiveActionColorSemantic { primary, success, warning, danger, neutral }

class LiveActionConfig {
  const LiveActionConfig({
    required this.id,
    required this.label,
    required this.actionType,
    required this.group,
    required this.color,
    required this.hotkey,
    required this.enabled,
    required this.priority,
    required this.queueBehavior,
    required this.canInterrupt,
    required this.cueType,
    required this.mediaAssetId,
  });

  final String id;
  final String label;
  final LiveActionType actionType;
  final LiveActionGroup group;
  final LiveActionColorSemantic color;
  final String? hotkey;
  final bool enabled;
  final int priority;
  final QueueBehavior queueBehavior;
  final bool canInterrupt;
  final CueType cueType;
  final String? mediaAssetId;

  LiveActionConfig copyWith({
    String? id,
    String? label,
    LiveActionType? actionType,
    LiveActionGroup? group,
    LiveActionColorSemantic? color,
    Object? hotkey = _unset,
    bool? enabled,
    int? priority,
    QueueBehavior? queueBehavior,
    bool? canInterrupt,
    CueType? cueType,
    Object? mediaAssetId = _unset,
  }) {
    return LiveActionConfig(
      id: id ?? this.id,
      label: label ?? this.label,
      actionType: actionType ?? this.actionType,
      group: group ?? this.group,
      color: color ?? this.color,
      hotkey: hotkey == _unset ? this.hotkey : hotkey as String?,
      enabled: enabled ?? this.enabled,
      priority: priority ?? this.priority,
      queueBehavior: queueBehavior ?? this.queueBehavior,
      canInterrupt: canInterrupt ?? this.canInterrupt,
      cueType: cueType ?? this.cueType,
      mediaAssetId: mediaAssetId == _unset ? this.mediaAssetId : mediaAssetId as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'actionType': actionType.value,
      'group': group.name,
      'color': color.name,
      'hotkey': hotkey,
      'enabled': enabled,
      'priority': priority,
      'queueBehavior': queueBehavior.value,
      'canInterrupt': canInterrupt,
      'cueType': cueType.value,
      'mediaAssetId': mediaAssetId,
    };
  }

  factory LiveActionConfig.fromJson(Map<String, dynamic> json) {
    return LiveActionConfig(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      actionType: LiveActionTypeX.fromValue(json['actionType'] as String?),
      group: LiveActionGroup.values.firstWhere(
        (item) => item.name == json['group'],
        orElse: () => LiveActionGroup.game,
      ),
      color: LiveActionColorSemantic.values.firstWhere(
        (item) => item.name == json['color'],
        orElse: () => LiveActionColorSemantic.primary,
      ),
      hotkey: json['hotkey'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      priority: json['priority'] as int? ?? 100,
      queueBehavior: QueueBehaviorX.fromValue(json['queueBehavior'] as String?),
      canInterrupt: json['canInterrupt'] as bool? ?? true,
      cueType: CueTypeX.fromValue(json['cueType'] as String?),
      mediaAssetId: json['mediaAssetId'] as String?,
    );
  }
}

const _unset = Object();
