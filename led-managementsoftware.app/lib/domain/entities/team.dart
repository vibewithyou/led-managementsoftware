import 'package:led_managementsoftware_app/domain/entities/entity_utils.dart';
import 'package:led_managementsoftware_app/domain/entities/player.dart';
import 'package:led_managementsoftware_app/domain/enums/team_side.dart';

class Team {
  const Team({
    required this.id,
    required this.projectId,
    required this.name,
    required this.side,
    this.shortName,
    this.players = const [],
  });

  final String id;
  final String projectId;
  final String name;
  final TeamSide side;
  final String? shortName;
  final List<Player> players;

  Team copyWith({
    String? id,
    String? projectId,
    String? name,
    TeamSide? side,
    String? shortName,
    List<Player>? players,
  }) {
    return Team(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      side: side ?? this.side,
      shortName: shortName ?? this.shortName,
      players: players ?? this.players,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'side': side.name,
      'shortName': shortName,
      'players': players.map((entry) => entry.toMap()).toList(),
    };
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      name: map['name'] as String,
      side: TeamSideX.fromValue(map['side'] as String),
      shortName: map['shortName'] as String?,
      players: ((map['players'] as List<dynamic>?) ?? const [])
          .map((entry) => Player.fromMap(entry as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Team &&
        other.id == id &&
        other.projectId == projectId &&
        other.name == name &&
        other.side == side &&
        other.shortName == shortName &&
        listEqualsByValue(other.players, players);
  }

  @override
  int get hashCode => Object.hash(id, projectId, name, side, shortName, listHash(players));
}
