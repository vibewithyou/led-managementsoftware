import 'package:led_managementsoftware_app/domain/entities/media_category.dart';

class MediaCategoryDto {
  const MediaCategoryDto({
    required this.id,
    required this.name,
    required this.isSystemCategory,
  });

  final String id;
  final String name;
  final bool isSystemCategory;

  factory MediaCategoryDto.fromEntity(MediaCategory entity) {
    return MediaCategoryDto(
      id: entity.id,
      name: entity.name,
      isSystemCategory: entity.isSystemCategory,
    );
  }

  MediaCategory toEntity() {
    return MediaCategory(
      id: id,
      name: name,
      isSystemCategory: isSystemCategory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isSystemCategory': isSystemCategory,
    };
  }

  factory MediaCategoryDto.fromMap(Map<String, dynamic> map) {
    return MediaCategoryDto(
      id: map['id'] as String,
      name: map['name'] as String,
      isSystemCategory: map['isSystemCategory'] as bool,
    );
  }
}
