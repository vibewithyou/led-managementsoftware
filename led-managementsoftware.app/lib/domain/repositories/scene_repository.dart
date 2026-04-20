import 'package:led_managementsoftware_app/domain/entities/scene.dart';

abstract class SceneRepository {
  Future<List<Scene>> fetchScenes(String projectId);
  Future<Scene> saveScene(Scene scene);
}
