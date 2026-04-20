import 'package:led_managementsoftware_app/domain/entities/media_item.dart';

abstract class MediaRepository {
  Future<List<MediaItem>> fetchMediaForProject(String projectId);
  Future<MediaItem> saveMedia(MediaItem item);
}
