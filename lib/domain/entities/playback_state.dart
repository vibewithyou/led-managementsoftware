import 'package:led_management_software/domain/entities/cue.dart';
import 'package:led_management_software/domain/enums/live_action_type.dart';
import 'package:led_management_software/domain/enums/playback_status.dart';
import 'package:led_management_software/domain/enums/transport_status.dart';

class PlaybackState {
  const PlaybackState({
    required this.id,
    required this.projectId,
    required this.status,
    required this.currentCue,
    required this.currentMediaPositionMs,
    required this.remainingMs,
    required this.startedAt,
    required this.lastAction,
    required this.lastError,
    required this.transportStatus,
    required this.transportMessage,
    required this.isLocked,
    required this.isBlackScreen,
  });

  factory PlaybackState.initial({required String projectId}) {
    return PlaybackState(
      id: projectId,
      projectId: projectId,
      status: PlaybackStatus.idle,
      currentCue: null,
      currentMediaPositionMs: 0,
      remainingMs: 0,
      startedAt: null,
      lastAction: null,
      lastError: null,
      transportStatus: TransportStatus.stopped,
      transportMessage: 'VLC gestoppt',
      isLocked: false,
      isBlackScreen: false,
    );
  }

  factory PlaybackState.fromJson(Map<String, dynamic> json) {
    final cueJson = json['currentCue'];
    return PlaybackState(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      status: PlaybackStatusX.fromValue(json['status'] as String?),
      currentCue: cueJson is Map<String, dynamic>
          ? Cue.fromJson(cueJson)
          : cueJson is Map
              ? Cue.fromJson(cueJson.map((key, value) => MapEntry(key.toString(), value)))
              : null,
      currentMediaPositionMs: json['currentMediaPositionMs'] as int? ?? 0,
      remainingMs: json['remainingMs'] as int? ?? 0,
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? ''),
      lastAction: (json['lastAction'] as String?) == null
          ? null
          : LiveActionTypeX.fromValue(json['lastAction'] as String?),
      lastError: json['lastError'] as String?,
      transportStatus: TransportStatusX.fromValue(json['transportStatus'] as String?),
      transportMessage: json['transportMessage'] as String? ?? 'VLC gestoppt',
      isLocked: json['isLocked'] as bool? ?? false,
      isBlackScreen: json['isBlackScreen'] as bool? ?? false,
    );
  }

  final String id;
  final String projectId;
  final PlaybackStatus status;
  final Cue? currentCue;
  final int currentMediaPositionMs;
  final int remainingMs;
  final DateTime? startedAt;
  final LiveActionType? lastAction;
  final String? lastError;
  final TransportStatus transportStatus;
  final String transportMessage;
  final bool isLocked;
  final bool isBlackScreen;

  PlaybackState copyWith({
    String? id,
    String? projectId,
    PlaybackStatus? status,
    Object? currentCue = _unset,
    int? currentMediaPositionMs,
    int? remainingMs,
    Object? startedAt = _unset,
    Object? lastAction = _unset,
    Object? lastError = _unset,
    TransportStatus? transportStatus,
    String? transportMessage,
    bool? isLocked,
    bool? isBlackScreen,
  }) {
    return PlaybackState(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      status: status ?? this.status,
      currentCue: currentCue == _unset ? this.currentCue : currentCue as Cue?,
      currentMediaPositionMs: currentMediaPositionMs ?? this.currentMediaPositionMs,
      remainingMs: remainingMs ?? this.remainingMs,
      startedAt: startedAt == _unset ? this.startedAt : startedAt as DateTime?,
      lastAction: lastAction == _unset ? this.lastAction : lastAction as LiveActionType?,
      lastError: lastError == _unset ? this.lastError : lastError as String?,
      transportStatus: transportStatus ?? this.transportStatus,
      transportMessage: transportMessage ?? this.transportMessage,
      isLocked: isLocked ?? this.isLocked,
      isBlackScreen: isBlackScreen ?? this.isBlackScreen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'status': status.value,
      'currentCue': currentCue?.toJson(),
      'currentMediaPositionMs': currentMediaPositionMs,
      'remainingMs': remainingMs,
      'startedAt': startedAt?.toIso8601String(),
      'lastAction': lastAction?.value,
      'lastError': lastError,
      'transportStatus': transportStatus.value,
      'transportMessage': transportMessage,
      'isLocked': isLocked,
      'isBlackScreen': isBlackScreen,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PlaybackState &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            projectId == other.projectId &&
            status == other.status &&
            currentCue == other.currentCue &&
            currentMediaPositionMs == other.currentMediaPositionMs &&
            remainingMs == other.remainingMs &&
            startedAt == other.startedAt &&
            lastAction == other.lastAction &&
            lastError == other.lastError &&
            transportStatus == other.transportStatus &&
            transportMessage == other.transportMessage &&
            isLocked == other.isLocked &&
            isBlackScreen == other.isBlackScreen;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      projectId,
      status,
      currentCue,
      currentMediaPositionMs,
      remainingMs,
      startedAt,
      lastAction,
      lastError,
      transportStatus,
      transportMessage,
      isLocked,
      isBlackScreen,
    );
  }
}

const _unset = Object();
