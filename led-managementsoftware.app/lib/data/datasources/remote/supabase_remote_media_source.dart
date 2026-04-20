import 'package:led_managementsoftware_app/data/datasources/remote/remote_media_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/supabase_tables.dart';
import 'package:led_managementsoftware_app/data/models/media_item_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRemoteMediaSource implements RemoteMediaSource {
  SupabaseRemoteMediaSource(this.client);

  final SupabaseClient client;

  @override
  Future<List<MediaItemDto>> fetchMediaForProject(String projectId) async {
    final response = await client
        .from(SupabaseTables.mediaItems)
        .select()
        .order('updated_at', ascending: false);

    return response
        .map((row) => MediaItemDto.fromMap(_fromDbMap(row)))
        .toList(growable: false);
  }

  @override
  Future<MediaItemDto> upsertMedia(MediaItemDto media) async {
    final response = await client
        .from(SupabaseTables.mediaItems)
        .upsert(_toDbMap(media), onConflict: 'id')
        .select()
        .single();
    return MediaItemDto.fromMap(_fromDbMap(response));
  }

  Map<String, dynamic> _toDbMap(MediaItemDto dto) {
    return {
      'id': dto.id,
      'name': dto.name,
      'local_path': dto.localPath,
      'remote_path': dto.remotePath,
      'type': dto.type,
      'category_id': dto.categoryId,
      'tags': dto.tags,
      'duration_ms': dto.durationMs,
      'is_active': dto.isActive,
      'sync_status': dto.syncStatus,
      'checksum': dto.checksum,
      'created_at': dto.createdAt,
      'updated_at': dto.updatedAt,
    };
  }

  Map<String, dynamic> _fromDbMap(Map<String, dynamic> map) {
    return {
      'id': map['id'],
      'name': map['name'],
      'localPath': map['local_path'],
      'remotePath': map['remote_path'],
      'type': map['type'],
      'categoryId': map['category_id'],
      'tags': map['tags'] ?? const <String>[],
      'durationMs': map['duration_ms'],
      'isActive': map['is_active'],
      'syncStatus': map['sync_status'],
      'checksum': map['checksum'],
      'createdAt': map['created_at'],
      'updatedAt': map['updated_at'],
    };
  }
}
