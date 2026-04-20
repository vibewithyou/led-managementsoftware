import 'package:led_managementsoftware_app/data/models/project_dto.dart';

abstract class LocalProjectSource {
  Future<List<ProjectDto>> readProjects();
  Future<void> writeProjects(List<ProjectDto> projects);
}
