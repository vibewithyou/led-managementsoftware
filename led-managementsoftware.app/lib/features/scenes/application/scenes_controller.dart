import 'package:led_managementsoftware_app/domain/entities/scene.dart';
import 'package:led_managementsoftware_app/domain/repositories/scene_repository.dart';

class ScenesController {
  ScenesController(this.repository);

  final SceneRepository repository;

  Future<List<Scene>> loadForProject(String projectId) {
    return repository.fetchScenes(projectId);
  }
}
