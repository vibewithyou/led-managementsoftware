import 'package:led_managementsoftware_app/domain/entities/entity_utils.dart';
import 'package:led_managementsoftware_app/domain/enums/team_side.dart';

class Player {
  const Player({
    required this.id,
    required this.projectId,
    required this.teamSide,
    required this.name,
    required this.number,
    required this.linkedClipIds,
    required this.enabledForIntro,
    required this.enabledForGoal,
    required this.enabledForInjury,
  });

  final String id;
  final String projectId;
  final TeamSide teamSide;
  final String name;
  final int number;
  final List<String> linkedClipIds;
  final bool enabledForIntro;
  final bool enabledForGoal;
  final bool enabledForInjury;

  Player copyWith({
    String? id,
    String? projectId,
    TeamSide? teamSide,
    String? name,
    int? number,
    List<String>? linkedClipIds,
    bool? enabledForIntro,
    bool? enabledForGoal,
    bool? enabledForInjury,
  }) {
    return Player(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      teamSide: teamSide ?? this.teamSide,
      name: name ?? this.name,
      number: number ?? this.number,
      linkedClipIds: linkedClipIds ?? this.linkedClipIds,
      enabledForIntro: enabledForIntro ?? this.enabledForIntro,
      enabledForGoal: enabledForGoal ?? this.enabledForGoal,
      enabledForInjury: enabledForInjury ?? this.enabledForInjury,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'teamSide': teamSide.name,
      'name': name,
      'number': number,
      'linkedClipIds': linkedClipIds,
      'enabledForIntro': enabledForIntro,
      'enabledForGoal': enabledForGoal,
      'enabledForInjury': enabledForInjury,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      teamSide: TeamSideX.fromValue(map['teamSide'] as String),
      name: map['name'] as String,
      number: map['number'] as int,
      linkedClipIds: ((map['linkedClipIds'] as List<dynamic>?) ?? const []).map((entry) => entry.toString()).toList(),
      enabledForIntro: map['enabledForIntro'] as bool,
      enabledForGoal: map['enabledForGoal'] as bool,
      enabledForInjury: map['enabledForInjury'] as bool,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Player &&
        other.id == id &&
        other.projectId == projectId &&
        other.teamSide == teamSide &&
        other.name == name &&
        other.number == number &&
        listEqualsByValue(other.linkedClipIds, linkedClipIds) &&
        other.enabledForIntro == enabledForIntro &&
        other.enabledForGoal == enabledForGoal &&
        other.enabledForInjury == enabledForInjury;
  }

  @override
  int get hashCode => Object.hash(
        id,
        projectId,
        teamSide,
        name,
        number,
        listHash(linkedClipIds),
        enabledForIntro,
        enabledForGoal,
        enabledForInjury,
      );
}
