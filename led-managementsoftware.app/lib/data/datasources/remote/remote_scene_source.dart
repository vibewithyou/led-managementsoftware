import 'package:led_managementsoftware_app/data/models/scene_dto.dart';

abstract class RemoteSceneSource {
  Future<List<SceneDto>> fetchScenes(String projectId);
  Future<SceneDto> upsertScene(SceneDto scene);
}
