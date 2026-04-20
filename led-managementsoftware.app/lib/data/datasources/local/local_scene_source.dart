import 'package:led_managementsoftware_app/data/models/scene_dto.dart';

abstract class LocalSceneSource {
  Future<List<SceneDto>> readScenes(String projectId);
  Future<void> writeScenes(String projectId, List<SceneDto> scenes);
}
