import 'package:led_managementsoftware_app/data/models/media_item_dto.dart';

abstract class LocalMediaSource {
  Future<List<MediaItemDto>> readMediaForProject(String projectId);
  Future<void> writeMediaForProject(String projectId, List<MediaItemDto> media);
}
