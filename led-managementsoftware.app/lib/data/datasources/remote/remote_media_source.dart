import 'package:led_managementsoftware_app/data/models/media_item_dto.dart';

abstract class RemoteMediaSource {
  Future<List<MediaItemDto>> fetchMediaForProject(String projectId);
  Future<MediaItemDto> upsertMedia(MediaItemDto media);
}
