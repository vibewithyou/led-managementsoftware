import 'package:led_managementsoftware_app/data/datasources/local/local_project_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/remote_project_source.dart';
import 'package:led_managementsoftware_app/data/models/project_dto.dart';
import 'package:led_managementsoftware_app/domain/entities/project.dart';
import 'package:led_managementsoftware_app/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl({
    required this.localSource,
    required this.remoteSource,
  });

  final LocalProjectSource localSource;
  final RemoteProjectSource remoteSource;

  @override
  Future<List<Project>> fetchProjects() async {
    try {
      final remote = await remoteSource.fetchProjects();
      await localSource.writeProjects(remote);
      return remote.map((dto) => dto.toEntity()).toList(growable: false);
    } catch (_) {
      final local = await localSource.readProjects();
      return local.map((dto) => dto.toEntity()).toList(growable: false);
    }
  }

  @override
  Future<Project> saveProject(Project project) async {
    final dto = ProjectDto.fromEntity(project);

    try {
      final saved = await remoteSource.upsertProject(dto);
      final currentLocal = await localSource.readProjects();
      final next = [...currentLocal.where((entry) => entry.id != saved.id), saved];
      await localSource.writeProjects(next);
      return saved.toEntity();
    } catch (_) {
      final currentLocal = await localSource.readProjects();
      final next = [...currentLocal.where((entry) => entry.id != dto.id), dto];
      await localSource.writeProjects(next);
      return dto.toEntity();
    }
  }
}
