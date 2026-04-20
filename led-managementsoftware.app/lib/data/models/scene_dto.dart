import 'package:led_managementsoftware_app/data/models/scene_clip_dto.dart';
import 'package:led_managementsoftware_app/domain/entities/scene.dart';
import 'package:led_managementsoftware_app/domain/enums/scene_category.dart';

class SceneDto {
  const SceneDto({
    required this.id,
    required this.projectId,
    required this.name,
    required this.category,
    required this.isLooping,
    required this.isActive,
    required this.isDefault,
    this.fallbackSceneId,
    required this.createdAt,
    required this.updatedAt,
    required this.clips,
  });

  final String id;
  final String projectId;
  final String name;
  final String category;
  final bool isLooping;
  final bool isActive;
  final bool isDefault;
  final String? fallbackSceneId;
  final String createdAt;
  final String updatedAt;
  final List<SceneClipDto> clips;

  factory SceneDto.fromEntity(Scene entity) {
    return SceneDto(
      id: entity.id,
      projectId: entity.projectId,
      name: entity.name,
      category: entity.category.name,
      isLooping: entity.isLooping,
      isActive: entity.isActive,
      isDefault: entity.isDefault,
      fallbackSceneId: entity.fallbackSceneId,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      clips: entity.clips.map(SceneClipDto.fromEntity).toList(),
    );
  }

  Scene toEntity() {
    return Scene(
      id: id,
      projectId: projectId,
      name: name,
      category: SceneCategoryX.fromValue(category),
      isLooping: isLooping,
      isActive: isActive,
      isDefault: isDefault,
      fallbackSceneId: fallbackSceneId,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      clips: clips.map((clip) => clip.toEntity()).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'category': category,
      'isLooping': isLooping,
      'isActive': isActive,
      'isDefault': isDefault,
      'fallbackSceneId': fallbackSceneId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'clips': clips.map((clip) => clip.toMap()).toList(),
    };
  }

  factory SceneDto.fromMap(Map<String, dynamic> map) {
    return SceneDto(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      isLooping: map['isLooping'] as bool,
      isActive: map['isActive'] as bool,
      isDefault: map['isDefault'] as bool,
      fallbackSceneId: map['fallbackSceneId'] as String?,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
      clips: ((map['clips'] as List<dynamic>?) ?? const [])
          .map((entry) => SceneClipDto.fromMap(entry as Map<String, dynamic>))
          .toList(),
    );
  }
}
