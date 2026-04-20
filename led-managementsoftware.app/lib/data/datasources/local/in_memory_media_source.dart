import 'package:led_managementsoftware_app/data/datasources/local/local_media_source.dart';
import 'package:led_managementsoftware_app/data/models/media_item_dto.dart';

class InMemoryMediaSource implements LocalMediaSource {
  final Map<String, List<MediaItemDto>> _store = {};

  @override
  Future<List<MediaItemDto>> readMediaForProject(String projectId) async {
    return List<MediaItemDto>.from(_store[projectId] ?? const []);
  }

  @override
  Future<void> writeMediaForProject(String projectId, List<MediaItemDto> media) async {
    _store[projectId] = List<MediaItemDto>.from(media);
  }
}
