import 'package:led_managementsoftware_app/domain/entities/entity_utils.dart';
import 'package:led_managementsoftware_app/domain/entities/scene_clip.dart';
import 'package:led_managementsoftware_app/domain/enums/scene_category.dart';

class Scene {
  const Scene({
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
    this.clips = const [],
  });

  final String id;
  final String projectId;
  final String name;
  final SceneCategory category;
  final bool isLooping;
  final bool isActive;
  final bool isDefault;
  final String? fallbackSceneId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SceneClip> clips;

  Scene copyWith({
    String? id,
    String? projectId,
    String? name,
    SceneCategory? category,
    bool? isLooping,
    bool? isActive,
    bool? isDefault,
    String? fallbackSceneId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<SceneClip>? clips,
  }) {
    return Scene(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      category: category ?? this.category,
      isLooping: isLooping ?? this.isLooping,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      fallbackSceneId: fallbackSceneId ?? this.fallbackSceneId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      clips: clips ?? this.clips,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'category': category.name,
      'isLooping': isLooping,
      'isActive': isActive,
      'isDefault': isDefault,
      'fallbackSceneId': fallbackSceneId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'clips': clips.map((clip) => clip.toMap()).toList(),
    };
  }

  factory Scene.fromMap(Map<String, dynamic> map) {
    return Scene(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      name: map['name'] as String,
      category: SceneCategoryX.fromValue(map['category'] as String),
      isLooping: map['isLooping'] as bool,
      isActive: map['isActive'] as bool,
      isDefault: map['isDefault'] as bool,
      fallbackSceneId: map['fallbackSceneId'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      clips: ((map['clips'] as List<dynamic>?) ?? const [])
          .map((entry) => SceneClip.fromMap(entry as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Scene &&
        other.id == id &&
        other.projectId == projectId &&
        other.name == name &&
        other.category == category &&
        other.isLooping == isLooping &&
        other.isActive == isActive &&
        other.isDefault == isDefault &&
        other.fallbackSceneId == fallbackSceneId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        listEqualsByValue(other.clips, clips);
  }

  @override
  int get hashCode => Object.hash(
        id,
        projectId,
        name,
        category,
        isLooping,
        isActive,
        isDefault,
        fallbackSceneId,
        createdAt,
        updatedAt,
        listHash(clips),
      );
}
