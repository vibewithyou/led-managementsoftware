import 'package:led_managementsoftware_app/data/datasources/remote/remote_project_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/supabase_tables.dart';
import 'package:led_managementsoftware_app/data/models/project_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRemoteProjectSource implements RemoteProjectSource {
  SupabaseRemoteProjectSource(this.client);

  final SupabaseClient client;

  @override
  Future<List<ProjectDto>> fetchProjects() async {
    final response = await client.from(SupabaseTables.projects).select().order('updated_at', ascending: false);
    return response
        .map((row) => ProjectDto.fromMap(_fromDbMap(row)))
        .toList(growable: false);
  }

  @override
  Future<ProjectDto> upsertProject(ProjectDto project) async {
    final response = await client.from(SupabaseTables.projects).upsert(_toDbMap(project), onConflict: 'id').select().single();
    return ProjectDto.fromMap(_fromDbMap(response));
  }

  Map<String, dynamic> _toDbMap(ProjectDto dto) {
    return {
      'id': dto.id,
      'name': dto.name,
      'date': dto.date,
      'location': dto.location,
      'status': dto.status,
      'home_team': dto.homeTeam,
      'away_team': dto.awayTeam,
      'notes': dto.notes,
      'created_at': dto.createdAt,
      'updated_at': dto.updatedAt,
      'archived_at': dto.archivedAt,
    };
  }

  Map<String, dynamic> _fromDbMap(Map<String, dynamic> map) {
    return {
      'id': map['id'],
      'name': map['name'],
      'date': map['date'],
      'location': map['location'],
      'status': map['status'],
      'homeTeam': map['home_team'],
      'awayTeam': map['away_team'],
      'notes': map['notes'] ?? '',
      'createdAt': map['created_at'],
      'updatedAt': map['updated_at'],
      'archivedAt': map['archived_at'],
    };
  }
}
