import 'package:led_managementsoftware_app/data/datasources/local/local_scene_source.dart';
import 'package:led_managementsoftware_app/data/models/scene_dto.dart';

class InMemorySceneSource implements LocalSceneSource {
  final Map<String, List<SceneDto>> _store = {};

  @override
  Future<List<SceneDto>> readScenes(String projectId) async {
    return List<SceneDto>.from(_store[projectId] ?? const []);
  }

  @override
  Future<void> writeScenes(String projectId, List<SceneDto> scenes) async {
    _store[projectId] = List<SceneDto>.from(scenes);
  }
}
