import 'package:led_managementsoftware_app/data/datasources/remote/remote_scene_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/supabase_tables.dart';
import 'package:led_managementsoftware_app/data/models/scene_clip_dto.dart';
import 'package:led_managementsoftware_app/data/models/scene_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRemoteSceneSource implements RemoteSceneSource {
  SupabaseRemoteSceneSource(this.client);

  final SupabaseClient client;

  @override
  Future<List<SceneDto>> fetchScenes(String projectId) async {
    final sceneRows = await client.from(SupabaseTables.scenes).select().eq('project_id', projectId).order('updated_at');
    final clipRows = await client.from(SupabaseTables.sceneClips).select().eq('project_id', projectId).order('sort_order');

    final clipsByScene = <String, List<SceneClipDto>>{};
    for (final raw in clipRows) {
      final mapped = _clipFromDb(raw);
      clipsByScene.putIfAbsent(mapped.sceneId, () => []).add(mapped);
    }

    return sceneRows.map((row) {
      final id = row['id'] as String;
      final dto = _sceneFromDb(row);
      return SceneDto(
        id: dto.id,
        projectId: dto.projectId,
        name: dto.name,
        category: dto.category,
        isLooping: dto.isLooping,
        isActive: dto.isActive,
        isDefault: dto.isDefault,
        fallbackSceneId: dto.fallbackSceneId,
        createdAt: dto.createdAt,
        updatedAt: dto.updatedAt,
        clips: clipsByScene[id] ?? const <SceneClipDto>[],
      );
    }).toList(growable: false);
  }

  @override
  Future<SceneDto> upsertScene(SceneDto scene) async {
    final persisted = await client.from(SupabaseTables.scenes).upsert(_sceneToDb(scene), onConflict: 'id').select().single();

    for (var i = 0; i < scene.clips.length; i++) {
      final clip = scene.clips[i];
      await client.from(SupabaseTables.sceneClips).upsert(_clipToDb(clip, scene.projectId, i), onConflict: 'id');
    }

    final dto = _sceneFromDb(persisted);
    return SceneDto(
      id: dto.id,
      projectId: dto.projectId,
      name: dto.name,
      category: dto.category,
      isLooping: dto.isLooping,
      isActive: dto.isActive,
      isDefault: dto.isDefault,
      fallbackSceneId: dto.fallbackSceneId,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      clips: scene.clips,
    );
  }

  SceneDto _sceneFromDb(Map<String, dynamic> map) {
    return SceneDto(
      id: map['id'] as String,
      projectId: map['project_id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      isLooping: map['is_looping'] as bool,
      isActive: map['is_active'] as bool,
      isDefault: map['is_default'] as bool,
      fallbackSceneId: map['fallback_scene_id'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      clips: const <SceneClipDto>[],
    );
  }

  Map<String, dynamic> _sceneToDb(SceneDto dto) {
    return {
      'id': dto.id,
      'project_id': dto.projectId,
      'name': dto.name,
      'category': dto.category,
      'is_looping': dto.isLooping,
      'is_active': dto.isActive,
      'is_default': dto.isDefault,
      'fallback_scene_id': dto.fallbackSceneId,
      'created_at': dto.createdAt,
      'updated_at': dto.updatedAt,
    };
  }

  SceneClipDto _clipFromDb(Map<String, dynamic> map) {
    return SceneClipDto(
      id: map['id'] as String,
      sceneId: map['scene_id'] as String,
      mediaItemId: map['media_item_id'] as String,
      orderIndex: map['sort_order'] as int,
      isProtected: map['is_protected'] as bool,
      isOverridable: map['is_overridable'] as bool,
      priority: map['priority'] as int,
      playOnce: map['play_once'] as bool,
      repeatable: map['repeatable'] as bool,
      rotationGroup: map['rotation_group'] as String?,
      returnBehavior: map['return_behavior'] as String,
      interruptionPolicy: map['interruption_policy'] as String,
    );
  }

  Map<String, dynamic> _clipToDb(SceneClipDto dto, String projectId, int sortOrder) {
    return {
      'id': dto.id,
      'project_id': projectId,
      'scene_id': dto.sceneId,
      'media_item_id': dto.mediaItemId,
      'is_protected': dto.isProtected,
      'is_overridable': dto.isOverridable,
      'priority': dto.priority,
      'play_once': dto.playOnce,
      'repeatable': dto.repeatable,
      'rotation_group': dto.rotationGroup,
      'return_behavior': dto.returnBehavior,
      'interruption_policy': dto.interruptionPolicy,
      'sort_order': sortOrder,
    };
  }
}
