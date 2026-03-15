import 'package:led_management_software/data/repositories/project_repository_impl.dart';
import 'package:led_management_software/domain/entities/project.dart';
import 'package:led_management_software/domain/repositories/project_repository.dart';
import 'package:led_management_software/features/projects/model/project_item_model.dart';

class ProjectsService {
  ProjectsService({ProjectRepository? repository}) : _repository = repository ?? ProjectRepositoryImpl();

  final ProjectRepository _repository;

  Future<List<ProjectItemModel>> loadProjects() async {
    final projects = await _repository.getAllProjects();
    return projects
        .map(
          (project) => ProjectItemModel(
            id: project.id,
            name: project.name,
            opponent: project.opponent,
            venue: project.venue,
            date: project.date,
            clipCount: project.clipCount,
            isActive: project.isActive,
            fallbackCueId: project.fallbackCueId,
            sponsorLoopCueId: project.sponsorLoopCueId,
          ),
        )
        .toList(growable: false);
  }

  Future<void> createProject({
    required String name,
    required String opponent,
    required String venue,
    required DateTime date,
    String? sponsorLoopCueId,
    String? fallbackCueId,
  }) async {
    final now = DateTime.now();
    final project = Project(
      id: 'project_${now.microsecondsSinceEpoch}',
      name: name,
      opponent: opponent,
      venue: venue,
      date: date,
      fallbackCueId: fallbackCueId,
      sponsorLoopCueId: sponsorLoopCueId,
      clipCount: 0,
      createdAt: now,
      updatedAt: now,
      isActive: false,
    );
    await _repository.saveProject(project);
  }

  Future<void> updateProject(ProjectItemModel model) async {
    final current = await _repository.getProjectById(model.id);
    if (current == null) {
      return;
    }

    await _repository.saveProject(
      current.copyWith(
        name: model.name,
        opponent: model.opponent,
        venue: model.venue,
        date: model.date,
        fallbackCueId: model.fallbackCueId,
        sponsorLoopCueId: model.sponsorLoopCueId,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteProject(String id) {
    return _repository.deleteProject(id);
  }

  Future<void> setActiveProject(String id) {
    return _repository.setActiveProject(id);
  }

  Future<ProjectItemModel?> getActiveProject() async {
    final active = await _repository.getActiveProject();
    if (active == null) {
      return null;
    }

    return ProjectItemModel(
      id: active.id,
      name: active.name,
      opponent: active.opponent,
      venue: active.venue,
      date: active.date,
      clipCount: active.clipCount,
      isActive: active.isActive,
      fallbackCueId: active.fallbackCueId,
      sponsorLoopCueId: active.sponsorLoopCueId,
    );
  }
}
