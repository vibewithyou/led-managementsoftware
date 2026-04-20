import 'package:led_managementsoftware_app/domain/enums/project_status.dart';

class Project {
  const Project({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.status,
    required this.homeTeam,
    required this.awayTeam,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String name;
  final DateTime date;
  final String location;
  final ProjectStatus status;
  final String homeTeam;
  final String awayTeam;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  Project copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? location,
    ProjectStatus? status,
    String? homeTeam,
    String? awayTeam,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      location: location ?? this.location,
      status: status ?? this.status,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'status': status.name,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'archivedAt': archivedAt?.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      date: DateTime.parse(map['date'] as String),
      location: map['location'] as String,
      status: ProjectStatusX.fromValue(map['status'] as String),
      homeTeam: map['homeTeam'] as String,
      awayTeam: map['awayTeam'] as String,
      notes: map['notes'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      archivedAt: map['archivedAt'] == null ? null : DateTime.parse(map['archivedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Project &&
        other.id == id &&
        other.name == name &&
        other.date == date &&
        other.location == location &&
        other.status == status &&
        other.homeTeam == homeTeam &&
        other.awayTeam == awayTeam &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.archivedAt == archivedAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, name, date, location, status, homeTeam, awayTeam, notes, createdAt, updatedAt, archivedAt);
}
