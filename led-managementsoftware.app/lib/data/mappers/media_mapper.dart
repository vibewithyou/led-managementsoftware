import 'package:led_managementsoftware_app/data/models/media_item_dto.dart';
import 'package:led_managementsoftware_app/domain/entities/media_item.dart';

class MediaMapper {
  const MediaMapper._();

  static MediaItem fromDto(MediaItemDto dto) => dto.toEntity();
  static MediaItemDto toDto(MediaItem entity) => MediaItemDto.fromEntity(entity);
}
