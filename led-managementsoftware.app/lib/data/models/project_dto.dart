import 'package:led_managementsoftware_app/domain/entities/project.dart';
import 'package:led_managementsoftware_app/domain/enums/project_status.dart';

class ProjectDto {
  const ProjectDto({
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
  final String date;
  final String location;
  final String status;
  final String homeTeam;
  final String awayTeam;
  final String notes;
  final String createdAt;
  final String updatedAt;
  final String? archivedAt;

  factory ProjectDto.fromEntity(Project entity) {
    return ProjectDto(
      id: entity.id,
      name: entity.name,
      date: entity.date.toIso8601String(),
      location: entity.location,
      status: entity.status.name,
      homeTeam: entity.homeTeam,
      awayTeam: entity.awayTeam,
      notes: entity.notes,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      archivedAt: entity.archivedAt?.toIso8601String(),
    );
  }

  Project toEntity() {
    return Project(
      id: id,
      name: name,
      date: DateTime.parse(date),
      location: location,
      status: ProjectStatusX.fromValue(status),
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      notes: notes,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      archivedAt: archivedAt == null ? null : DateTime.parse(archivedAt!),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'location': location,
      'status': status,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'archivedAt': archivedAt,
    };
  }

  factory ProjectDto.fromMap(Map<String, dynamic> map) {
    return ProjectDto(
      id: map['id'] as String,
      name: map['name'] as String,
      date: map['date'] as String,
      location: map['location'] as String,
      status: map['status'] as String,
      homeTeam: map['homeTeam'] as String,
      awayTeam: map['awayTeam'] as String,
      notes: map['notes'] as String,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
      archivedAt: map['archivedAt'] as String?,
    );
  }
}
