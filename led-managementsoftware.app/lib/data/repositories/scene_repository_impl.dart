import 'package:led_managementsoftware_app/data/datasources/local/local_scene_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/remote_scene_source.dart';
import 'package:led_managementsoftware_app/data/models/scene_dto.dart';
import 'package:led_managementsoftware_app/domain/entities/scene.dart';
import 'package:led_managementsoftware_app/domain/repositories/scene_repository.dart';

class SceneRepositoryImpl implements SceneRepository {
  SceneRepositoryImpl({
    required this.localSource,
    required this.remoteSource,
  });

  final LocalSceneSource localSource;
  final RemoteSceneSource remoteSource;

  @override
  Future<List<Scene>> fetchScenes(String projectId) async {
    try {
      final remote = await remoteSource.fetchScenes(projectId);
      await localSource.writeScenes(projectId, remote);
      return remote.map((dto) => dto.toEntity()).toList(growable: false);
    } catch (_) {
      final local = await localSource.readScenes(projectId);
      return local.map((dto) => dto.toEntity()).toList(growable: false);
    }
  }

  @override
  Future<Scene> saveScene(Scene scene) async {
    final dto = SceneDto.fromEntity(scene);

    try {
      final savedRemote = await remoteSource.upsertScene(dto);
      final local = await localSource.readScenes(scene.projectId);
      final next = [...local.where((entry) => entry.id != savedRemote.id), savedRemote];
      await localSource.writeScenes(scene.projectId, next);
      return savedRemote.toEntity();
    } catch (_) {
      final local = await localSource.readScenes(scene.projectId);
      final next = [...local.where((entry) => entry.id != dto.id), dto];
      await localSource.writeScenes(scene.projectId, next);
      return dto.toEntity();
    }
  }
}
