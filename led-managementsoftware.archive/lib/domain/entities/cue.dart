import 'package:led_management_software/domain/enums/cue_trigger_mode.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/queue_behavior.dart';

class Cue {
  const Cue({
    required this.id,
    required this.mediaAssetId,
    required this.title,
    required this.cueType,
    required this.isLocked,
    required this.canInterrupt,
    required this.mustPlayToEnd,
    required this.autoReturnToFallback,
    required this.queueIfBlocked,
    required this.queueBehavior,
    required this.triggerMode,
    required this.hotkey,
    required this.isFavorite,
    required this.notes,
  });

  factory Cue.empty() {
    return const Cue(
      id: '',
      mediaAssetId: '',
      title: '',
      cueType: CueType.oneShot,
      isLocked: false,
      canInterrupt: true,
      mustPlayToEnd: false,
      autoReturnToFallback: false,
      queueIfBlocked: true,
      queueBehavior: QueueBehavior.enqueue,
      triggerMode: CueTriggerMode.manual,
      hotkey: null,
      isFavorite: false,
      notes: null,
    );
  }

  factory Cue.fromJson(Map<String, dynamic> json) {
    return Cue(
      id: json['id'] as String? ?? '',
      mediaAssetId: json['mediaAssetId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      cueType: CueTypeX.fromValue(json['cueType'] as String?),
      isLocked: json['isLocked'] as bool? ?? false,
      canInterrupt: json['canInterrupt'] as bool? ?? true,
      mustPlayToEnd: json['mustPlayToEnd'] as bool? ?? false,
      autoReturnToFallback: json['autoReturnToFallback'] as bool? ?? false,
      queueIfBlocked: json['queueIfBlocked'] as bool? ?? true,
      queueBehavior: QueueBehaviorX.fromValue(json['queueBehavior'] as String?),
      triggerMode: CueTriggerModeX.fromValue(json['triggerMode'] as String?),
      hotkey: json['hotkey'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  final String id;
  final String mediaAssetId;
  final String title;
  final CueType cueType;
  final bool isLocked;
  final bool canInterrupt;
  final bool mustPlayToEnd;
  final bool autoReturnToFallback;
  final bool queueIfBlocked;
  final QueueBehavior queueBehavior;
  final CueTriggerMode triggerMode;
  final String? hotkey;
  final bool isFavorite;
  final String? notes;

  Cue copyWith({
    String? id,
    String? mediaAssetId,
    String? title,
    CueType? cueType,
    bool? isLocked,
    bool? canInterrupt,
    bool? mustPlayToEnd,
    bool? autoReturnToFallback,
    bool? queueIfBlocked,
    QueueBehavior? queueBehavior,
    CueTriggerMode? triggerMode,
    Object? hotkey = _unset,
    bool? isFavorite,
    Object? notes = _unset,
  }) {
    return Cue(
      id: id ?? this.id,
      mediaAssetId: mediaAssetId ?? this.mediaAssetId,
      title: title ?? this.title,
      cueType: cueType ?? this.cueType,
      isLocked: isLocked ?? this.isLocked,
      canInterrupt: canInterrupt ?? this.canInterrupt,
      mustPlayToEnd: mustPlayToEnd ?? this.mustPlayToEnd,
      autoReturnToFallback: autoReturnToFallback ?? this.autoReturnToFallback,
      queueIfBlocked: queueIfBlocked ?? this.queueIfBlocked,
      queueBehavior: queueBehavior ?? this.queueBehavior,
      triggerMode: triggerMode ?? this.triggerMode,
      hotkey: hotkey == _unset ? this.hotkey : hotkey as String?,
      isFavorite: isFavorite ?? this.isFavorite,
      notes: notes == _unset ? this.notes : notes as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mediaAssetId': mediaAssetId,
      'title': title,
      'cueType': cueType.value,
      'isLocked': isLocked,
      'canInterrupt': canInterrupt,
      'mustPlayToEnd': mustPlayToEnd,
      'autoReturnToFallback': autoReturnToFallback,
      'queueIfBlocked': queueIfBlocked,
      'queueBehavior': queueBehavior.value,
      'triggerMode': triggerMode.value,
      'hotkey': hotkey,
      'isFavorite': isFavorite,
      'notes': notes,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Cue &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            mediaAssetId == other.mediaAssetId &&
            title == other.title &&
            cueType == other.cueType &&
            isLocked == other.isLocked &&
            canInterrupt == other.canInterrupt &&
            mustPlayToEnd == other.mustPlayToEnd &&
            autoReturnToFallback == other.autoReturnToFallback &&
            queueIfBlocked == other.queueIfBlocked &&
            queueBehavior == other.queueBehavior &&
            triggerMode == other.triggerMode &&
            hotkey == other.hotkey &&
            isFavorite == other.isFavorite &&
            notes == other.notes;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      mediaAssetId,
      title,
      cueType,
      isLocked,
      canInterrupt,
      mustPlayToEnd,
      autoReturnToFallback,
      queueIfBlocked,
      queueBehavior,
      triggerMode,
      hotkey,
      isFavorite,
      notes,
    );
  }
}

const _unset = Object();
