import 'package:led_managementsoftware_app/data/datasources/remote/remote_media_source.dart';
import 'package:led_managementsoftware_app/data/models/media_item_dto.dart';

class OfflineRemoteMediaSource implements RemoteMediaSource {
  final Map<String, List<MediaItemDto>> _store = {};

  @override
  Future<List<MediaItemDto>> fetchMediaForProject(String projectId) async {
    return List<MediaItemDto>.from(_store[projectId] ?? const []);
  }

  @override
  Future<MediaItemDto> upsertMedia(MediaItemDto media) async {
    final projectId = _defaultScope;
    final scoped = List<MediaItemDto>.from(_store[projectId] ?? const []);
    _store[projectId] = [...scoped.where((entry) => entry.id != media.id), media];
    return media;
  }

  static const String _defaultScope = 'global';
}