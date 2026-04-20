import 'package:led_managementsoftware_app/data/datasources/remote/remote_scene_source.dart';
import 'package:led_managementsoftware_app/data/models/scene_dto.dart';

class MockRemoteSceneSource implements RemoteSceneSource {
  final Map<String, List<SceneDto>> _store = {};

  @override
  Future<List<SceneDto>> fetchScenes(String projectId) async {
    return List<SceneDto>.from(_store[projectId] ?? const []);
  }

  @override
  Future<SceneDto> upsertScene(SceneDto scene) async {
    final current = List<SceneDto>.from(_store[scene.projectId] ?? const []);
    final filtered = current.where((entry) => entry.id != scene.id).toList(growable: false);
    _store[scene.projectId] = [...filtered, scene];
    return scene;
  }
}
