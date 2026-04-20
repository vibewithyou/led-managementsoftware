import 'package:led_management_software/domain/enums/team_type.dart';

class LineupEntry {
  const LineupEntry({
    required this.id,
    required this.projectId,
    required this.playerName,
    required this.jerseyNumber,
    required this.position,
    required this.teamType,
    required this.introCueId,
    required this.sortOrder,
    required this.isCaptain,
    required this.isActive,
  });

  factory LineupEntry.empty() {
    return const LineupEntry(
      id: '',
      projectId: '',
      playerName: '',
      jerseyNumber: '',
      position: '',
      teamType: TeamType.home,
      introCueId: null,
      sortOrder: 0,
      isCaptain: false,
      isActive: true,
    );
  }

  factory LineupEntry.fromJson(Map<String, dynamic> json) {
    return LineupEntry(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      playerName: json['playerName'] as String? ?? '',
      jerseyNumber: json['jerseyNumber'] as String? ?? '',
      position: json['position'] as String? ?? '',
      teamType: TeamTypeX.fromValue(json['teamType'] as String?),
      introCueId: json['introCueId'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
      isCaptain: json['isCaptain'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  final String id;
  final String projectId;
  final String playerName;
  final String jerseyNumber;
  final String position;
  final TeamType teamType;
  final String? introCueId;
  final int sortOrder;
  final bool isCaptain;
  final bool isActive;

  LineupEntry copyWith({
    String? id,
    String? projectId,
    String? playerName,
    String? jerseyNumber,
    String? position,
    TeamType? teamType,
    Object? introCueId = _unset,
    int? sortOrder,
    bool? isCaptain,
    bool? isActive,
  }) {
    return LineupEntry(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      playerName: playerName ?? this.playerName,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      position: position ?? this.position,
      teamType: teamType ?? this.teamType,
      introCueId: introCueId == _unset ? this.introCueId : introCueId as String?,
      sortOrder: sortOrder ?? this.sortOrder,
      isCaptain: isCaptain ?? this.isCaptain,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'playerName': playerName,
      'jerseyNumber': jerseyNumber,
      'position': position,
      'teamType': teamType.value,
      'introCueId': introCueId,
      'sortOrder': sortOrder,
      'isCaptain': isCaptain,
      'isActive': isActive,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LineupEntry &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            projectId == other.projectId &&
            playerName == other.playerName &&
            jerseyNumber == other.jerseyNumber &&
            position == other.position &&
            teamType == other.teamType &&
            introCueId == other.introCueId &&
            sortOrder == other.sortOrder &&
            isCaptain == other.isCaptain &&
            isActive == other.isActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      projectId,
      playerName,
      jerseyNumber,
      position,
      teamType,
      introCueId,
      sortOrder,
      isCaptain,
      isActive,
    );
  }
}

const _unset = Object();
