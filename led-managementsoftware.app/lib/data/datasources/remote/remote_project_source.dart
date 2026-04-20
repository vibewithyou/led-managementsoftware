import 'package:led_managementsoftware_app/data/models/project_dto.dart';

abstract class RemoteProjectSource {
  Future<List<ProjectDto>> fetchProjects();
  Future<ProjectDto> upsertProject(ProjectDto project);
}
