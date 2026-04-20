import 'package:led_management_software/domain/entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getAllProjects();

  Future<Project?> getProjectById(String id);

  Future<Project?> getActiveProject();

  Future<void> setActiveProject(String id);

  Future<void> saveProject(Project project);

  Future<void> deleteProject(String id);
}
