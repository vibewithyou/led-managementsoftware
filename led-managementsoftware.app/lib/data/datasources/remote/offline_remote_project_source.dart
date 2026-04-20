import 'package:led_managementsoftware_app/data/datasources/remote/remote_project_source.dart';
import 'package:led_managementsoftware_app/data/models/project_dto.dart';

class OfflineRemoteProjectSource implements RemoteProjectSource {
  final Map<String, ProjectDto> _store = {};

  @override
  Future<List<ProjectDto>> fetchProjects() async {
    return _store.values.toList(growable: false);
  }

  @override
  Future<ProjectDto> upsertProject(ProjectDto project) async {
    _store[project.id] = project;
    return project;
  }
}