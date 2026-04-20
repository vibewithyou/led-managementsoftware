import 'package:led_managementsoftware_app/data/datasources/local/local_media_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/remote_media_source.dart';
import 'package:led_managementsoftware_app/data/models/media_item_dto.dart';
import 'package:led_managementsoftware_app/domain/entities/media_item.dart';
import 'package:led_managementsoftware_app/domain/repositories/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  MediaRepositoryImpl({
    required this.localSource,
    required this.remoteSource,
  });

  final LocalMediaSource localSource;
  final RemoteMediaSource remoteSource;

  @override
  Future<List<MediaItem>> fetchMediaForProject(String projectId) async {
    try {
      final remote = await remoteSource.fetchMediaForProject(projectId);
      await localSource.writeMediaForProject(_mediaScope, remote);
      return remote.map((dto) => dto.toEntity()).toList(growable: false);
    } catch (_) {
      final local = await localSource.readMediaForProject(_mediaScope);
      return local.map((dto) => dto.toEntity()).toList(growable: false);
    }
  }

  @override
  Future<MediaItem> saveMedia(MediaItem item) async {
    final dto = MediaItemDto.fromEntity(item);

    try {
      final savedRemote = await remoteSource.upsertMedia(dto);
      final local = await localSource.readMediaForProject(_mediaScope);
      final next = [...local.where((entry) => entry.id != savedRemote.id), savedRemote];
      await localSource.writeMediaForProject(_mediaScope, next);
      return savedRemote.toEntity();
    } catch (_) {
      final local = await localSource.readMediaForProject(_mediaScope);
      final next = [...local.where((entry) => entry.id != dto.id), dto];
      await localSource.writeMediaForProject(_mediaScope, next);
      return dto.toEntity();
    }
  }

  static const String _mediaScope = 'global';
}
