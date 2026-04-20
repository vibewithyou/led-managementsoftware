import 'package:led_managementsoftware_app/domain/entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> fetchProjects();
  Future<Project> saveProject(Project project);
}
